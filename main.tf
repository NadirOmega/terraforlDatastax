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
  resource_group_id = data.ibm_resource_group.group.id
}


