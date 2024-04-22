class OauthsController < ApplicationController
  skip_before_action :require_login, only: [:oauth, :callback, :destroy]
  def oauth
    redirect_to line_oauth_url, allow_other_host: true
  end
  
  def callback
    provider = "line"
    if @user = login_from(provider)
        redirect_to root_path, notice: "#{provider.titleize}でログインしました"
    else
      @user = create_from(provider)
      reset_session
      auto_login(@user)
      if @user.persisted?
        redirect_to events_path, notice: "#{provider.titleize}でログインしました"
      else
        redirect_to root_path, alert: "ログインに失敗しました"
      end
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
      bot_prompt = "nomal"
  
      "https://access.line.me/oauth2/v2.1/authorize?response_type=code&client_id=#{client_id}&redirect_uri=#{CGI.escape(redirect_uri)}&state=#{state}&bot_prompt=#{bot_prompt}&scope=#{CGI.escape(scope)}"
    end
end