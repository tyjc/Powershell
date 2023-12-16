#import modules
Import-Module ActiveDirectory

#importCSV of usernames to update
Write-host "Importing Users..."
$users = Import-Csv -Path /path/to/csv.csv
Write-host "Users imported!"

foreach ($user in $users) {
	$name = Get-ADUser -Identity $user.displayName
	write-host working on $name.Name
	$name | Set-ADUser -replace @{extensionAttribute1 = $user.extensionAttribute1; extensionAttribute2 = $user.extensionAttribute2; extensionAttribute3 = $user.extensionAttribute3 }
}