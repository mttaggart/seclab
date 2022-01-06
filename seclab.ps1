<#
.SYNOPSIS
Seclab uses Packer to generate a home lab environment for security research

.DESCRIPTION
This script wraps packer, so make sure it's installed and on the PATH. It will create virtual machines and networks using Hyper-V, so it must be run as an administrator. 

.PARAMETER Action
The action to take. Options are "init", "add", and "remove."

.PARAMETER VMType
The type of VM to add for -Action add

.PARAMETER VMName
Name of VM to add or remove

.LINK
https://github.com/mttaggart/seclab
#>

Param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("init","add","remove")]
    [String]$Action,
    
    [Parameter(Mandatory = $false, ValueFromPipeline=$true)]
    [ValidateSet("win-server","labbuntu","jumpbox", "win-ws")]
    [String]$VMType,

    [Parameter(Mandatory = $false, ValueFromPipeline=$true)]
    [String]$VMName
)

if ($Action -eq "init") {
    write-host "INIT"
} elseif ($Action -eq "add") {
    write-host "ADD"
} else {
    write-host "REMOVE"
}
