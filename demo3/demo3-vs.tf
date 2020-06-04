variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "VC-INS-A-Datacenter"
}

data "vsphere_resource_pool" "pool" {
  name          = "VMs"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = "wdc-eso-ins-a-VMs-1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "dvPortGroup-private-sdm-4050"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "cbp_centos73x64"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "random_integer" "suffix" {
  min     = 1000
  max     = 9999
}

resource "vsphere_virtual_machine" "vm" {
  name             = "terraform-test-${random_integer.suffix.result}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 1
  memory   = 512
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

}

output "vm_name" {
    value = "${vsphere_virtual_machine.vm.name}"
}

variable "extra" {}