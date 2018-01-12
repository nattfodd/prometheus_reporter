# frozen_string_literal: true

require 'pry'
require 'simplecov'

require './lib/prometheus_reporter'

SPEC_ROOT = __dir__

def read_fixture(filename)
  File.read("#{SPEC_ROOT}/fixtures/#{filename}.txt")
end

SimpleCov.start
