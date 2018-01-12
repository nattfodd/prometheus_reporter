# frozen_string_literal: true

module PrometheusReporter
  class BaseError < StandardError; end

  class UnknownConfig < BaseError
    def initialize(key)
      @key = key
    end

    def message
      "Unknown configuration option: #{@key}"
    end
  end

  class MissingMetricValue < BaseError
    def intialize(key)
      @key = key
    end

    def message
      "Missing value for #{@key} metric"
    end
  end

  class UnknownMetricType < BaseError
    def initialize(key_type)
      @type = key_type
    end

    def message
      "Unknown key type: #{@type}. "\
        "Valid ones: #{TextFormatter::TYPES.join(', ')}"
    end
  end

  class TypeAlreadySpecified < BaseError
    def initialize(key)
      @key = key
    end

    def message
      "Can't overwrite type for the #{@key} metric (type is already specified)"
    end
  end

  class HelpAlreadySpecified < BaseError
    def initialize(key)
      @key = key
    end

    def message
      "Can't overwrite help for the #{@key} metric (help is already specified)"
    end
  end
end
