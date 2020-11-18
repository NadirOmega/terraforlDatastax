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
  
}
##############################################################################
# Cluster Data
##############################################################################

data ibm_container_cluster_config cluster {
  cluster_name_id   = "cluster1_demo"
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

resource ibm_resource_instance activity_tracker {

  name              = "testLogDnaDemo"
  service           = "logdnaat"
  plan              = "lite"
  location          = "eu-de"
  resource_group_id = data.ibm_resource_group.group.id

  parameters = {
    service-endpoints = "public"
  }

}

##############################################################################


##############################################################################
# Cluster Logging Setup
##############################################################################

module logging {
    source             = "./log_dna"
    resource_group_id  = data.ibm_resource_group.group.id
    use_data           = var.bring_your_own_logging
    ibm_region         = var.ibm_region
    name               = var.logging_instance_name
    logdna_agent_image = var.logging_agent_image
    logdna_endpoint    = var.logging_endpoint
    logging_plan       = var.logging_plan
    tags               = var.tags
    end_points         = var.service_end_points
}

