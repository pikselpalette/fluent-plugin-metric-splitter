require 'fluent/mixin/rewrite_tag_name'

module Fluent
  class MetricSplitter < Output
    Fluent::Plugin.register_output('metric_splitter', self)
    include Fluent::HandleTagNameMixin
    include Fluent::Mixin::RewriteTagName

    config_param :tag_for, :string, default: 'prefix'
    config_param :name_keys, :string, default: nil
    config_param :name_key_pattern, :string, default: nil

    attr_accessor :out_tag, :hostname_command

    unless method_defined?(:log)
      define_method("log") { $log }
    end

    def configure(conf)
      super
      @out_tag = conf['out_tag'] if conf['out_tag']
      @hostname_command = conf['hostname_command'] if conf['hostname_command']
      unless ['prefix', 'suffix', 'ignore'].include?(@tag_for)
        raise Fluent::ConfigError, 'metric_splitter: can specify to tag_for only prefix, suffix or ignore'
      end

      if [@name_keys, @name_key_pattern].compact.size != 1
        raise Fluent::ConfigError, 'metric_splitter: must have one and only one of name_keys or name_key_pattern'
      end

      if @name_keys
        @name_keys = @name_keys.split(',')
      end
      if @name_key_pattern
        @name_key_pattern = Regexp.new(@name_key_pattern)
      end
    end

    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    def start
      super
    end

    def shutdown
      super
    end

    def remap(data)
      if data.is_a? String
        if data =~ /^[0-9]+\.[0-9]+$/
          data = data.to_f
        elsif data =~ /^\d+$/
          data = data.to_i
        else
          data = nil
        end
      end
      data
    end

    def format_metrics(tag, record)
      filtered_record = if @name_keys
                          record.select { |k,v| @name_keys.include?(k) }
                        else # defined @name_key_pattern
                          record.select { |k,v| @name_key_pattern.match(k) }
                        end

      return {} if filtered_record.empty?

      metrics = {}
      tag = tag.sub(/\.$/, '') # may include a dot at the end of the emit_tag fluent-mixin-rewrite-tag-name returns. remove it.
      filtered_record.each do |k, v|
        key = case @tag_for
              when 'ignore' then k
              when 'prefix' then tag + '.' + k
              when 'suffix' then k + '.' + tag
              end

        key = key.gsub(/(\s|\/)+/, '_') # cope with in the case of containing symbols or spaces in the key of the record like in_dstat.
        next unless v = remap(v)
        metrics[key] = v
      end
      metrics
    end

    # Define `router` method of v0.12 to support v0.10 or earlier
    unless method_defined?(:router)
      define_method("router") { Fluent::Engine }
    end

    def emit(tag, es, chain)
      es.each do |time, record|
        emit_tag = tag.dup
        filter_record(emit_tag, time, record)
        metrics = format_metrics(emit_tag, record)
        metrics.each do |k, v|
          router.emit(@out_tag, time, {"time" => time, "path" => k, "data" => v})
        end
      end
      chain.next
    end
  end
end
