#!/usr/bin/env rake

ENV['RACK_ENV']               ||= "development"
ENV['HEATHEN_STORAGE_ROOT']   ||= File.expand_path('../storage', __FILE__)
ENV['RACK_RELATIVE_URL_ROOT'] ||= '/heathen'

require ($app = File.expand_path('../app', __FILE__))

namespace :heathen do

  namespace :redis do
    desc "Clear the redis database keys"
    task :clear do
      redis = Heathen::App.redis
      redis.keys.each { |k| redis.del(k) }
    end
  end

  namespace :cache do
    desc 'Clear the cache, causing access to existing conversion urls to reprocess content'
    task :clear do
      sh "rm -rf #{Heathen::App.cache_storage_root + '*'}"
    end
  end

  namespace :temp do
    desc 'Clear the temp storage (useful for development)'
    task :clear do
      sh "rm -rf #{Heathen::App.temp_storage_root + '*'}"
    end
  end

  desc 'Clear the redis keys and the cache'
  task :clear => [ 'redis:clear', 'cache:clear', 'temp:clear' ]

  desc "Run a console"
  task :console do
    sh "irb -r #{$app}"
  end
end

