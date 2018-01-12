# frozen_string_literal: true

module PrometheusReporter
  module Configuration
    CONFIG_KEYS = %i[prefix].freeze

    def config
      @config ||= OpenStruct.new
    end

    def configure
      yield(config)
      config.to_h.each_key do |key|
        raise(UnknownConfig, key) unless CONFIG_KEYS.include?(key)
      end
    end
  end
end
