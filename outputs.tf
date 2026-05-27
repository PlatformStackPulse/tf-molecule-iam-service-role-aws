output "enabled" {
  description = "Whether the module is enabled"
  value       = local.enabled
}

output "role_arn" {
  description = "ARN of the IAM role"
  value       = module.role.role_arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = module.role.role_name
}

output "role_id" {
  description = "ID of the IAM role"
  value       = module.role.role_id
}

output "policy_arn" {
  description = "ARN of the IAM policy"
  value       = module.policy.policy_arn
}

output "policy_name" {
  description = "Name of the IAM policy"
  value       = module.policy.policy_name
}

output "instance_profile_arn" {
  description = "ARN of the instance profile (null if not created)"
  value       = try(module.instance_profile[0].instance_profile_arn, null)
}

output "instance_profile_name" {
  description = "Name of the instance profile (null if not created)"
  value       = try(module.instance_profile[0].instance_profile_name, null)
}
