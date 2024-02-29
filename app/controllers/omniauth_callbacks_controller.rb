class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def line
    basic_action
  end

  def failure
    flash[:alert] = "外部サービスでの認証に失敗しました。"
    redirect_to root_path
  end

  private
  
  def basic_action
    @omniauth = request.env["omniauth.auth"]
    if @omniauth.present?
      @profile = LineUser.find_or_initialize_by(provider: @omniauth["provider"], uid: @omniauth["uid"])
      if @profile.new_record?
        @profile.name = @omniauth["info"]["name"]
        @profile.save!
      end
      sign_in(:line_user, @profile)
    end
    flash[:notice] = "ログインしました"
    redirect_to root_path
  end
end