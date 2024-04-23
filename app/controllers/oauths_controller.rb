class OauthsController < ApplicationController
  skip_before_action :require_login, only: [:oauth, :callback, :destroy]

  require 'net/http'
  require 'uri'
  require 'json'
  require 'jwt' 

  def oauth
    redirect_to line_oauth_url, allow_other_host: true
  end

  def callback
    provider = "line"
    if params[:error]
      redirect_to root_path, alert: "LINEログインに失敗しました: #{params[:error_description]}"
      return
    end
    

    token_response = fetch_line_token(params[:code])
    if token_response[:access_token]
      line_id = decode_id_token(token_response[:id_token])
      @user = User.find_or_create_by(line_user_id: line_id)
      reset_session
      auto_login(@user)
      if @user.persisted?
        redirect_to events_path, notice: "#{provider.titleize}でログインしました"
      else
        redirect_to root_path, alert: "ログインに失敗しました"
      end
    else
      redirect_to root_path, alert: "LINEトークンの取得に失敗しました"
    end
  end

  def destroy
    logout
    redirect_to root_path, status: :see_other
  end

  private

  def auth_params
    params.permit(:code, :provider, :error, :state)
  end

  def line_oauth_url
    client_id = ENV['LINE_KEY']
    redirect_uri = "https://reminder-chat-38cf4e1a3ae9.herokuapp.com/auth/line/callback"
    state = SecureRandom.hex(15)
    scope = "openid profile"
    bot_prompt = "aggressive"
    "https://access.line.me/oauth2/v2.1/authorize?response_type=code&client_id=#{client_id}&redirect_uri=#{CGI.escape(redirect_uri)}&state=#{state}&bot_prompt=#{bot_prompt}&scope=#{CGI.escape(scope)}"
  end

  def fetch_line_token(code)
    uri = URI.parse("https://api.line.me/oauth2/v2.1/token")
    request = Net::HTTP::Post.new(uri)
    request.set_form_data(
      "grant_type" => "authorization_code",
      "code" => code,
      "redirect_uri" => "https://reminder-chat-38cf4e1a3ae9.herokuapp.com/auth/line/callback",
      "client_id" => ENV['LINE_KEY'],
      "client_secret" => ENV['LINE_SECRET']
    )

    req_options = {
      use_ssl: uri.scheme == "https"
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    JSON.parse(response.body, symbolize_names: true)
  end

  def decode_id_token(id_token)
    decoded_token = JWT.decode(id_token, nil, false)
    decoded_token[0]['sub']
  end

  def decode_id_token(id_token)
    jwks_url = "https://api.line.me/oauth2/v2.1/certs"
    jwks_json = Net::HTTP.get(URI(jwks_url))
    jwks_keys = Array(JSON.parse(jwks_json)['keys'])

    rsa_public = OpenSSL::PKey::RSA.new(
      JWT::JWK.import(jwks_keys.first).export_to_pem
    )

    decoded_token = JWT.decode(id_token, rsa_public, true, { algorithm: 'RS256' })
    decoded_token[0]['sub']
  end  
end