packer {
  required_plugins {
    virtualbox = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "hostname" {
  type = "string"
  default = "seclab-win-ws"
}

variables "password {
  type = "string",
  default = "Seclab123!"
}

source "virtualbox-iso" "seclab-win-ws" {
  /*skip_export             = true*/
  format                  = "ova"
  communicator            = "none"
  virtualbox_version_file = ""
  guest_additions_mode    = "disable"
  guest_os_type           = "Windows10_64"
  iso_url                 = "win10.iso"
  /*iso_url                 = "https://software-download.microsoft.com/download/sg/19043.928.210409-1212.21h1_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"*/
  iso_checksum            = "sha256:026607e7aa7ff80441045d8830556bf8899062ca9b3c543702f112dd6ffe6078"
  cpus                    = 2
  memory                  = 4096
  vm_name                 = "seclab-win-ws"
  boot_wait               = "20s"
  boot_command = [
    "<tab><tab><tab><enter><wait>",
    "<enter><wait15s>",
    "<spacebar><tab><enter><wait>",
    "<tab><enter><wait><enter>",
    "<wait6m>",
    "<enter><wait5s>",
    "<enter><wait>",
    "<enter><wait5s>",
    "<tab><enter><wait>",
    "<tab><tab><tab><tab><enter><wait3s>",
    "seclab<enter><wait>",
    "${var.password}<enter><wait>",
    "${var.password}<enter><wait>",
    "<down><tab>SecurityAnswer<enter><wait>",
    "<down><tab>SecurityAnswer<enter><wait>",
    "<down><tab>SecurityAnswer<enter><wait10s>",
    "<tab><tab><tab><wait>",
    "<spacebar><tab><spacebar><tab><spacebar><tab><spacebar><tab><spacebar><tab><spacebar><tab><tab><enter><wait3s>",
    "<tab><tab><tab><tab><enter><wait3m>",
    "<menu><wait3s>powershell<wait><right><down><enter><wait><left><enter><wait>",
    "winrm quickconfig<enter><wait>",
    "y<enter><wait3s>",
    "Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private<enter><wait>",
    "Rename-Computer ${var.hostname}<enter><wait>"
    
  ]

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--memory", "4096"],
    ["modifyvm", "{{.Name}}", "--cpus", "2"],
    ["modifyvm", "{{.Name}}", "--nic1", "intnet", "--intnet1", "isolation"],
  ]

}

build {
  sources = ["sources.virtualbox-iso.seclab-win-ws"]
}
