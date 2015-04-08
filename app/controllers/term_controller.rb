class TermController < WebsocketRails::BaseController
  def user_connected
    p 'user connected'

    key_objects = get_key_objects Redis.current.keys.sort

    broadcast_message :all_keys, key_objects
  end

  def key_tab_complete
    p "key search for '#{message['string']}'"

    search = message['string']
    search += '*' unless search.match(/\*/)

    keys = Redis.current.keys(search).sort

    trigger_success keys: keys[0..10]
  end

  def redis_call
    p "redis call: '#{message['string']}'"

    command = message['string']

    method = command.split(' ').first
    command = command.gsub method, ''

    args, opts = eval "args_parser #{command}"

    resp = begin
      if args.blank? && opts.present?
        Redis.current.send(method, **opts)
      elsif args.present? && opts.blank?
        Redis.current.send(method, *args)
      elsif args.present? && opts.present?
        Redis.current.send(method, *args, **opts)
      else
        Redis.current.send method
      end
    end

    if resp.is_a?(Array) && Redis.current.type(resp.first) != 'none'
      key_objects = get_key_objects resp

      trigger_success response: "#{key_objects.count} keys matched query"

      send_message :keys, keys: key_objects

      return
    elsif method.match(/^keys$/i) && resp.blank?
      trigger_success response: "no keys matched query"
      send_message :keys, keys: []
    elsif method.match(/^(get|set)$/i)
      if key_details = get_key_details(args.first)
        trigger_success response: resp

        send_message :key, key_details
        return
      end
    end

    trigger_success response: resp
  rescue => e
    p [e.message, e.backtrace].flatten.join("\n")
    trigger_failure message: "Error on server: #{e.message}"
  end

  private

  def get_key_details(key)
    return nil if key.blank?

    futures = {}
    Redis.current.pipelined do
      futures[:value] = Redis.current.get key
      futures[:type] = Redis.current.type key
      futures[:ttl] = Redis.current.ttl key
    end

    key_obj = { key: key }
    futures.each {|obj_key, future|
      key_obj[obj_key] = future.value
    }
    key_obj
  end

  def get_key_objects(keys)
    keys_with_futures = []
    Redis.current.pipelined do
      keys.each { |key|
        obj = { key: key }
        obj[:type] = Redis.current.type(key)
        keys_with_futures << obj
      }
    end

    keys_with_futures.map {|key_obj|
      key_obj[:type] = key_obj[:type].value
      key_obj
    }
  end

  def args_parser(*args, **opts)
    [ args, opts ]
  end
end
