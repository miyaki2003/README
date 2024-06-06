class StaticpagesController < ApplicationController
  skip_before_action :require_login, only: [:top, :terms, :privacy_policy]
  def top; end

  def terms; end

  def privacy_policy; end
end
