# Unit Tests — tf-molecule-iam-service-role-aws
#
# These tests use a mock AWS provider — no real AWS calls are made.
# Only plan-KNOWN values are asserted (tf-label flags, input pass-throughs,
# optional-resource nullability). Computed ARNs/IDs are unknown under a mock
# provider and are intentionally NOT asserted.
#
# Run with:      terraform test -test-directory=tests/unit
# Run verbose:   terraform test -test-directory=tests/unit -verbose

mock_provider "aws" {}

# The child IAM atoms' computed outputs (role name, policy ARN) resolve to null
# under a mock provider, which trips the downstream attachment atom's input
# validation. Override those child-module outputs file-wide with known, valid
# sample values so the composition plans cleanly in every run block.
override_module {
  target = module.role
  outputs = {
    enabled        = true
    role_arn       = "arn:aws:iam::123456789012:role/eg-test-thing"
    role_name      = "eg-test-thing"
    role_id        = "AROAEXAMPLEID123456"
    role_unique_id = "AROAEXAMPLEID123456"
  }
}

override_module {
  target = module.policy
  outputs = {
    enabled     = true
    policy_arn  = "arn:aws:iam::123456789012:policy/eg-test-thing"
    policy_name = "eg-test-thing"
    policy_id   = "ANPAEXAMPLEID123456"
  }
}

variables {
  # tf-label identity
  namespace = "eg"
  stage     = "test"
  name      = "thing"

  # Module-required inputs
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = "arn:aws:s3:::example-bucket/*"
    }]
  })
}

# ---------------------------------------------------------------------------
# Test: module is enabled and composes its atoms when enabled = true (default)
# ---------------------------------------------------------------------------
run "creates_when_enabled" {
  command = plan

  assert {
    condition     = output.enabled == true
    error_message = "Module should report enabled = true when enabled input is true (default)."
  }

  assert {
    condition     = output.instance_profile_arn == null
    error_message = "instance_profile_arn should be null when create_instance_profile is false (default)."
  }

  assert {
    condition     = output.instance_profile_name == null
    error_message = "instance_profile_name should be null when create_instance_profile is false (default)."
  }
}

# ---------------------------------------------------------------------------
# Test: module creates nothing (and reports disabled) when enabled = false
# ---------------------------------------------------------------------------
run "disabled_creates_nothing" {
  command = plan

  variables {
    enabled = false
  }

  assert {
    condition     = output.enabled == false
    error_message = "Module should report enabled = false when enabled input is false."
  }

  assert {
    condition     = output.instance_profile_arn == null
    error_message = "instance_profile_arn should be null when the module is disabled."
  }
}
