resource "newrelic_one_dashboard" "exampledash" {
  name        = "New Relic Terraform Example"
  permissions = "public_read_only"

  page {
    name = "New Relic Terraform Example"

    widget_billboard {
      title  = "Average CPU"
      row    = 1
      column = 1
      width  = 6
      height = 3

      nrql_query {
        query = "FROM SystemSample SELECT average(cpuPercent) facet hostname"
      }
    }

    widget_line {
      title  = "Average CPU OverTime"
      row    = 4
      column = 1
      width  = 6
      height = 3

      nrql_query {
        account_id = var.account_id
        query      = "FROM SystemSample Select average(cpuPercent) facet hostname since 24 hours ago timeseries"
      }

    
    }
  }
}