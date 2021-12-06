packer {
  required_plugins {
    virtualbox = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "password" {
  type    = string
  default = "Seclab123!"
}

source "virtualbox-iso" "seclab-win-server" {
  /*skip_export             = true*/
  format                  = "ova"
  communicator            = "none"
  virtualbox_version_file = ""
  winrm_username          = "Administrator"
  winrm_password          = "${var.password}"
  winrm_use_ssl           = true
  guest_additions_mode    = "disable"
  guest_os_type           = "Windows2019_64"
  iso_url                 = "https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"
  iso_checksum            = "sha256:549bca46c055157291be6c22a3aaaed8330e78ef4382c99ee82c896426a1cee1"
  cpus                    = 2
  memory                  = 4096
  vm_name                 = "seclab-win-server"
  boot_wait               = "20s"
  boot_command = [
    "<tab><tab><tab><enter><wait>",
    "<enter><wait15s>",
    "<down><enter><wait5s>",
    "<spacebar><enter><wait>",
    "<down><enter><wait>",
    "<enter>",
    "<wait4m>",
    "${var.password}<tab>${var.password}<enter><wait>",
    "<enter><wait1m>",
    "<LeftCtrlOn><LeftAltOn><del><LeftCtrlOff><LeftAltOff><wait>",
    "${var.password}<enter><wait1m>",
    "<enter><leftSuperOn>r<leftSuperOff><wait3s>",
    "powershell.exe<enter><wait3s>",
    "winrm quickconfig -q<enter><wait3s>",
    "Set-Item -Path WSMan:\\localhost\\Service\\Auth\\Basic -Value <$>true<enter><wait>"
    /*"Rename-Computer zd-dc-01<enter><wait>"*/
    
  ]

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--memory", "4096"],
    ["modifyvm", "{{.Name}}", "--cpus", "2"],
    ["modifyvm", "{{.Name}}", "--nic2", "intnet", "--intnet2", "isolation"],
  ]

}


build {
  sources = ["sources.virtualbox-iso.seclab-win-server"]
}
