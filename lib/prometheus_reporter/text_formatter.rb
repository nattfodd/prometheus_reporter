# frozen_string_literal: true

module PrometheusReporter
  class TextFormatter
    TYPES      = %i[counter gauge histogram summary untyped].freeze
    LABELESS   = :labeless
    HELP_TOKEN = :help
    TYPE_TOKEN = :type
    DEFAULTS   = { HELP_TOKEN => nil, TYPE_TOKEN => nil }.freeze
    TOKENS     = [HELP_TOKEN, TYPE_TOKEN].freeze
    SEPARATOR  = "\n"

    class << self
      def draw(prefix: PrometheusReporter.config.prefix, &block)
        formatter = new(prefix: prefix)
        formatter.instance_eval(&block)
        formatter.to_s
      end
    end

    def initialize(prefix: PrometheusReporter.config.prefix)
      @data = {}
      @prefix = prefix
    end

    def help(key, description)
      set_token_value!(HELP_TOKEN, key, description)
    end

    def type(key, type)
      type = type.downcase.to_sym
      raise(UnknownMetricType, type) unless TYPES.include?(type)

      set_token_value!(TYPE_TOKEN, key, type)
    end

    def entry(key, value:, labels: {}, timestamp: nil)
      @data[prefixed(key)] ||= DEFAULTS.dup

      label_key = labels.any? ? labels : LABELESS
      entry_data =
        {
          value:     value,
          timestamp: timestamp
        }.compact

      @data[prefixed(key)][label_key] = entry_data
    end

    def to_s
      metrics_data = []

      @data.each do |prometheus_key_name, prometheus_key_values|
        prometheus_key_values = prometheus_key_values.compact
        validate_data!(prometheus_key_name, prometheus_key_values)
        metrics_data << metric_entry(prometheus_key_name, prometheus_key_values)
      end

      metrics_data.join(SEPARATOR)
    end

    private

    def set_token_value!(token, key, value)
      prefixed_key = prefixed(key)
      @data[prefixed_key] ||= DEFAULTS.dup

      if @data[prefixed_key][token]
        err_class = "PrometheusReporter::#{token.capitalize}AlreadySpecified"
        raise(Object.const_get(err_class), key)
      end

      @data[prefixed_key][token] = value
    end

    def prefixed(key)
      @prefix ? "#{@prefix}_#{key}" : key
    end

    def validate_data!(key_name, key_data)
      return if TOKENS.include?(key_name)
      return if key_data.any? { |k, _| k.is_a?(Hash) || k == LABELESS }

      raise(MissingMetricValue, key_name)
    end

    def metric_entry(prometheus_key_name, prometheus_key_values)
      metric_lines = []
      prometheus_key_values.each do |label_or_token, value|
        metric_lines << text_entry(prometheus_key_name, label_or_token, value)
      end
      (metric_lines << nil).join(SEPARATOR)
    end

    def text_entry(prometheus_key_name, label_or_token, value)
      case label_or_token
      when HELP_TOKEN
        "# HELP #{prometheus_key_name} #{value}"
      when TYPE_TOKEN
        "# TYPE #{prometheus_key_name} #{value}"
      else
        entry_to_string(prometheus_key_name, label_or_token, value)
      end
    end

    def entry_to_string(prometheus_key_name, label_or_token, value_hash)
      entry = "#{prometheus_key_name}#{labels_to_str(label_or_token)} "\
              "#{value_hash[:value]}"
      entry += " #{value_hash[:timestamp]}" if value_hash[:timestamp]
      entry
    end

    def labels_to_str(label_or_token)
      return if label_or_token == LABELESS || label_or_token.empty?

      labels_str =
        label_or_token.map do |l_name, l_value|
          "#{l_name}=\"#{l_value}\""
        end.join(',')

      "{#{labels_str}}"
    end
  end
end
