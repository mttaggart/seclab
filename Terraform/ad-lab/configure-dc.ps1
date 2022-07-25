# Get existing addresses
$inf_addr = Get-NetIpAddress | where {$_.IpAddress -like "192.168.99.*"}
$iso_addr = Get-NetIpAddress | where {$_.IpAddress -like "10.1.99.*"}
# Set Infra Address
New-NetIpAddress -Address $inf_addr.Address -PrefixLength 24 -InterfaceIndex $inf_addr.InterfaceIndex -DefaultGateway 192.168.99.1
New-NetIpAddress -Address 192.168.99.2 -PrefixLength 24 -InterfaceIndex $inf_addr.InterfaceIndex -DefaultGateway 192.168.99.1
# Set Isolation Address
New-NetIpAddress -Address $iso_addr.Address -PrefixLength 24 -InterfaceIndex $iso_addr.InterfaceIndex -DefaultGateway 10.1.99.1
New-NetIpAddress -Address 10.1.99.2 -PrefixLength 24 -InterfaceIndex $iso_addr.InterfaceIndex -DefaultGateway 10.1.99.1
