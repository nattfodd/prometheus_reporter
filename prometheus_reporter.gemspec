# frozen_string_literal: true

require_relative 'lib/prometheus_reporter/version'

Gem::Specification.new do |s|
  s.name     = 'prometheus_reporter'
  s.version  = PrometheusReporter::VERSION
  s.summary  = 'Generates & parses prometheus text reporting format'
  s.authors  = ['Oleksii Kuznietsov (nattfodd)']
  s.email    = ['nattfodd.pp.ua@gmail.com']
  s.homepage = 'https://github.com/nattfodd/prometheus_reporter'
  s.licenses = ['MIT']
  s.files    = `git ls-files -z`.split("\x0")
                                .reject do |f|
                                  f.match(%r{^(test|spec|features)/})
                                end
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.required_ruby_version = '~> 2.4'

  s.require_paths = ['lib']

  s.add_development_dependency 'pry', '~> 0.11'
  s.add_development_dependency 'rspec', '~> 3.7'
  s.add_development_dependency 'rubocop', '~> 0.52'
  s.add_development_dependency 'simplecov', '~> 0.15'
end
