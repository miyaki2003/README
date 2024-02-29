Rails.application.config.middleware.use OmniAuth::Builder do
  provider :line, ENV['LINE_KEY'], ENV['LINE_SECRET']
end