Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
  Sidekiq.options[:concurrency] = 5
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end
