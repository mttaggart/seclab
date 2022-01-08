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

function switchCheck() {

    param(
        [string[]]$switches
    )
    
    return ($switches.Name -contains "Seclab-Internal") -and ($switches.Name -contains "Seclab-Isolation")
}


# Load switches
$switches = Get-VMSwitch | select Name

if ($Action -eq "init") {
    write-host "INIT"
    # Create Seclab/Isolation Switch
    if (! ($switches.Name -contains "Seclab-Internal")) {
        

        New-VMSwitch -Name "Seclab-Internal" -SwitchType Internal
        $iface = Get-NetAdapter | where {$_.Name -like "*Seclab-Internal*"}
        New-NetIPAddress -IPAddress 10.0.100.1 -PrefixLength 24 -InterfaceIndex $iface.ifIndex
        
    }
    if (! ($switches.Name -contains "Seclab-Isolation")) {
        New-VMSwitch -Name "Seclab-Isolation" -SwitchType Private
    }
    # Build pfSense
    cd pfsense-packer
    packer build -force .
    # Import VM
    $vmcx = ls ".\output-seclab-pfsense\Virtual Machines\*.vmcx" | Select Name
    $vmcxPath = ".\output-seclab-pfsense\Virtual Machines\" + $vmcx.Name.ToString()
    Import-VM -Path $vmcxPath -Register
    # Modify VM To add additional Network Adapter
    Add-VMNetworkAdapter -VMName "seclab-pfsense" -SwitchName "Seclab-Isolation"
    cd ..

    # Build Ansible
    # cd ansible-packer





} elseif ($Action -eq "add") {
    if (! (switchCheck($switches))) {
        write-host "Switches not configured. Run init first!"
    }
} else {
    if (! (switchCheck($switches))) {
        write-host "Switches not configured. Run init first!"
    }
}
