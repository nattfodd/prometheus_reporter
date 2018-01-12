[![Gem Version](https://badge.fury.io/rb/prometheus_reporter.svg)](https://badge.fury.io/rb/prometheus_reporter) [![Build Status](https://travis-ci.org/nattfodd/prometheus_reporter.svg?branch=master)](https://travis-ci.org/nattfodd/prometheus_reporter)

## Configuration

You may want to have metric keys application prefix to distinguish those metrics
from metric keys of other applications.

By default, `prefix` isn't used.

```ruby
PrometheusReporter.configure do |config|
  config.prefix = 'my_web_app'
end

f = PrometheusReporter::TextFormatter.new
f.entry(:emails_count, 567)
f.to_s # => "my_web_app_emails_count 567\n"
```

You can overwrite it passing another prefix to a new `TextFormatter` instance:

```ruby
f = PrometheusReporter::TextFormatter.new(prefix: 'facebook_clone')
f.entry(:emails_count, 987)
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

### Parsing Prometheus text format (not implemented yet):

```ruby
str = <<-PROMETHEUS_TEXT
  # HELP facebook_clone_emails_today Amount of emails sent from the beginning of the day
  # TYPE facebook_clone_emails_today counter
  facebook_clone_emails_today{type="notify_for_inactivity"} 10 1515681885
  facebook_clone_emails_today{type="registration_confirmation"} 18 1515681886
PROMETHEUS_TEXT
p = PrometheusReporter::TextParser.new(str)
p.extract
# =>
#  [
#    {
#      facebook_clone_emails_today:
#        {
#          value: 10,
#          labels: { type: 'notify_for_inactivity' },
#          timestamp: 1515681885,
#          type: 'counter',
#          help: 'Amount of emails sent from the beginning of the day'
#        }
#    },
#    {
#      facebook_clone_emails_today:
#        {
#          value: 18,
#          labels: { type: 'registration_confirmation' },
#          timestamp: 1515681886,
#          type: 'counter',
#          help: 'Amount of emails sent from the beginning of the day'
#        }
#    }
#  ]
```
