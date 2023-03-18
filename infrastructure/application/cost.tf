resource "aws_budgets_budget" "resource_budget" {
  name              = var.application_name
  budget_type       = "COST"
  limit_amount      = "10.0"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2023-03-12_00:00"

  cost_filter {
    name   = "TagKeyValue"
    values = [join("$", ["user:Application", var.application_name])]
  }

  cost_types {
    use_amortized = true
  }
}