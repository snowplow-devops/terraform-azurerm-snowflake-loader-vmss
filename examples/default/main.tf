locals {
  name                 = "snowflake-loader-test"
  storage_account_name = "sfloadertestsa"

  app_version = "5.7.5"

  window_period_min = 1

  snowflake_loader_user     = "USER"
  snowflake_loader_password = "PASSWORD"
  snowflake_warehouse       = "WAREHOUSE"
  snowflake_database        = "DATABASE"
  snowflake_schema          = "atomic"
  snowflake_region          = "REGION"
  snowflake_account         = "ACCOUNT"

  ssh_public_key = "PUBLIC_KEY"

  user_provided_id = "snowflake-loader-module-example@snowplow.io"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.name}-rg"
  location = "North Europe"
}

module "eh_namespace" {
  source  = "snowplow-devops/event-hub-namespace/azurerm"
  version = "0.1.1"

  name                = "${local.name}-ehn"
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [azurerm_resource_group.rg]
}

module "enriched_event_hub" {
  source  = "snowplow-devops/event-hub/azurerm"
  version = "0.1.1"

  name                = "${local.name}-enriched-topic"
  namespace_name      = module.eh_namespace.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 1
}

module "queue_event_hub" {
  source  = "snowplow-devops/event-hub/azurerm"
  version = "0.1.1"

  name                = "${local.name}-queue-topic"
  namespace_name      = module.eh_namespace.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 1
}

module "storage_account" {
  source  = "snowplow-devops/storage-account/azurerm"
  version = "0.1.2"

  name                = local.storage_account_name
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [azurerm_resource_group.rg]
}

module "storage_container" {
  source  = "snowplow-devops/storage-container/azurerm"
  version = "0.1.1"

  name                 = "${local.name}-container"
  storage_account_name = module.storage_account.name
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }
}

module "transformer" {
  source  = "snowplow-devops/transformer-event-hub-vmss/azurerm"
  version = "0.3.0"

  accept_limited_use_license = true

  name                = "${local.name}-transformer"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = tolist(azurerm_virtual_network.vnet.subnet)[0].id

  app_version = local.app_version

  enriched_topic_name           = module.enriched_event_hub.name
  enriched_topic_kafka_password = module.enriched_event_hub.read_only_primary_connection_string
  queue_topic_name              = module.queue_event_hub.name
  queue_topic_kafka_password    = module.queue_event_hub.read_write_primary_connection_string
  eh_namespace_name             = module.eh_namespace.name
  kafka_brokers                 = module.eh_namespace.broker

  storage_account_name   = module.storage_account.name
  storage_container_name = module.storage_container.name
  window_period_min      = local.window_period_min

  widerow_file_format = "json"

  ssh_public_key = local.ssh_public_key

  user_provided_id = local.user_provided_id

  depends_on = [azurerm_resource_group.rg, module.storage_container, module.storage_account]
}

module "sf_loader" {
  source = "../.."

  accept_limited_use_license = true

  name                = "${local.name}-snowflake-loader"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = tolist(azurerm_virtual_network.vnet.subnet)[0].id

  app_version = local.app_version

  queue_topic_name           = module.queue_event_hub.name
  queue_topic_kafka_password = module.queue_event_hub.read_only_primary_connection_string
  eh_namespace_name          = module.eh_namespace.name
  kafka_brokers              = module.eh_namespace.broker

  storage_account_name                          = module.storage_account.name
  storage_container_name_for_transformer_output = module.storage_container.name

  snowflake_loader_user = local.snowflake_loader_user
  snowflake_password    = local.snowflake_loader_password
  snowflake_warehouse   = local.snowflake_warehouse
  snowflake_database    = local.snowflake_database
  snowflake_schema      = local.snowflake_schema
  snowflake_region      = local.snowflake_region
  snowflake_account     = local.snowflake_account

  ssh_public_key = local.ssh_public_key

  user_provided_id = local.user_provided_id

  depends_on = [module.storage_container]
}
