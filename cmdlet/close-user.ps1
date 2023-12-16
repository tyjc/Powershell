function close-user {

    <#
.SYNOPSIS
  Offboards an AD User
.DESCRIPTION
  - Disables a user account in Active Directory for offboarding
  - Removes all AD group memberships
  - Removes extension attributes
  - Sets mailbox to shared
  - Hides mailbox from the GAL
.NOTES
  Version:        1.0
  Author:         Ty Collins
  Creation Date:  23/12/2022
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String] $username,
        [Parameter(Mandatory)]
        [String] $oupath
    )

    Write-Host "Importing Modules"
    Import-Module ActiveDirectory, ExchangeOnlineManagement
    Write-Host "Modules Imported"
    
    $users = Get-ADUser -Identity $username
    
    Connect-ExchangeOnline

    Set-Mailbox -Identity $username -Type shared -HiddenFromAddressListsEnabled:$true
    Get-ADPrincipalGroupMembership -Identity $username | Select-Object name | Export-Csv "/path/to/csv.csv"
    Get-ADPrincipalGroupMembership -Identity $username | Where-Object -Property name -ne -Value 'domain users' | Remove-ADGroupMember -Members delete.me -Confirm:$false

    foreach ($user in $users) {
        Write-Host "Clearing Extension Attributes One and Two"
        Set-ADUser -Identity $user.distinguishedname -Clear extensionattribute1, extensionattribute2 -Confirm:$false
        Write-Host "Moving user to Disabled Accounts OU"
        Move-ADObject -Identity $user.distinguishedname -TargetPath $oupath -Confirm:$false
        Write-Host "Disabling User"
        Disable-ADAccount -Identity $user.distinguishedname
    }
}
