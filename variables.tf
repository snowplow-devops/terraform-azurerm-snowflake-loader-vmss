variable "accept_limited_use_license" {
  description = "Acceptance of the SLULA terms (https://docs.snowplow.io/limited-use-license-1.0/)"
  type        = bool
  default     = false

  validation {
    condition     = var.accept_limited_use_license
    error_message = "Please accept the terms of the Snowplow Limited Use License Agreement to proceed."
  }
}

variable "name" {
  description = "A name which will be pre-pended to the resources created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy the service into"
  type        = string
}

variable "app_version" {
  description = "App version to use. This variable facilitates dev flow, the modules may not work with anything other than the default value."
  type        = string
  default     = "5.7.1"
}

variable "subnet_id" {
  description = "The subnet id to deploy the service into"
  type        = string
}

variable "vm_sku" {
  description = "The instance type to use"
  type        = string
  default     = "Standard_B2s"
}

variable "associate_public_ip_address" {
  description = "Whether to assign a public ip address to this instance"
  type        = bool
  default     = true
}

variable "ssh_public_key" {
  description = "The SSH public key attached for access to the servers"
  type        = string
}

variable "ssh_ip_allowlist" {
  description = "The comma-seperated list of CIDR ranges to allow SSH traffic from"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "The tags to append to this resource"
  default     = {}
  type        = map(string)
}

variable "java_opts" {
  description = "Custom JAVA Options"
  default     = "-XX:InitialRAMPercentage=75 -XX:MaxRAMPercentage=75"
  type        = string
}

# --- Configuration options

variable "queue_topic_name" {
  description = "The name of the queue Event Hubs topic that the loader will read messages from"
  type        = string
}

variable "queue_topic_kafka_username" {
  description = "Username for connection to Kafka cluster under PlainLoginModule (default: '$ConnectionString' which is used for EventHubs)"
  type        = string
  default     = "$ConnectionString"
}

variable "queue_topic_kafka_password" {
  description = "Password for connection to Kafka cluster under PlainLoginModule (note: as default the EventHubs topic connection string for reading is expected)"
  type        = string
}

variable "eh_namespace_name" {
  description = "The name of the Event Hubs namespace (note: if you are not using EventHubs leave this blank)"
  type        = string
  default     = ""
}

variable "kafka_brokers" {
  description = "The brokers to configure for access to the Kafka Cluster (note: as default the EventHubs namespace broker)"
  type        = string
}

variable "storage_account_name" {
  description = "Storage Account name where data to load is stored"
  type        = string
}

variable "storage_container_name_for_transformer_output" {
  description = "Storage Container name for transformer output - must be within 'storage_account_name'"
  type        = string
}

variable "storage_container_name_for_folder_monitoring_staging" {
  description = "Storage Container name for folder monitoring to stage data - must be within 'storage_account_name' (NOTE: must be set if 'folder_monitoring_enabled' is true)"
  type        = string
  default     = ""
}

variable "folder_monitoring_enabled" {
  description = "Whether folder monitoring should be activated or not"
  default     = false
  type        = bool
}

variable "sp_tracking_enabled" {
  description = "Whether Snowplow tracking should be activated or not"
  default     = false
  type        = bool
}

variable "sp_tracking_app_id" {
  description = "App id for Snowplow tracking"
  default     = ""
  type        = string
}

variable "sp_tracking_collector_url" {
  description = "Collector URL for Snowplow tracking"
  default     = ""
  type        = string
}

variable "sentry_enabled" {
  description = "Whether Sentry should be enabled or not"
  default     = false
  type        = bool
}

variable "sentry_dsn" {
  description = "DSN for Sentry instance"
  default     = ""
  type        = string
  sensitive   = true
}

variable "statsd_enabled" {
  description = "Whether Statsd should be enabled or not"
  default     = false
  type        = bool
}

variable "statsd_host" {
  description = "Hostname of StatsD server"
  default     = ""
  type        = string
}

variable "statsd_port" {
  description = "Port of StatsD server"
  default     = 8125
  type        = number
}

variable "stdout_metrics_enabled" {
  description = "Whether logging metrics to stdout should be activated or not"
  default     = false
  type        = bool
}

variable "webhook_enabled" {
  description = "Whether webhook should be enabled or not"
  default     = false
  type        = bool
}

variable "webhook_collector" {
  description = "URL of webhook collector"
  default     = ""
  type        = string
}

variable "folder_monitoring_period" {
  description = "How often to folder should be checked by folder monitoring"
  default     = "8 hours"
  type        = string

  validation {
    condition     = can(regex("\\d+ (ns|nano|nanos|nanosecond|nanoseconds|us|micro|micros|microsecond|microseconds|ms|milli|millis|millisecond|milliseconds|s|second|seconds|m|minute|minutes|h|hour|hours|d|day|days)", var.folder_monitoring_period))
    error_message = "Invalid period formant."
  }
}

variable "folder_monitoring_since" {
  description = "Specifies since when folder monitoring will check"
  default     = "14 days"
  type        = string

  validation {
    condition     = can(regex("\\d+ (ns|nano|nanos|nanosecond|nanoseconds|us|micro|micros|microsecond|microseconds|ms|milli|millis|millisecond|milliseconds|s|second|seconds|m|minute|minutes|h|hour|hours|d|day|days)", var.folder_monitoring_since))
    error_message = "Invalid period formant."
  }
}

