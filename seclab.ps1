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
    [ValidateSet("init","add","remove","teardown")]
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
        

        # Create Seclab-Internal Switch
        New-VMSwitch -Name "Seclab-Internal" -SwitchType Internal
        $iface = Get-NetAdapter | where {$_.Name -like "*Seclab-Internal*"}

        # Create Seclab-Internal IP
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
    cd ansible-packer
    packer build . -force

    # Import it
    $vmcx = ls ".\output-seclab-ansible\Virtual Machines\*.vmcx" | Select Name
    $vmcxPath = ".\output-seclab-ansible\Virtual Machines\" + $vmcx.Name.ToString()
    Import-VM -Path $vmcxPath -Register

    # Modify VM Net adapters
    $vm = Get-VM -VMName "seclab-ansible"
    $vm | Remove-NetworkAdapter
    Add-VMNetworkAdapter -VMName "seclab-ansible" -SwitchName "Seclab-Internal"
    Add-VMNetworkAdapter -VMName "seclab-ansible" -SwitchName "Seclab-Isolation"

    cd ..
    

} elseif ($Action -eq "add") {
    if (! (switchCheck($switches))) {
        write-host "Switches not configured. Run init first!"
    }
} elseif ($Action -eq "teardown") {
    if (! (switchCheck($switches))) {
        # Remove the base VMs
        $pfsense = Get-VM -Name "seclab-pfsense"
        $ansible = Get-VM -Name "seclab-ansible"

        # Delete VMs
        Remove-VM -VMName $pfsense.VMName
        Remove-VM -VMName $ansible.$VMName
        # Delete HDs
        Remove-Item -Path $pfsense.HardDrives.Path
        Remove-Item -Path $ansible.HardDrives.Path
        # Remove Switches
        Remove-VMSwitch -SwitchName "Seclab-Internal"
        Remove-VMSwitch -SwitchName "Seclab-Isolation"
    }
} else {
    if (! (switchCheck($switches))) {
        write-host "Switches not configured. Run init first!"
    }
}
