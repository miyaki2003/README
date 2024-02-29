class SessionsController < ApplicationController
  def create
    user = LineUser.find_or_create_from_auth_hash(request.env['omniauth.auth'])
    if user
      session[:line_user_id] = user.id
      session[:line_user_name] = user.username
      redirect_to root_path, notice: "ログインしました。"
    else
      redirect_to root_path, notice: "失敗しました。"
    end
  end
end