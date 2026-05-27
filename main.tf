# -----------------------------------------------------
# Molecule: IAM Service Role
# Composes IAM atoms into a complete service role with
# managed policy, attachment, and optional instance profile.
# -----------------------------------------------------

# --- IAM Role ---
module "role" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-iam-role-aws.git?ref=c6bc7003dc846b588c7334180f80217a3bad08f1"

  context               = module.this.context
  assume_role_policy    = var.assume_role_policy
  description           = var.role_description
  path                  = var.role_path
  max_session_duration  = var.max_session_duration
  force_detach_policies = var.force_detach_policies
}

# --- IAM Policy ---
module "policy" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-iam-policy-aws.git?ref=014a418a1640910503e888ee6fa75b0a61a5e656"

  context     = module.this.context
  description = var.policy_description
  path        = var.policy_path
  policy      = var.policy
}

# --- Attach Policy to Role ---
module "attachment" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-iam-role-policy-attachment-aws.git?ref=c6719afbd6067eee7db36aaa5acc581d108bf413"

  context    = module.this.context
  role_name  = module.role.role_name
  policy_arn = module.policy.policy_arn

  depends_on = [module.role, module.policy]
}

# --- Instance Profile (optional, for EC2) ---
module "instance_profile" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-iam-instance-profile-aws.git?ref=9194be06a01e7a064ec24c87956d59cab42719f8"
  count  = var.create_instance_profile ? 1 : 0

  context   = module.this.context
  role_name = module.role.role_name
  path      = var.role_path

  depends_on = [module.role]
}
