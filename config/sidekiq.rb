Sidekiq.configure_server do |config|
  if Rails.env.development?
    config.redis = { url: 'redis://localhost:6379/0' }
  elsif Rails.env.production?
    config.redis = { url: ENV['REDIS_URL'] }
  end
end
