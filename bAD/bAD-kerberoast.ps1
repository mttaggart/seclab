New-ADUser -Name "Kirby" -SamAccountName "kirby" -Enabled $true -AccountPassword (Read-host -AsSecureString "rangataua@6613")
$meatloaf = hostname
setspn -a $meatloaf/kirby.ginger.local:4444 ginger\kirby
setspn -T ginger.local -Q */*