variable "folder_monitoring_until" {
  description = "Specifies until when folder monitoring will check"
  default     = "6 hours"
  type        = string

  validation {
    condition     = can(regex("\\d+ (ns|nano|nanos|nanosecond|nanoseconds|us|micro|micros|microsecond|microseconds|ms|milli|millis|millisecond|milliseconds|s|second|seconds|m|minute|minutes|h|hour|hours|d|day|days)", var.folder_monitoring_until))
    error_message = "Invalid period formant."
  }
}

variable "health_check_enabled" {
  description = "Whether health check should be enabled or not"
  default     = false
  type        = bool
}

variable "health_check_freq" {
  description = "Frequency of health check"
  default     = "1 hour"
  type        = string

  validation {
    condition     = can(regex("\\d+ (ns|nano|nanos|nanosecond|nanoseconds|us|micro|micros|microsecond|microseconds|ms|milli|millis|millisecond|milliseconds|s|second|seconds|m|minute|minutes|h|hour|hours|d|day|days)", var.health_check_freq))
    error_message = "Invalid period formant."
  }
}

variable "health_check_timeout" {
  description = "How long to wait for a response for health check query"
  default     = "1 min"
  type        = string

  validation {
    condition     = can(regex("\\d+ (ns|nano|nanos|nanosecond|nanoseconds|us|micro|micros|microsecond|microseconds|ms|milli|millis|millisecond|milliseconds|s|second|seconds|m|minute|minutes|h|hour|hours|d|day|days)", var.health_check_timeout))
    error_message = "Invalid period formant."
  }
}

variable "retry_queue_enabled" {
  description = "Whether retry queue should be enabled or not"
  default     = false
  type        = bool
}

variable "retry_period" {
  description = "How often batch of failed folders should be pulled into a discovery queue"
  default     = "10 min"
  type        = string

  validation {
    condition     = can(regex("\\d+ (ns|nano|nanos|nanosecond|nanoseconds|us|micro|micros|microsecond|microseconds|ms|milli|millis|millisecond|milliseconds|s|second|seconds|m|minute|minutes|h|hour|hours|d|day|days)", var.retry_period))
    error_message = "Invalid period formant."
  }
}

variable "retry_queue_size" {
  description = "How many failures should be kept in memory"
  default     = -1
  type        = number
}

variable "retry_queue_max_attempt" {
  description = "How many attempt to make for each folder"
  default     = -1
  type        = number
}

variable "retry_queue_interval" {
  description = "Artificial pause after each failed folder being added to the queue"
  default     = "10 min"
  type        = string

  validation {
    condition     = can(regex("\\d+ (ns|nano|nanos|nanosecond|nanoseconds|us|micro|micros|microsecond|microseconds|ms|milli|millis|millisecond|milliseconds|s|second|seconds|m|minute|minutes|h|hour|hours|d|day|days)", var.retry_queue_interval))
    error_message = "Invalid period formant."
  }
}

# --- Iglu Resolver

variable "default_iglu_resolvers" {
  description = "The default Iglu Resolvers that will be used by Stream Shredder"
  default = [
    {
      name            = "Iglu Central"
      priority        = 10
      uri             = "http://iglucentral.com"
      api_key         = ""
      vendor_prefixes = []
    },
    {
      name            = "Iglu Central - Mirror 01"
      priority        = 20
      uri             = "http://mirror01.iglucentral.com"
      api_key         = ""
      vendor_prefixes = []
    }
  ]
  type = list(object({
    name            = string
    priority        = number
    uri             = string
    api_key         = string
    vendor_prefixes = list(string)
  }))
}

variable "custom_iglu_resolvers" {
  description = "The custom Iglu Resolvers that will be used by Stream Shredder"
  default     = []
  type = list(object({
    name            = string
    priority        = number
    uri             = string
    api_key         = string
    vendor_prefixes = list(string)
  }))
}

# --- Telemetry

variable "kafka_source" {
  description = "The source providing the Kafka connectivity (def: azure_event_hubs)"
  default     = "azure_event_hubs"
  type        = string
}

variable "telemetry_enabled" {
  description = "Whether or not to send telemetry information back to Snowplow Analytics Ltd"
  type        = bool
  default     = true
}

variable "user_provided_id" {
  description = "An optional unique identifier to identify the telemetry events emitted by this stack"
  type        = string
  default     = ""
}

# --- Snowflake parameters

variable "snowflake_loader_user" {
  description = "Snowflake username used by loader to perform loading"
  type        = string
}

variable "snowflake_password" {
  description = "Password for snowflake_loader_user used by loader to perform loading"
  type        = string
  sensitive   = true
}

variable "snowflake_warehouse" {
  description = "Snowflake warehouse name"
  type        = string
}

variable "snowflake_database" {
  description = "Snowflake database name"
  type        = string
}

variable "snowflake_schema" {
  description = "Snowflake schema name"
  type        = string
}

variable "snowflake_region" {
  description = "Snowflake region"
  type        = string
}

variable "snowflake_account" {
  description = "Snowflake account"
  type        = string
}
