[![Release][release-image]][release] [![CI][ci-image]][ci] [![License][license-image]][license] [![Registry][registry-image]][registry] [![Source][source-image]][source]

# terraform-azurerm-snowflake-loader-vmss

A Terraform module which deploys the Snowplow Snowflake Loader on an Azure virtual machine.

## Telemetry

This module by default collects and forwards telemetry information to Snowplow to understand how our applications are being used.  No identifying information about your sub-account or account fingerprints are ever forwarded to us - it is very simple information about what modules and applications are deployed and active.

If you wish to subscribe to our mailing list for updates to these modules or security advisories please set the `user_provided_id` variable to include a valid email address which we can reach you at.

### How do I disable it?

To disable telemetry simply set variable `telemetry_enabled = false`.

### What are you collecting?

For details on what information is collected please see this module: https://github.com/snowplow-devops/terraform-snowplow-telemetry

## Usage

```hcl
module "sf_loader_service" {
  source = "snowplow-devops/snowflake-loader-vmss/azurerm"

  accept_limited_use_license = true

  name                = var.name
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  queue_topic_name           = var.queue_event_hub_name
  queue_topic_kafka_password = var.queue_event_hub_read_only_primary_connection_string
  eh_namespace_name          = var.eh_namespace_name
  kafka_brokers              = var.kafka_brokers

  storage_account_name                          = var.storage_account_name
  storage_container_name_for_transformer_output = var.storage_container_name

  snowflake_loader_user = var.snowflake_loader_user
  snowflake_password    = var.snowflake_loader_password
  snowflake_warehouse   = var.snowflake_warehouse
  snowflake_database    = var.snowflake_database
  snowflake_schema      = var.snowflake_schema
  snowflake_region      = var.snowflake_region
  snowflake_account     = var.snowflake_account

  ssh_public_key = var.ssh_public_key
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 2.39.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.58.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 2.39.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.58.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_service"></a> [service](#module\_service) | snowplow-devops/service-vmss/azurerm | 0.1.1 |
| <a name="module_telemetry"></a> [telemetry](#module\_telemetry) | snowplow-devops/telemetry/snowplow | 0.5.0 |

## Resources

| Name | Type |
|------|------|
| [azuread_application.app_registration](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_password.app_password](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_service_principal.sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_eventhub_consumer_group.queue_topic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.egress_tcp_443](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.egress_tcp_80](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.egress_udp_123](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.egress_udp_statsd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.ingress_tcp_22](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_role_assignment.staging_blob_contributor_app_ra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.storage_account_blob_delegator_app_ra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.transformer_output_blob_contributor_app_ra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_storage_account.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |
| [azurerm_storage_container.staging_sc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_container) | data source |
| [azurerm_storage_container.transformer_output_sc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_container) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kafka_brokers"></a> [kafka\_brokers](#input\_kafka\_brokers) | The brokers to configure for access to the Kafka Cluster (note: as default the EventHubs namespace broker) | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | A name which will be pre-pended to the resources created | `string` | n/a | yes |
| <a name="input_queue_topic_kafka_password"></a> [queue\_topic\_kafka\_password](#input\_queue\_topic\_kafka\_password) | Password for connection to Kafka cluster under PlainLoginModule (note: as default the EventHubs topic connection string for reading is expected) | `string` | n/a | yes |
| <a name="input_queue_topic_name"></a> [queue\_topic\_name](#input\_queue\_topic\_name) | The name of the queue Event Hubs topic that the loader will read messages from | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group to deploy the service into | `string` | n/a | yes |
| <a name="input_snowflake_account"></a> [snowflake\_account](#input\_snowflake\_account) | Snowflake account | `string` | n/a | yes |
| <a name="input_snowflake_database"></a> [snowflake\_database](#input\_snowflake\_database) | Snowflake database name | `string` | n/a | yes |
| <a name="input_snowflake_loader_user"></a> [snowflake\_loader\_user](#input\_snowflake\_loader\_user) | Snowflake username used by loader to perform loading | `string` | n/a | yes |
| <a name="input_snowflake_password"></a> [snowflake\_password](#input\_snowflake\_password) | Password for snowflake\_loader\_user used by loader to perform loading | `string` | n/a | yes |
| <a name="input_snowflake_region"></a> [snowflake\_region](#input\_snowflake\_region) | Snowflake region | `string` | n/a | yes |
| <a name="input_snowflake_schema"></a> [snowflake\_schema](#input\_snowflake\_schema) | Snowflake schema name | `string` | n/a | yes |
| <a name="input_snowflake_warehouse"></a> [snowflake\_warehouse](#input\_snowflake\_warehouse) | Snowflake warehouse name | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | The SSH public key attached for access to the servers | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Storage Account name where data to load is stored | `string` | n/a | yes |
| <a name="input_storage_container_name_for_transformer_output"></a> [storage\_container\_name\_for\_transformer\_output](#input\_storage\_container\_name\_for\_transformer\_output) | Storage Container name for transformer output - must be within 'storage\_account\_name' | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet id to deploy the service into | `string` | n/a | yes |
| <a name="input_accept_limited_use_license"></a> [accept\_limited\_use\_license](#input\_accept\_limited\_use\_license) | Acceptance of the SLULA terms (https://docs.snowplow.io/limited-use-license-1.0/) | `bool` | `false` | no |
| <a name="input_app_version"></a> [app\_version](#input\_app\_version) | App version to use. This variable facilitates dev flow, the modules may not work with anything other than the default value. | `string` | `"5.7.5"` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether to assign a public ip address to this instance | `bool` | `true` | no |
| <a name="input_custom_iglu_resolvers"></a> [custom\_iglu\_resolvers](#input\_custom\_iglu\_resolvers) | The custom Iglu Resolvers that will be used by Stream Shredder | <pre>list(object({<br>    name            = string<br>    priority        = number<br>    uri             = string<br>    api_key         = string<br>    vendor_prefixes = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_default_iglu_resolvers"></a> [default\_iglu\_resolvers](#input\_default\_iglu\_resolvers) | The default Iglu Resolvers that will be used by Stream Shredder | <pre>list(object({<br>    name            = string<br>    priority        = number<br>    uri             = string<br>    api_key         = string<br>    vendor_prefixes = list(string)<br>  }))</pre> | <pre>[<br>  {<br>    "api_key": "",<br>    "name": "Iglu Central",<br>    "priority": 10,<br>    "uri": "http://iglucentral.com",<br>    "vendor_prefixes": []<br>  },<br>  {<br>    "api_key": "",<br>    "name": "Iglu Central - Mirror 01",<br>    "priority": 20,<br>    "uri": "http://mirror01.iglucentral.com",<br>    "vendor_prefixes": []<br>  }<br>]</pre> | no |
| <a name="input_eh_namespace_name"></a> [eh\_namespace\_name](#input\_eh\_namespace\_name) | The name of the Event Hubs namespace (note: if you are not using EventHubs leave this blank) | `string` | `""` | no |
| <a name="input_folder_monitoring_enabled"></a> [folder\_monitoring\_enabled](#input\_folder\_monitoring\_enabled) | Whether folder monitoring should be activated or not | `bool` | `false` | no |
| <a name="input_folder_monitoring_period"></a> [folder\_monitoring\_period](#input\_folder\_monitoring\_period) | How often to folder should be checked by folder monitoring | `string` | `"8 hours"` | no |
| <a name="input_folder_monitoring_since"></a> [folder\_monitoring\_since](#input\_folder\_monitoring\_since) | Specifies since when folder monitoring will check | `string` | `"14 days"` | no |
| <a name="input_folder_monitoring_until"></a> [folder\_monitoring\_until](#input\_folder\_monitoring\_until) | Specifies until when folder monitoring will check | `string` | `"6 hours"` | no |
| <a name="input_health_check_enabled"></a> [health\_check\_enabled](#input\_health\_check\_enabled) | Whether health check should be enabled or not | `bool` | `false` | no |
| <a name="input_health_check_freq"></a> [health\_check\_freq](#input\_health\_check\_freq) | Frequency of health check | `string` | `"1 hour"` | no |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | How long to wait for a response for health check query | `string` | `"1 min"` | no |
| <a name="input_java_opts"></a> [java\_opts](#input\_java\_opts) | Custom JAVA Options | `string` | `"-XX:InitialRAMPercentage=75 -XX:MaxRAMPercentage=75"` | no |
| <a name="input_kafka_source"></a> [kafka\_source](#input\_kafka\_source) | The source providing the Kafka connectivity (def: azure\_event\_hubs) | `string` | `"azure_event_hubs"` | no |
| <a name="input_queue_topic_kafka_username"></a> [queue\_topic\_kafka\_username](#input\_queue\_topic\_kafka\_username) | Username for connection to Kafka cluster under PlainLoginModule (default: '$ConnectionString' which is used for EventHubs) | `string` | `"$ConnectionString"` | no |
| <a name="input_retry_period"></a> [retry\_period](#input\_retry\_period) | How often batch of failed folders should be pulled into a discovery queue | `string` | `"10 min"` | no |
| <a name="input_retry_queue_enabled"></a> [retry\_queue\_enabled](#input\_retry\_queue\_enabled) | Whether retry queue should be enabled or not | `bool` | `false` | no |
| <a name="input_retry_queue_interval"></a> [retry\_queue\_interval](#input\_retry\_queue\_interval) | Artificial pause after each failed folder being added to the queue | `string` | `"10 min"` | no |
| <a name="input_retry_queue_max_attempt"></a> [retry\_queue\_max\_attempt](#input\_retry\_queue\_max\_attempt) | How many attempt to make for each folder | `number` | `-1` | no |
| <a name="input_retry_queue_size"></a> [retry\_queue\_size](#input\_retry\_queue\_size) | How many failures should be kept in memory | `number` | `-1` | no |
| <a name="input_sentry_dsn"></a> [sentry\_dsn](#input\_sentry\_dsn) | DSN for Sentry instance | `string` | `""` | no |
| <a name="input_sentry_enabled"></a> [sentry\_enabled](#input\_sentry\_enabled) | Whether Sentry should be enabled or not | `bool` | `false` | no |
| <a name="input_sp_tracking_app_id"></a> [sp\_tracking\_app\_id](#input\_sp\_tracking\_app\_id) | App id for Snowplow tracking | `string` | `""` | no |
| <a name="input_sp_tracking_collector_url"></a> [sp\_tracking\_collector\_url](#input\_sp\_tracking\_collector\_url) | Collector URL for Snowplow tracking | `string` | `""` | no |
| <a name="input_sp_tracking_enabled"></a> [sp\_tracking\_enabled](#input\_sp\_tracking\_enabled) | Whether Snowplow tracking should be activated or not | `bool` | `false` | no |
| <a name="input_ssh_ip_allowlist"></a> [ssh\_ip\_allowlist](#input\_ssh\_ip\_allowlist) | The comma-seperated list of CIDR ranges to allow SSH traffic from | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_statsd_enabled"></a> [statsd\_enabled](#input\_statsd\_enabled) | Whether Statsd should be enabled or not | `bool` | `false` | no |
| <a name="input_statsd_host"></a> [statsd\_host](#input\_statsd\_host) | Hostname of StatsD server | `string` | `""` | no |
| <a name="input_statsd_port"></a> [statsd\_port](#input\_statsd\_port) | Port of StatsD server | `number` | `8125` | no |
| <a name="input_stdout_metrics_enabled"></a> [stdout\_metrics\_enabled](#input\_stdout\_metrics\_enabled) | Whether logging metrics to stdout should be activated or not | `bool` | `false` | no |
| <a name="input_storage_container_name_for_folder_monitoring_staging"></a> [storage\_container\_name\_for\_folder\_monitoring\_staging](#input\_storage\_container\_name\_for\_folder\_monitoring\_staging) | Storage Container name for folder monitoring to stage data - must be within 'storage\_account\_name' (NOTE: must be set if 'folder\_monitoring\_enabled' is true) | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to append to this resource | `map(string)` | `{}` | no |
| <a name="input_telemetry_enabled"></a> [telemetry\_enabled](#input\_telemetry\_enabled) | Whether or not to send telemetry information back to Snowplow Analytics Ltd | `bool` | `true` | no |
| <a name="input_user_provided_id"></a> [user\_provided\_id](#input\_user\_provided\_id) | An optional unique identifier to identify the telemetry events emitted by this stack | `string` | `""` | no |
| <a name="input_vm_sku"></a> [vm\_sku](#input\_vm\_sku) | The instance type to use | `string` | `"Standard_B2s"` | no |
| <a name="input_webhook_collector"></a> [webhook\_collector](#input\_webhook\_collector) | URL of webhook collector | `string` | `""` | no |
| <a name="input_webhook_enabled"></a> [webhook\_enabled](#input\_webhook\_enabled) | Whether webhook should be enabled or not | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nsg_id"></a> [nsg\_id](#output\_nsg\_id) | ID of the network security group attached to the Loader Server nodes |
| <a name="output_vmss_id"></a> [vmss\_id](#output\_vmss\_id) | ID of the VM scale-set |

# Copyright and license

Copyright 2023-present Snowplow Analytics Ltd.

Licensed under the [Snowplow Limited Use License Agreement][license]. _(If you are uncertain how it applies to your use case, check our answers to [frequently asked questions][license-faq].)_

[release]: https://github.com/snowplow-devops/terraform-azurerm-snowflake-loader-vmss/releases/latest
[release-image]: https://img.shields.io/github/v/release/snowplow-devops/terraform-azurerm-snowflake-loader-vmss

[ci]: https://github.com/snowplow-devops/terraform-azurerm-snowflake-loader-vmss/actions?query=workflow%3Aci
[ci-image]: https://github.com/snowplow-devops/terraform-azurerm-snowflake-loader-vmss/workflows/ci/badge.svg

[license]: https://docs.snowplow.io/limited-use-license-1.0/
[license-image]: https://img.shields.io/badge/license-Snowplow--Limited--Use-blue.svg?style=flat
[license-faq]: https://docs.snowplow.io/docs/contributing/limited-use-license-faq/

[registry]: https://registry.terraform.io/modules/snowplow-devops/snowflake-loader-vmss/azurerm/latest
[registry-image]: https://img.shields.io/static/v1?label=Terraform&message=Registry&color=7B42BC&logo=terraform

[source]: https://github.com/snowplow/snowplow-rdb-loader
[source-image]: https://img.shields.io/static/v1?label=Snowplow&message=Snowflake%20Loader&color=0E9BA4&logo=GitHub
