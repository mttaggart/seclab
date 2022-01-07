// packer {
//   required_plugins {
//     virtualbox = {
//       version = ">= 0.0.1"
//       source  = "github.com/hashicorp/virtualbox"
//     }
//   }
// }

source "hyperv-iso" "seclab-pfsense" {
  /*skip_export             = true*/
  shutdown_command        = "poweroff"
  communicator            = "none"
  guest_additions_mode    = "disable"
  switch_name             = "Seclab-Internal"
  // guest_os_type           = "FreeBSD_64"
  iso_url                 = "pfSense-CE-2.5.2-RELEASE-amd64.iso"
  iso_checksum            = "sha256:234bcd61549867cfda719424a11bb0e13233c2b582acc7cec0ee1b0ec0966cf3"
  cpus                    = 1
  memory                  = 1024
  vm_name                 = "seclab-pfsense"
  http_directory          = "html"
  boot_wait               = "30s"
  boot_command = [
    "<enter><wait>",
    "<enter><wait>",
    "<enter><wait>",
    "<enter><wait>",
    "<enter><wait>",
    "<enter><wait>",
    "<spacebar><wait>",
    "<enter><wait>",
    "<tab><enter><wait>",
    "<enter><wait30s>",
    "<tab><enter><wait>",
    "ifconfig hn0 10.0.100.2 netmask 255.255.255.0 up<enter>",
    "/usr/local/bin/curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/config.xml > /conf/config.xml",
    "<enter><wait10s>",
    "<wait>exit<enter>",
    "<enter><wait>",
    "<enter><wait>",
  ]

}

build {
  sources = ["sources.hyperv-iso.seclab-pfsense"]
}
