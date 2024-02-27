class OmniauthCallbacksController < ApplicationController
  def line
    basic_action
  end

  def failure
    # 認証が失敗した時の処理
    flash[:alert] = "外部サービスでの認証に失敗しました。"
    redirect_to root_path # または、失敗時にユーザーをリダイレクトしたい任意のパス
  end

  private
  
  def basic_action
    @omniauth = request.env["omniauth.auth"]
    if @omniauth.present?
      @profile = LineUser.find_or_initialize_by(provider: @omniauth["provider"], uid: @omniauth["uid"])
      if @profile.email.blank?
        email = @omniauth["info"]["email"] ? @omniauth["info"]["email"] : "#{@omniauth["uid"]}-#{@omniauth["provider"]}@example.com"
        @profile = current_line_user || LineUser.create!(provider: @omniauth["provider"], uid: @omniauth["uid"], email: email, name: @omniauth["info"]["name"], password: Devise.friendly_token[0, 20])
      end
      @profile.set_values(@omniauth)
      sign_in(:line_user, @profile)
    end
    #ログイン後のflash messageとリダイレクト先を設定
    flash[:notice] = "ログインしました"
    redirect_to expendable_items_path
  end

  def fake_email(uid, provider)
    "#{auth.uid}-#{auth.provider}@example.com"
  end
end
