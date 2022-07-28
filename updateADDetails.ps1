#import modules
Import-Module ActiveDirectory

#importCSV of usernames to update
Write-host "Importing Users..."
$users = Import-Csv -Path /path/to/csvs etc/allUserDetails.csv
Write-host "Users imported!"

foreach ($user in $users) {
    Get-ADUser -Identity $user.displayName |
    Set-ADUser -Title $user.title -EmailAddress $user.mail -description $user.description -state $user.st -postalCode $user.postalCode
}