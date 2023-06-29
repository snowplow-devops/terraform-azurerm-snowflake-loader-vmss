locals {
  module_name    = "snowflake-loader-vmss"
  module_version = "0.1.0"

  app_name = "rdb-loader-snowflake"
  # TODO: Change once 5.7.0 is published
  app_version = "5.7.0-rc3"

  local_tags = {
    Name           = var.name
    app_name       = local.app_name
    app_version    = local.app_version
    module_name    = local.module_name
    module_version = local.module_version
  }

  tags = merge(
    var.tags,
    local.local_tags
  )
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

module "telemetry" {
  source  = "snowplow-devops/telemetry/snowplow"
  version = "0.5.0"

  count = var.telemetry_enabled ? 1 : 0

  user_provided_id = var.user_provided_id
  cloud            = "AZURE"
  region           = data.azurerm_resource_group.rg.location
  app_name         = local.app_name
  app_version      = local.app_version
  module_name      = local.module_name
  module_version   = local.module_version
}

# --- Network: Security Group Rules

resource "azurerm_network_security_group" "nsg" {
  name                = var.name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = var.resource_group_name

  tags = local.tags
}

resource "azurerm_network_security_rule" "ingress_tcp_22" {
  name                        = "${var.name}_ingress_tcp_22"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.ssh_ip_allowlist
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "egress_tcp_80" {
  name                        = "${var.name}_egress_tcp_80"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "egress_tcp_443" {
  name                        = "${var.name}_egress_tcp_443"
  priority                    = 101
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Needed for clock synchronization
resource "azurerm_network_security_rule" "egress_udp_123" {
  name                        = "${var.name}_egress_udp_123"
  priority                    = 102
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "123"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Needed for statsd
resource "azurerm_network_security_rule" "egress_udp_statsd" {
  name                        = "${var.name}_egress_udp_statsd"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = var.statsd_port
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# --- IAM: Authentication & Credentials

# Lookup current user
data "azuread_client_config" "current" {}

resource "azuread_application" "app_registration" {
  display_name = "${var.name}-app-registration"
  # Assign current user as owner, otherwise we won't be able to modify or delete after creation (Active directory admins can also modify)
  owners = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_password" "app_password" {
  application_object_id = azuread_application.app_registration.object_id
}

resource "azuread_service_principal" "sp" {
  application_id = azuread_application.app_registration.application_id
  use_existing   = true
}

# Required to allow the loader to generate SAS tokens
data "azurerm_storage_account" "storage_account" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "storage_account_blob_delegator_app_ra" {
  scope                = data.azurerm_storage_account.storage_account.id
  role_definition_name = "Storage Blob Delegator"
  principal_id         = azuread_service_principal.sp.object_id
}

# Required to allow the loader to access the transformed output
data "azurerm_storage_container" "transformer_output_sc" {
  name                 = var.storage_container_name_for_transformer_output
  storage_account_name = var.storage_account_name
}

resource "azurerm_role_assignment" "transformer_output_blob_contributor_app_ra" {
  scope                = data.azurerm_storage_container.transformer_output_sc.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.sp.object_id
}

# Required to allow the loader to perform folder monitoring activities and stage data
data "azurerm_storage_container" "staging_sc" {
  count = var.folder_monitoring_enabled ? 1 : 0

  name                 = var.storage_container_name_for_folder_monitoring_staging
  storage_account_name = var.storage_account_name
}

resource "azurerm_role_assignment" "staging_blob_contributor_app_ra" {
  count = var.folder_monitoring_enabled ? 1 : 0

  scope                = join("", data.azurerm_storage_container.staging_sc.*.resource_manager_id)
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.sp.object_id
}

# --- EventHubs: Consumer Groups

resource "azurerm_eventhub_consumer_group" "queue_topic" {
  name = var.name

  namespace_name      = var.eh_namespace_name
  eventhub_name       = var.queue_topic_name
  resource_group_name = var.resource_group_name
}

# --- Compute: VM scale-set deployment

locals {
  resolvers_raw = concat(var.default_iglu_resolvers, var.custom_iglu_resolvers)

  resolvers_public = [
    for resolver in local.resolvers_raw : merge(
      {
        name           = resolver["name"],
        priority       = resolver["priority"],
        vendorPrefixes = resolver["vendor_prefixes"],
        connection = {
          http = {
            uri = resolver["uri"]
          }
        }
      }
    ) if resolver["api_key"] == ""
  ]

  resolvers_private = [
    for resolver in local.resolvers_raw : merge(
      {
        name           = resolver["name"],
        priority       = resolver["priority"],
        vendorPrefixes = resolver["vendor_prefixes"],
        connection = {
          http = {
            uri    = resolver["uri"]
            apikey = resolver["api_key"]
          }
        }
      }
    ) if resolver["api_key"] != ""
  ]

  resolvers = flatten([
    local.resolvers_public,
    local.resolvers_private
  ])

  iglu_config = templatefile("${path.module}/templates/iglu_config.json.tmpl", { resolvers = jsonencode(local.resolvers) })

  config = templatefile("${path.module}/templates/config.hocon.tmpl", {
    storage_account_name                          = var.storage_account_name
    storage_container_name_for_transformer_output = var.storage_container_name_for_transformer_output

    queue_topic_name              = var.queue_topic_name
    queue_topic_connection_string = var.queue_topic_connection_string
    queue_group_id                = azurerm_eventhub_consumer_group.queue_topic.name

    eh_namespace_broker = var.eh_namespace_broker

    sf_username               = var.snowflake_loader_user
    sf_password               = var.snowflake_password
    sf_region                 = var.snowflake_region
    sf_account                = var.snowflake_account
    sf_wh_name                = var.snowflake_warehouse
    sf_db_name                = var.snowflake_database
    sf_schema                 = var.snowflake_schema
    sp_tracking_enabled       = var.sp_tracking_enabled
    sp_tracking_app_id        = var.sp_tracking_app_id
    sp_tracking_collector_url = var.sp_tracking_collector_url
    sentry_enabled            = var.sentry_enabled
    sentry_dsn                = var.sentry_dsn
    statsd_enabled            = var.statsd_enabled
    statsd_host               = var.statsd_host
    statsd_port               = var.statsd_port
    stdout_metrics_enabled    = var.stdout_metrics_enabled
    webhook_enabled           = var.webhook_enabled
    webhook_collector         = var.webhook_collector
    folder_monitoring_enabled = var.folder_monitoring_enabled
    folder_monitoring_staging = var.storage_container_name_for_folder_monitoring_staging
    folder_monitoring_period  = var.folder_monitoring_period
    folder_monitoring_since   = var.folder_monitoring_since
    folder_monitoring_until   = var.folder_monitoring_until
    health_check_enabled      = var.health_check_enabled
    health_check_freq         = var.health_check_freq
    health_check_timeout      = var.health_check_timeout
    retry_queue_enabled       = var.retry_queue_enabled
    retry_period              = var.retry_period
    retry_queue_size          = var.retry_queue_size
    retry_queue_max_attempt   = var.retry_queue_max_attempt
    retry_queue_interval      = var.retry_queue_interval

    telemetry_disable          = !var.telemetry_enabled
    telemetry_collector_uri    = join("", module.telemetry.*.collector_uri)
    telemetry_collector_port   = 443
    telemetry_secure           = true
    telemetry_user_provided_id = var.user_provided_id
    telemetry_auto_gen_id      = join("", module.telemetry.*.auto_generated_id)
    telemetry_module_name      = local.module_name
    telemetry_module_version   = local.module_version
  })

  user_data = templatefile("${path.module}/templates/user-data.sh.tmpl", {
    tenant_id     = azuread_service_principal.sp.application_tenant_id
    client_id     = azuread_application.app_registration.application_id
    client_secret = azuread_application_password.app_password.value

    config_b64      = base64encode(local.config)
    iglu_config_b64 = base64encode(local.iglu_config)
    version         = local.app_version

    telemetry_script = join("", module.telemetry.*.azurerm_ubuntu_22_04_user_data)

    java_opts = var.java_opts
  })
}

module "service" {
  source  = "snowplow-devops/service-vmss/azurerm"
  version = "0.1.0"

  user_supplied_script = local.user_data
  name                 = var.name
  resource_group_name  = var.resource_group_name

  subnet_id                   = var.subnet_id
  network_security_group_id   = azurerm_network_security_group.nsg.id
  associate_public_ip_address = var.associate_public_ip_address
  admin_ssh_public_key        = var.ssh_public_key

  sku            = var.vm_sku
  instance_count = 1

  tags = local.tags
}
