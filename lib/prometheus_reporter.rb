# frozen_string_literal: true

require 'ostruct'

require_relative 'prometheus_reporter/errors'
require_relative 'prometheus_reporter/configuration'

module PrometheusReporter
  extend Configuration
end

require_relative 'prometheus_reporter/version'
require_relative 'prometheus_reporter/text_formatter'
