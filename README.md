## Configuration

You may want to have metric keys application prefix to distinguish those metrics
from metric keys of other applications.
By default, `application_prefix` isn't used.

```ruby
PrometheusReporter.configure do |config|
  config.application_prefix = 'facebook_clone'
end
```

## Usage

Creating text report for Prometheus:

```ruby
require 'prometheus_reporter'

f = PrometheusReporter::TextFormatter.new
# Optional: creates a line with the description for the key
# # HELP facebook_clone_emails_today Events created from the beginning of the day
f.help(:emails_today, 'Events created from the beginning of the day')
# Optional: creates a line specifying key type
# (if ommited, Prometheus marks key as :untyped)
# # TYPE facebook_clone_emails_today counter
f.type(:emails_today, :counter)
# Required: creates a line with key, labels, value, and timestamp
# facebook_clone_emails_today{type="notify_for_inactivity"} 10 1515681885
f.entry(:emails_today,
        value: 10,
        labels: { type: 'notify_for_inactivity' }
        timestamp: Time.now.to_i)
f.entry(:emails_today,
        value: 18,
        labels: { type: 'registration_confirmation' }
        timestamp: Time.now.to_i)
f.to_s
# =>
#   # HELP facebook_clone_emails_today Amount of emails sent from the beginning of the day
#   # TYPE facebook_clone_emails_today counter
#   facebook_clone_emails_today{type="notify_for_inactivity"} 10 1515681885
#   facebook_clone_emails_today{type="registration_confirmation"} 18 1515681886
```

Parsing Prometheus text format:

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
