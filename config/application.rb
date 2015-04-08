require File.expand_path('../boot', __FILE__)

# require 'rails/all'
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module Yargui
  class Application < Rails::Application
    config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')

    redis_file = Rails.root.join 'config', 'redis.yml'
    redis_yml = YAML::load ERB.new(File.read redis_file).result
    config.redis_opts = redis_yml[Rails.env || 'test'].symbolize_keys
  end
end
