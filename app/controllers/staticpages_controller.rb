class StaticpagesController < ApplicationController
  #skip_before_action :require_login, only: [:top, :terms, :privacy_policy]
  def top
  end

  def terms
    html_content = render_to_string(template: 'staticpages/terms', layout: false, formats: [:html])
    render json: { html: html_content }, status: :ok
  end

  def privacy_policy
    html_content = render_to_string(template: '/staticpages/privacy_policy', layout: false, formats: [:html])
    render json: { html: html_content }, status: :ok
  end
end