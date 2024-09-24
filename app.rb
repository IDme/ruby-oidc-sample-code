require "sinatra"
require "oauth2"
require "json/jwt"
require "httparty"

# Get this information by registering your app at https://developer.idmelabs.com
client_id         = "CLIENT_ID"
client_secret     = "CLIENT_SECRET"
redirect_uri      = "http://localhost:4567/callback"
authorization_url = "https://api.idmelabs.com/oauth/authorize"
token_url         = "https://api.idmelabs.com/oauth/token"
userinfo_url      = "https://api.idmelabs.com/api/public/v3/userinfo.json"
oidc_config_url   = "https://api.idmelabs.com/oidc/.well-known/jwks"

# Possible scope values: "military", "student", "responder", "teacher"
scope = "openid login"

# Enable sessions
use Rack::Session::Pool

# Instantiate OAuth 2.0 client
client = OAuth2::Client.new(client_id, client_secret, :authorize_url => authorization_url, :token_url => token_url)

get "/" do
  auth_endpoint = client.auth_code.authorize_url(:redirect_uri => redirect_uri, :scope => scope)
  
  <<-HTML
  <div id="idme-verification">
    <a href="#{auth_endpoint}">
      <img src="https://s3.amazonaws.com/idme/developer/idme-buttons/assets/img/signin.svg" height="50"/>
    </a>
  </div>
  HTML
end

get "/callback" do
  # Exchange the code for an access token and save it in the session
  session[:oauth_token] = client.auth_code.get_token(params[:code], :redirect_uri => redirect_uri)
  
  redirect "/profile"
end

get "/profile" do
  # Retrieve the user's attributes with the access_token we saved in the session from the "/callback" route
  token = session[:oauth_token]
  body  = token.get(userinfo_url).body
  
  # Trims the "" from the response. This required because we pass back the response malformed. TODO: Open a product intake ticket to investigate
  id_token = body.tr('""', '')
  
  # Retrieve's the most up-to-date JWT URIs we have configured at the well-known configuration endpoint
  jwts    = HTTParty.get(oidc_config_url).body
  jwk_set = JSON::JWK::Set.new(JSON.parse(jwts))
  
  # Verifies and decodes the payload using the id_token and the jwt keys
  decoded_token = JSON::JWT.decode id_token, jwk_set

  content_type "text/json"
  decoded_token.to_json
end