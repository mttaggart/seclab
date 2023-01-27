$hostname = (Get-ADComputer -filter 'primarygroupid -ne "516"' | Select-Object DNSHostName)
$hostname = $hostname.DNSHostName.split(".")[0]
Get-ADComputer -Identity $hostname | Set-ADAccountControl -TrustedForDelegation $true
