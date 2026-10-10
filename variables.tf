variable "eks_node_groups" {
  description = <<EOT
Map of eks_node_groups, attributes below
Required:
    - cluster_name
    - node_role_arn
    - subnet_ids
    - scaling_config (block):
        - desired_size (required)
        - max_size (required)
        - min_size (required)
Optional:
    - ami_type
    - capacity_type
    - disk_size
    - force_update_version
    - instance_types
    - labels
    - node_group_name
    - node_group_name_prefix
    - region
    - release_version
    - tags
    - tags_all
    - version
    - launch_template (block):
        - id (optional)
        - name (optional)
        - version (required)
    - node_repair_config (block):
        - enabled (optional)
        - max_parallel_nodes_repaired_count (optional)
        - max_parallel_nodes_repaired_percentage (optional)
        - max_unhealthy_node_threshold_count (optional)
        - max_unhealthy_node_threshold_percentage (optional)
        - node_repair_config_overrides (optional, block):
            - min_repair_wait_time_mins (required)
            - node_monitoring_condition (required)
            - node_unhealthy_reason (required)
            - repair_action (required)
    - remote_access (block):
        - ec2_ssh_key (optional)
        - source_security_group_ids (optional)
    - taint (block):
        - effect (required)
        - key (required)
        - value (optional)
    - update_config (block):
        - max_unavailable (optional)
        - max_unavailable_percentage (optional)
        - update_strategy (optional)
    - warm_pool_config (block):
        - max_group_prepared_capacity (optional)
        - min_size (optional)
        - pool_state (optional)
        - reuse_on_scale_in (optional)
EOT

  type = map(object({
    cluster_name           = string
    node_role_arn          = string
    subnet_ids             = set(string)
    ami_type               = optional(string)
    capacity_type          = optional(string)
    disk_size              = optional(number)
    force_update_version   = optional(bool)
    instance_types         = optional(list(string))
    labels                 = optional(map(string))
    node_group_name        = optional(string)
    node_group_name_prefix = optional(string)
    region                 = optional(string)
    release_version        = optional(string)
    tags                   = optional(map(string))
    tags_all               = optional(map(string))
    version                = optional(string)
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
    launch_template = optional(object({
      id      = optional(string)
      name    = optional(string)
      version = string
    }))
    node_repair_config = optional(object({
      enabled                                 = optional(bool)
      max_parallel_nodes_repaired_count       = optional(number)
      max_parallel_nodes_repaired_percentage  = optional(number)
      max_unhealthy_node_threshold_count      = optional(number)
      max_unhealthy_node_threshold_percentage = optional(number)
      node_repair_config_overrides = optional(list(object({
        min_repair_wait_time_mins = number
        node_monitoring_condition = string
        node_unhealthy_reason     = string
        repair_action             = string
      })))
    }))
    remote_access = optional(object({
      ec2_ssh_key               = optional(string)
      source_security_group_ids = optional(set(string))
    }))
    taint = optional(list(object({
      effect = string
      key    = string
      value  = optional(string)
    })))
    update_config = optional(object({
      max_unavailable            = optional(number)
      max_unavailable_percentage = optional(number)
      update_strategy            = optional(string)
    }))
    warm_pool_config = optional(object({
      max_group_prepared_capacity = optional(number)
      min_size                    = optional(number)
      pool_state                  = optional(string)
      reuse_on_scale_in           = optional(bool)
    }))
  }))
  validation {
    condition = alltrue([
      for k, v in var.eks_node_groups : (
        v.taint == null || (length(v.taint) <= 50)
      )
    ])
    error_message = "Each taint list must contain at most 50 items"
  }
  validation {
    condition = alltrue([
      for k, v in var.eks_node_groups : (
        v.node_group_name == null || (length(v.node_group_name) >= 0 && length(v.node_group_name) <= 63)
      )
    ])
    error_message = "must be between 0 and 63 characters"
  }
  validation {
    condition = alltrue([
      for k, v in var.eks_node_groups : (
        v.node_repair_config == null || (v.node_repair_config.max_parallel_nodes_repaired_count == null || (v.node_repair_config.max_parallel_nodes_repaired_count >= 1))
      )
    ])
    error_message = "must be at least 1"
  }
  validation {
    condition = alltrue([
      for k, v in var.eks_node_groups : (
        v.node_repair_config == null || (v.node_repair_config.max_parallel_nodes_repaired_percentage == null || (v.node_repair_config.max_parallel_nodes_repaired_percentage >= 1 && v.node_repair_config.max_parallel_nodes_repaired_percentage <= 100))
      )
    ])
    error_message = "must be between 1 and 100"
  }
  validation {
    condition = alltrue([
      for k, v in var.eks_node_groups : (
        v.node_repair_config == null || (v.node_repair_config.max_unhealthy_node_threshold_count == null || (v.node_repair_config.max_unhealthy_node_threshold_count >= 1))
      )
    ])
    error_message = "must be at least 1"
  }
  validation {
    condition = alltrue([
      for k, v in var.eks_node_groups : (
        v.node_repair_config == null || (v.node_repair_config.max_unhealthy_node_threshold_percentage == null || (v.node_repair_config.max_unhealthy_node_threshold_percentage >= 1 && v.node_repair_config.max_unhealthy_node_threshold_percentage <= 100))
      )
    ])
    error_message = "must be between 1 and 100"
  }
  validation {
    condition = alltrue([
      for k, v in var.eks_node_groups : (
        v.node_repair_config == null || (v.node_repair_config.node_repair_config_overrides == null || alltrue([for item in v.node_repair_config.node_repair_config_overrides : (item.min_repair_wait_time_mins >= 1)]))
      )
    ])
    error_message = "must be at least 1"
  }
  validation {
    condition = alltrue([
      for k, v in var.eks_node_groups : (
        v.scaling_config.desired_size >= 0
      )
    ])
    error_message = "must be at least 0"
  }
  validation {
    condition = alltrue([
      for k, v in var.eks_node_groups : (
        v.scaling_config.max_size >= 1
      )
    ])
    error_message = "must be at least 1"
  }
  validation {
    condition = alltrue([
      for k, v in var.eks_node_groups : (
        v.scaling_config.min_size >= 0
      )
    ])
    error_message = "must be at least 0"
  }
  validation {
    condition = alltrue([
      for k, v in var.eks_node_groups : (
        v.update_config == null || (v.update_config.max_unavailable == null || (v.update_config.max_unavailable >= 1 && v.update_config.max_unavailable <= 100))
      )
    ])
    error_message = "must be between 1 and 100"
  }
  validation {
    condition = alltrue([
      for k, v in var.eks_node_groups : (
        v.update_config == null || (v.update_config.max_unavailable_percentage == null || (v.update_config.max_unavailable_percentage >= 1 && v.update_config.max_unavailable_percentage <= 100))
      )
    ])
    error_message = "must be between 1 and 100"
  }
  validation {
    condition = alltrue([
      for k, v in var.eks_node_groups : (
        v.warm_pool_config == null || (v.warm_pool_config.max_group_prepared_capacity == null || (v.warm_pool_config.max_group_prepared_capacity >= -1))
      )
    ])
    error_message = "must be at least -1"
  }
  validation {
    condition = alltrue([
      for k, v in var.eks_node_groups : (
        v.warm_pool_config == null || (v.warm_pool_config.min_size == null || (v.warm_pool_config.min_size >= 0))
      )
    ])
    error_message = "must be at least 0"
  }
  # Note: 20 additional provider-side validators are enforced at apply time but not mirrored as validation{} blocks here (bespoke or non-mechanically-translatable).
}

