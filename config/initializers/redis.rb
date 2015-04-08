Redis.current = Redis::Pool.new Rails.configuration.redis_opts.merge(driver: :hiredis)
