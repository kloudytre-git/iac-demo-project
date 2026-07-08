## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_ssm_parameter.db_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.db_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.db_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_password.db](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Storage in GB (free tier allows up to 20) | `number` | `20` | no |
| <a name="input_database_security_group_id"></a> [database\_security\_group\_id](#input\_database\_security\_group\_id) | Security group ID for the database (from the security module) | `string` | n/a | yes |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Name of the initial database | `string` | `"appdb"` | no |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | Database port (5432 = Postgres) | `number` | `5432` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Master username | `string` | `"appadmin"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | PostgreSQL major version | `string` | `"16"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g. dev, staging) | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | RDS instance class | `string` | `"db.t3.micro"` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnet IDs the database is allowed to live in | `list(string)` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name, used for naming and tagging | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_address"></a> [db\_address](#output\_db\_address) | Database hostname |
| <a name="output_db_endpoint"></a> [db\_endpoint](#output\_db\_endpoint) | Connection endpoint (host:port) |
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | Initial database name |
| <a name="output_db_password_ssm_parameter"></a> [db\_password\_ssm\_parameter](#output\_db\_password\_ssm\_parameter) | SSM parameter name where the password is stored |
