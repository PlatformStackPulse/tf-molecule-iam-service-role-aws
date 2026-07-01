# tf-molecule-iam-service-role-aws

Terraform molecule that composes IAM atoms into a complete service role with managed policy, role-policy attachment, and optional EC2 instance profile.

## Features

- **One-shot service role** — creates an IAM role, a managed permissions policy, and the role↔policy attachment in a single module call.
- **Configurable trust policy** — supply any `assume_role_policy` (Lambda, EC2, ECS tasks, cross-account, etc.); the input is validated as JSON.
- **Validated permissions policy** — the `policy` input is validated as JSON before being turned into a managed policy.
- **Optional EC2 instance profile** — set `create_instance_profile = true` to also emit an instance profile bound to the role.
- **tf-label naming & tagging** — consistent `namespace`/`environment`/`stage`/`name` IDs and tags via the shared `tf-label` context.
- **Enable/disable switch** — `enabled = false` short-circuits the whole molecule so it creates nothing.
- **Tunable role controls** — `role_path`, `policy_path`, `max_session_duration`, and `force_detach_policies` are all exposed with sane defaults.

## Atoms Composed

| Atom | Purpose |
|------|---------|
| `tf-atom-iam-role-aws` | Creates the IAM role with trust policy |
| `tf-atom-iam-policy-aws` | Creates the managed permissions policy |
| `tf-atom-iam-role-policy-attachment-aws` | Attaches the policy to the role |
| `tf-atom-iam-instance-profile-aws` | (Optional) Creates EC2 instance profile |

## Usage

```hcl
module "lambda_role" {
  source = "git::https://github.com/PlatformStackPulse/tf-molecule-iam-service-role-aws.git?ref=v1.0.0"

  namespace   = "psp"
  environment = "prod"
  name        = "lambda-processor"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "arn:aws:logs:*:*:*"
    }]
  })
}
```

## With Instance Profile (EC2)

```hcl
module "ec2_role" {
  source = "git::https://github.com/PlatformStackPulse/tf-molecule-iam-service-role-aws.git?ref=v1.0.0"

  namespace   = "psp"
  environment = "prod"
  name        = "web-server"

  create_instance_profile = true

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = "arn:aws:s3:::my-bucket/*"
    }]
  })
}
```

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

### Providers

No providers.

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_attachment"></a> [attachment](#module\_attachment) | git::https://github.com/PlatformStackPulse/tf-atom-iam-role-policy-attachment-aws.git | c6719afbd6067eee7db36aaa5acc581d108bf413 |
| <a name="module_instance_profile"></a> [instance\_profile](#module\_instance\_profile) | git::https://github.com/PlatformStackPulse/tf-atom-iam-instance-profile-aws.git | 9194be06a01e7a064ec24c87956d59cab42719f8 |
| <a name="module_policy"></a> [policy](#module\_policy) | git::https://github.com/PlatformStackPulse/tf-atom-iam-policy-aws.git | 014a418a1640910503e888ee6fa75b0a61a5e656 |
| <a name="module_role"></a> [role](#module\_role) | git::https://github.com/PlatformStackPulse/tf-atom-iam-role-aws.git | c6bc7003dc846b588c7334180f80217a3bad08f1 |
| <a name="module_this"></a> [this](#module\_this) | git::https://github.com/PlatformStackPulse/tf-label.git | v1.0.0 |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assume_role_policy"></a> [assume\_role\_policy](#input\_assume\_role\_policy) | JSON-encoded assume role (trust) policy document | `string` | n/a | yes |
| <a name="input_policy"></a> [policy](#input\_policy) | JSON-encoded IAM permissions policy document | `string` | n/a | yes |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes and tags, which are merged. | <pre>object({<br/>    enabled             = optional(bool, true)<br/>    namespace           = optional(string, null)<br/>    tenant              = optional(string, null)<br/>    environment         = optional(string, null)<br/>    stage               = optional(string, null)<br/>    name                = optional(string, null)<br/>    delimiter           = optional(string, null)<br/>    attributes          = optional(list(string), [])<br/>    tags                = optional(map(string), {})<br/>    label_order         = optional(list(string), null)<br/>    regex_replace_chars = optional(string, null)<br/>    id_length_limit     = optional(number, null)<br/>    label_key_case      = optional(string, null)<br/>    label_value_case    = optional(string, null)<br/>    labels_as_tags      = optional(set(string), null)<br/>    descriptor_formats = optional(map(object({<br/>      format = string<br/>      labels = list(string)<br/>    })), {})<br/>  })</pre> | `{}` | no |
| <a name="input_create_instance_profile"></a> [create\_instance\_profile](#input\_create\_instance\_profile) | Whether to create an EC2 instance profile for this role | `bool` | `false` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>   format = string<br/>   labels = list(string)<br/>}`<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | <pre>map(object({<br/>    format = string<br/>    labels = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources. | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'. | `string` | `null` | no |
| <a name="input_force_detach_policies"></a> [force\_detach\_policies](#input\_force\_detach\_policies) | Whether to force detach policies before destroying the role | `bool` | `false` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` to keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>Note: The value of the `name` tag, if included, will be the `id`, not the `name`. | `set(string)` | `null` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | Maximum session duration in seconds (3600-43200) | `number` | `3600` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique. | `string` | `null` | no |
| <a name="input_policy_description"></a> [policy\_description](#input\_policy\_description) | Description for the IAM policy | `string` | `null` | no |
| <a name="input_policy_path"></a> [policy\_path](#input\_policy\_path) | Path for the IAM policy | `string` | `"/"` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_role_description"></a> [role\_description](#input\_role\_description) | Description for the IAM role | `string` | `null` | no |
| <a name="input_role_path"></a> [role\_path](#input\_role\_path) | Path for the IAM role and instance profile | `string` | `"/"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element. A customer identifier, indicating who this instance of a resource is for. | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Whether the module is enabled |
| <a name="output_instance_profile_arn"></a> [instance\_profile\_arn](#output\_instance\_profile\_arn) | ARN of the instance profile (null if not created) |
| <a name="output_instance_profile_name"></a> [instance\_profile\_name](#output\_instance\_profile\_name) | Name of the instance profile (null if not created) |
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | ARN of the IAM policy |
| <a name="output_policy_name"></a> [policy\_name](#output\_policy\_name) | Name of the IAM policy |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the IAM role |
| <a name="output_role_id"></a> [role\_id](#output\_role\_id) | ID of the IAM role |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the IAM role |
<!-- END_TF_DOCS -->

## Tests

This module ships a `terraform test` suite under `tests/`:

- **Unit tests** (`tests/unit/`) — run against a **mock AWS provider**, so no real
  AWS calls are made and no credentials are required. They assert plan-known values
  (the `enabled` flag and the nullability of the optional instance-profile outputs);
  computed ARNs/IDs are intentionally not asserted because they are unknown under a
  mock provider.
- **Integration tests** (`tests/integration/`) — run against a **real AWS provider**
  and create real (billable) resources. Require valid AWS credentials.

```bash
# Unit tests (mocked, safe, no credentials)
terraform init -backend=false
terraform test -test-directory=tests/unit

# Integration tests (real AWS resources — costs may be incurred)
terraform test -test-directory=tests/integration
```

Both suites are also wired into `make test` and the CI pipeline
(`.github/workflows/ci.yml`).