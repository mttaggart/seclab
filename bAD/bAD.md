This list of commands will create a forest with the name of ginger.local and add a domain admin with the password as below. Password is taken out of rockyou.txt

## Install Active Directory

Add-WindowsFeature AD-DomainServices
Install ADDSForest -DomainName ginger.local -InstallDNS

## Create new Domain Admin

New-Aduser -Name "Thackerman" -AccountPassword (Read-Host -AsSecureString "rangataua@6613") -Enabled $true

## Set DNS of WINDOWS CLIENT (NOT DC) and add to domain
## First run Get-NetIPConfiguration to get interface index

Set-DnsClientServerAddress -InterfaceIndex <> -ServerAddresses <IP of domain controller>
Add-Computer -DomainName ginger.local -Restart

## Create local admin for non-dc computer

## Run on domain controller
New-ADUser -samaccountname "wadmin" -name "wadmin" -enabled $true -accountpassword(Read-Host -AsSecureString "rangataua@6613")

## Run on workstation
Add-LocalGroupMember -Group "Administrators" -Member "ginger\wadmin"
