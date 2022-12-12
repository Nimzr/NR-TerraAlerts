## Create a new Alert Policy

resource "newrelic_alert_policy" "mytestpolicy" {
  name                  = "My Test Policy"
  incident_preference   = "PER_POLICY" # PER_POLICY is default
}


# Creates an email alert destination.
resource "newrelic_notification_destination" "mytestdestination" {
  name = "terraform-email-destination"
  type = "EMAIL"

  property {
    key = "email"
    value = "nima@beaming.digital,nadib@newrelic.com"
  }
}


resource "newrelic_notification_channel" "mytestchannel" {
  name = "channel-email"
  type = "EMAIL"
  destination_id = newrelic_notification_destination.mytestdestination.id
  product = "IINT"

  property {
    key = "subject"
    value = "My Test Subject"
  }

    property {
    key = "customDetailsEmail"
    value = "issue id - {{issueId}}"
  }
}

// A workflow that matches issues that include incidents triggered by the policy
resource "newrelic_workflow" "workflow-example" {
  name = "workflow-example"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "Filter-name"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator = "EXACTLY_MATCHES"
      values = [ newrelic_alert_policy.mytestpolicy.id ]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.mytestchannel.id
  }
}

# Create an alert condition and apply it to the policy
resource "newrelic_infra_alert_condition" "mytestcpuinfraalert" {
    policy_id = newrelic_alert_policy.mytestpolicy.id

    name        = "My Test High CPU Usage Alert"
    type        = "infra_metric"
    event       = "SystemSample"
    select      = "cpuPercent"
    comparison  = "above"

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


resource "newrelic_nrql_alert_condition" "mytestnrqlalert" {
  type                         = "static"
  name                         = "My Test NRQL Alert"
  policy_id = newrelic_alert_policy.mytestpolicy.id
  description                  = "CPU Alert"
  enabled                      = true
  violation_time_limit_seconds = 3600

  # baseline type only
  baseline_direction = "upper_only"

  nrql {
    query = "FROM SystemSample SELECT average(cpuPercent) facet hostname"
  }

  critical {
    operator              = "above"
    threshold             = 80
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }

  warning {
    operator              = "above"
    threshold             = 65
    threshold_duration    = 600
    threshold_occurrences = "ALL"
  }
}
