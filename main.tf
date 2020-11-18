provider "ibm" {
  ibmcloud_api_key = "${var.ibm_api_key}"
}

data ibm_resource_group group {
  name = "ITGP_DATA"
}
# name of VPC

resource "ibm_container_cluster" "cluster1_demo" {
  name            = "cluster1_demo"
  gateway_enabled = true 
  datacenter      = "fra02"
  machine_type    = "u2c.2x4"
  hardware        = "shared"
  default_pool_size = 1
  worker_num=1
  resource_group_id = "${data.ibm_resource_group.group.id}"
  public_vlan_id  = "2347339"
  private_vlan_id = "2347341"
  private_service_endpoint = true
}
##############################################################################
# Cluster Data
##############################################################################

data ibm_container_cluster_config cluster {
  cluster_name_id   = ibm_container_cluster.cluster1_demo.id
  resource_group_id = data.ibm_resource_group.group.id
  admin             = true
}

##############################################################################


##############################################################################
# Kubernetes Provider
##############################################################################

provider kubernetes {
  load_config_file       = false
  host                   = data.ibm_container_cluster_config.cluster.host
  client_certificate     = data.ibm_container_cluster_config.cluster.admin_certificate
  client_key             = data.ibm_container_cluster_config.cluster.admin_key
  cluster_ca_certificate = data.ibm_container_cluster_config.cluster.ca_certificate
}

##############################################################################

##############################################################################
# Activity Tracker
##############################################################################

#resource ibm_resource_instance activity_tracker {

#  name              = "testLogDnaDemo"
#  service           = "logdnaat"
 ## plan              = "lite"
 # location          = "eu-de"
#  resource_group_id = data.ibm_resource_group.group.id

#  parameters = {
#    service-endpoints = "public"
##  }

#}

##############################################################################


##############################################################################
# Cluster Logging Setup
##############################################################################

module logging {
    source             = "./modules/log_dna"
    resource_group_id  = data.ibm_resource_group.group.id
    use_data           = var.bring_your_own_logging
    ibm_region         = var.ibm_region
    name               = var.logging_instance_name
    logdna_agent_image = var.logging_agent_image
    logdna_endpoint    = var.logging_endpoint
    logging_plan       = "lite"
    #tags               = var.tags
    end_points         = "public"
}

#Sysdig Part
#Config
  ##############################################################################
# Locally define image pull secrets to copy to ibm-observe namespace 
##############################################################################

locals {
  image_pull_secrets = [
      "all-icr-io"
    ]
} 

##############################################################################


##############################################################################
# Create Namespace
##############################################################################

resource kubernetes_namespace ibm_observe {
  metadata {
    name = "ibm-observe"
  }
}

##############################################################################


##############################################################################
# Default pull secret
##############################################################################

data kubernetes_secret image_pull_secret {
  count = length(local.image_pull_secrets)
  metadata {
    name = element(local.image_pull_secrets, count.index)
  }
}

##############################################################################


##############################################################################
# Copy image pull secret to ibm-observe
##############################################################################

resource kubernetes_secret copy_image_pull_secret {
  count = length(local.image_pull_secrets)
  metadata {
    name      = "ibm-observe-${element(local.image_pull_secrets, count.index)}"
    namespace = kubernetes_namespace.ibm_observe.metadata.0.name
  }
  data      = {
    ".dockerconfigjson" = data.kubernetes_secret.image_pull_secret[count.index].data[".dockerconfigjson"]
  }
  type = "kubernetes.io/dockerconfigjson"
}

##############################################################################
  module monitor {
    source             = "./modules/sys_dig"
    resource_group_id  = data.ibm_resource_group.group.id
    use_data           = var.bring_your_own_monitor
    ibm_region         = var.ibm_region
    name               = var.monitor_name
    cluster_name       = var.cluster_name
    sysdig_image       = var.monitor_agent_image
    sysdig_endpoint    = var.monitor_endpoint
    monitor_plan       = var.monitor_plan
    tags               = var.tags
    end_points         = var.service_end_points
}
