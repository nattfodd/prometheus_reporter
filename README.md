[![Gem Version](https://badge.fury.io/rb/prometheus_reporter.svg)](https://badge.fury.io/rb/prometheus_reporter) [![Build Status](https://travis-ci.org/nattfodd/prometheus_reporter.svg?branch=master)](https://travis-ci.org/nattfodd/prometheus_reporter)

## Prometheus Reporter
`prometheus_reporter` helps you to generate [Prometheus](https://prometheus.io) metric reports using its [text format](https://prometheus.io/docs/instrumenting/exposition_formats/#text-format-details). Official client helps you to monitor internal web-server guts, while `prometheus_reporter` can help you representing any data you want.

### Overview
```ruby
require 'prometheus_reporter'

f = PrometheusReporter::TextFormatter.new
f.entry(:my_metric, value: 144, labels: { source: 'api', module: 'chat' })
f.to_s
# => 'my_metric{souce="api",module="chat"} 144'
```

## Installation
Installation is pretty standard:
```bash
$ gem install prometheus_reporter
```
or using `Gemfile`:
```ruby
gem 'prometheus_reporter', '~> 1.0'
```
## Configuration

You may want to have metric keys application prefix to distinguish those metrics
from metric keys reported by other applications.

By default, `prefix` isn't used.

```ruby
PrometheusReporter.configure do |config|
  config.prefix = 'my_web_app'
end

f = PrometheusReporter::TextFormatter.new
f.entry(:emails_count, value: 567)
f.to_s # => "my_web_app_emails_count 567\n"
```

You can overwrite it passing another prefix to a new `TextFormatter` instance:

```ruby
f = PrometheusReporter::TextFormatter.new(prefix: 'facebook_clone')
f.entry(:emails_count, value: 987)
f.to_s # => "facebook_clone_emails_count 987\n"
```

## Usage

### Creating text report for Prometheus:

```ruby
require 'prometheus_reporter'

f = PrometheusReporter::TextFormatter.new
f.help(:emails_today, 'Events created from the beginning of the day')
f.type(:emails_today, :counter)
f.entry(:emails_today,
        value: 10,
        labels: { type: 'notify_for_inactivity' }
        timestamp: Time.now.to_i)
f.entry(:emails_today,
        value: 18,
        labels: { type: 'registration_confirmation' }
        timestamp: Time.now.to_i)
f.to_s
```

Produces the following output:

```
# HELP facebook_clone_emails_today Amount of emails sent from the beginning of the day
# TYPE facebook_clone_emails_today counter
facebook_clone_emails_today{type="notify_for_inactivity"} 10 1515681885
facebook_clone_emails_today{type="registration_confirmation"} 18 1515681886
```

## Usefull links
- Official Prometheus [ruby client](https://github.com/prometheus/client_ruby)
- [Prometheus](https://github.com/prometheus) itself
