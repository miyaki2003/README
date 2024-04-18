class OauthsController < ApplicationController
  skip_before_action :require_login, only: [:oauth, :callback, :destroy]
  def oauth
    login_at(:line)
  end
  
  def callback
    provider = "line"
    omniauth_data = request.env['omniauth.auth']
    
    unless omniauth_data
      redirect_to root_path, alert: "認証データの取得に失敗しました"
      return
    end
    
    if @user = login_from(provider)
      @user.update(line_user_id: omniauth_data.uid) unless @user.line_user_id == omniauth_data.uid
      redirect_to root_path, notice: "#{provider.titleize}でログインしました"
    else
      @user = build_from(provider)
      @user.line_user_id = omniauth_data.uid
      reset_session
      auto_login(@user)
      if @user.save
        redirect_to root_path, notice: "#{provider.titleize}でログインしました"
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
end