module Embulk
  module Input

    class Redis < InputPlugin
      require 'redis'
      require 'json'

      Plugin.register_input("rediskeys", self)

      def self.transaction(config, &control)
        # configuration code:
        task = {
          'host' => config.param('host', :string, :default => 'localhost'),
          'port' => config.param('port', :integer, :default => 6379),
          'db' => config.param('db', :integer, :default => 0),
          'key_prefix' => config.param('key_prefix', :string, :default => ''),
          'encode' => config.param('encode', :string, :default => 'json')
        }
        
        redis = ::Redis.new(:host => task['host'], :port => task['port'], :db => task['db'])
        keys = redis.keys("#{task['key_prefix']}*").inject([]){|col, k|
              col.push({'name' => k, 'type' => 'string'})
              col
            }
        puts "keys:#{keys}"

        task['columns'] = config.param('columns', :array, :default => keys).inject({}){|a, col|
              a[col['name']] = col['type'].to_sym
              a
            }

        columns = task['columns'].map.with_index{|(name, type), i|
          Column.new(i, name, type)
        }

        #resume(task, columns, 1, &control)
        puts "Redis input started."
        task_reports = yield(task, columns, 1)
        puts "Redis input finished. Commit reports = #{task_reports.to_json}"
  
        return {}
      end

#      def self.resume(task, columns, count, &control)
#        task_reports = yield(task, columns, count)
#
#        next_config_diff = {}
#        return next_config_diff
#      end

      # TODO
      #def self.guess(config)
      #  sample_records = [
      #    {"example"=>"a", "column"=>1, "value"=>0.1},
      #    {"example"=>"a", "column"=>2, "value"=>0.2},
      #  ]
      #  columns = Guess::SchemaGuess.from_hash_records(sample_records)
      #  return {"columns" => columns}
      #end

      def init
        # initialization code:
        puts "Redis input thread #{index}..."
        super
        @rows = 0
        @redis = ::Redis.new(:host => task['host'], :port => task['port'], :db => task['db'])
      end

      def deserialize_element(name, x)
        begin
          type = nil
          @task['columns'].each do |key, value|
            if key == name
              type = value
              break
            end
          end
          val = x
          case type.to_sym  # Converted to String implicitly?
          when :boolean
            if val.is_a?(TrueClass) || val.is_a?(FalseClass)
              val
            else
              downcased_val = val.downcase
              case downcased_val
              when 'true' then true
              when 'false' then false
              else nil
              end
            end
          when :long
            Integer(val)
          when :double
            Float(val)
          when :string
            val
          when :timestamp
            Time.parse(val)
          else
            raise "Shouldn't reach here: val:#{val}, col_name:#{name}, col_type:#{type}"
          end
        rescue => e
          STDERR.puts "Failed to deserialize: val:#{val}, col_name:#{name}, col_type:#{type}, error:#{e.inspect}"
        end
      end

      def run
        records = []
        @redis.keys("#{@task['key_prefix']}*").each do |k|
          case @task['encode']
          when 'json'
            v = @redis.get(k)
          when 'hash'
            v = @redis.hgetall(k).to_json
          end
          v = "{\"#{k}\":#{v}}"
          x = JSON.parse(v)
          records.push(deserialize_element(k, x))
          @rows += 1
        end
        @page_builder.add(records)
        @page_builder.finish  # don't forget to call finish :-)

        task_report = {
          "rows" => @rows
        }
        return task_report
      end

    end
  end
end
