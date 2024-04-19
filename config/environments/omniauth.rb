Rails.application.config.middleware.use OmniAuth::Builder do
  provider :line, 'LINE_CHANNEL_SECRET', 'LINE_CHANNEL_TOKEN'
end
