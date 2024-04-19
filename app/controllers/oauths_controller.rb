class OauthsController < ApplicationController
  skip_before_action :require_login, only: [:oauth, :callback, :destroy]
  def oauth
    login_at(:line)
  end
  
  def callback
    provider = "line"
    omniauth_data = request.env['omniauth.auth']

    Rails.logger.info "Omniauth Data: #{omniauth_data.inspect}"

    if @user = login_from(provider)
        redirect_to root_path, notice: "#{provider.titleize}でログインしました。"
    else
      @user = create_from(provider)
      @user.line_user_id = omniauth_data['uid'] if omniauth_data['uid'].present?
      
      reset_session
      auto_login(@user)
      if @user.persisted?
        redirect_to root_path, notice: "#{provider.titleize}でログインしました。"
      else
        redirect_to root_path, alert: "ログインに失敗しました。"
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
end