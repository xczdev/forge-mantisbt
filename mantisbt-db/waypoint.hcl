project = "forge/mantisbt-db"

labels = { "domaine" = "forge" }

# https://developer.hashicorp.com/waypoint/docs/waypoint-hcl/runner
runner {
  enabled = true
  profile = "common-odr"
  data_source "git" {
    url                         = "https://github.com/ansforge/forge-mantisbt.git"
    ref                         = "var.datacenter"
    path                        = "mantisbt-db"
    ignore_changes_outside_path = true
  }
  poll {
    # à mettre à true pour déployer automatiquement en cas de changement dans la branche
    enabled  = true
    interval = "60s"
  }
}

############## APPs ##############

# --- MariaDB ---

app "forge-mantisbt-db" {
  build {
    use "docker-pull" {
      image = var.database_image
      tag   = var.database_tag
    }
  }
  deploy {
    use "nomad-jobspec" {
      jobspec = templatefile("${path.app}/forge-mantisbt-mariadb.nomad.tpl", {
        datacenter                = var.datacenter
        vault_secrets_engine_name = var.vault_secrets_engine_name
        vault_acl_policy_name     = var.vault_acl_policy_name

        nomad_namespace = var.nomad_namespace
        image           = var.database_image
        tag             = var.database_tag

        log_shipper_image = var.log_shipper_image
        log_shipper_tag   = var.log_shipper_tag
      })
    }
  }
}

############## variables ##############

# --- variable common ---

# Convention :
# [NOM-WORKSPACE] = [waypoint projet name] = [nomad namespace name] = [Vault ACL Policies Name] = [Valut Secrets Engine Name]

variable "datacenter" {
  type    = string
  default = "henix_docker_platform_dev"
  env     = ["NOMAD_DC"]
}

# ${workspace.name} : waypoint workspace name

variable "nomad_namespace" {
  type    = string
  default = "${workspace.name}"
}

variable "vault_acl_policy_name" {
  type    = string
  default = "forge"
}

variable "vault_secrets_engine_name" {
  type    = string
  default = "forge/mantisbt"
}

# --- MariaDB ---

variable "database_image" {
  type    = string
  default = "mariadb"
}

variable "database_tag" {
  type    = string
  default = "10.4"
}

# --- log-shipper ---
variable "log_shipper_image" {
  type    = string
  default = "ans/nomad-filebeat"
}

variable "log_shipper_tag" {
  type    = string
  default = "8.2.3-2.0"
}