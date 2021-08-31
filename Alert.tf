## Create a new Alert Policy

resource "newrelic_alert_policy" "mytestpolicy" {
  name                  = "My Test Policy"
  incident_preference   = "PER_POLICY" # PER_POLICY is default
}


# Creates an email alert channel.
resource "newrelic_alert_channel" "email_channel" {
  name          = "My Test Email Channel"
  type          = "email"

  config {
    recipients              = "nima@beaming.digital, nadib@newreli.com"
    include_json_attachment = "1"
  }
}

# Apply the Alert channel to the policy
resource "newrelic_alert_policy_channel" "mychannellink" {
    policy_id   = newrelic_alert_policy.mytestpolicy.id
    channel_ids = [
        newrelic_alert_channel.email_channel.id
    ]
}


# Create an alert condition and apply it to the policy
resource "newrelic_infra_alert_condition" "my_high_cpu_alert" {
    policy_id = newrelic_alert_policy.mytestpolicy.id

    name        = "My Test High CPU Usage Alert"
    type        = "infra_metric"
    event       = "SystemSample"
    select      = "cpuPercent"
    comparison  = "above"
    where       = "(hostname LIKE 'ubunzzy')"

    critical {
      duration      = 25
      value         = 25
      time_function = "any"
    }

    warning {
      duration      = 10 
      value         = 15
      time_function = "any"
    }
}
