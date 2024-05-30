class StaticpagesController < ApplicationController
  skip_before_action :require_login, only: [:top, :terms, :privacy_policy]
  def top; end

  def terms
    render layout: 'application'
  end

  def privacy_policy
    render layout: 'application'
  end
end
