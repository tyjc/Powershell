function New-ADUser {
    <#
.SYNOPSIS
  Creates a new user account in AD
.DESCRIPTION
  - Creates a new user account in AD from a template account
  - Prefills address details with the neccessary office location
  - Prefills phone number fields with default reception phone numbers for each office
  - Prefills basic group memberships
.NOTES
  Version:        1.0
  Author:         Ty Collins
  Creation Date:  17/06/2022
#>


    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String] $FirstName,
        [Parameter(Mandatory)]
        [String] $Surname,
        [Parameter(Mandatory)]
        [String] $Location,
        [Parameter(Mandatory)]
        [String] $Role,
        [Parameter(Mandatory)]
        [String] $Company
    )

    Write-Warning "
  |+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+DISCLAIMER|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|
  ##############################################################################################################
  ##############################################################################################################
  ||||||||||||||||||||||||||||||||||||   I wrote it, and it works for me.   ||||||||||||||||||||||||||||||||||||
  ||||||||||||||  If you run it, and don't understand it, don't blame me when you break something  |||||||||||||
  ##############################################################################################################
  ##############################################################################################################
" -WarningAction Inquire

    #Import required modules
    Write-Host "Importing relevant modules"
    Write-Host "Importing Active Directory Module"
    Import-Module ActiveDirectory
    Write-Host "Imported Active Directory Module"
    Write-Host "All Modules have been imported"

    #set template account for new user. This will be a generic account, as it cant pull account memberships etc.
    $Template = Get-ADUser -Filter "UserPrincipalName -eq 'Template@contoso.com.au'" -Properties country, organization, state

    #Formats extra variables for filling in the New-ADUser cmdlet
    Get-newPassword
    Write-Host password should be here $Password
    $Name = ($FirstName + ' ' + $Surname)
    $sAMAccountName = ($FirstName + '.' + $Surname)
    $Email = ($FirstName + '.' + $Surname + '@contoso.com.au')
    $SecurePassword = (ConvertTo-SecureString -AsPlainText $Password -Force)

    #Sets profile path for user based on location parameter
    Switch ($Location) {
        Location1 {
            $ProfilePath = 'OU path' 
            $PostalCode = '1234' 
            $Street = 'streed address'
            $City = 'city'
            $POBox = 'PO BOX 123'
            $Fax = '07 1234 5678'
            $Phone = '07 1234 5678'
        }
        Location2 {
            $ProfilePath = 'OU path' 
            $PostalCode = '1234' 
            $Street = 'streed address'
            $City = 'city'
            $POBox = 'PO BOX 123'
            $Fax = '07 1234 5678'
            $Phone = '07 1234 5678'
        }
        Location3 {
            $ProfilePath = 'OU path' 
            $PostalCode = '1234' 
            $Street = 'streed address'
            $City = 'city'
            $POBox = 'PO BOX 123'
            $Fax = '07 1234 5678'
            $Phone = '07 1234 5678'
        }
    }

    #Creates the new user
    Write-Host "Creating new user - $Name"
    New-ADUser -Instance $template -SamAccountName $sAMAccountName -GivenName $FirstName -Surname $Surname -Name $Name -EmailAddress $Email -UserPrincipalName $Email -ProfilePath $Profile -ScriptPath 'logon.bat' -Title $Role -StreetAddress $Street -AccountPassword $SecurePassword -Description $Role -DisplayName $Name -Company $Company -PostalCode $PostalCode -Path $ProfilePath $POBox -Fax $Fax -OfficePhone $Phone -City $City -POBox $POBox
    Write-Host "New User Created"

    #Uses location parameter to determine AD groups to join account to
    Switch ($Location) {
        Location1 {
            $ADGroups = @("Array of AD Groups")
            foreach ($ADGroup in $ADGroups) {
                Write-Host "Adding to $ADGroup"
                Add-ADPrincipalGroupMembership $sAMAccountName -MemberOf $ADGroup
                Write-Host "Added to $ADGroup"
            }
        }
        Location2 {
            $ADGroups = @("Array of AD Groups")
            foreach ($ADGroup in $ADGroups) {
                Write-Host "Adding to $ADGroup"
                Add-ADPrincipalGroupMembership $sAMAccountName -MemberOf $ADGroup
                Write-Host "Added to $ADGroup"
            }
        }
        Location3 {
            $ADGroups = @("Array of AD Groups")
            foreach ($ADGroup in $ADGroups) {
                Write-Host "Adding to $ADGroup"
                Add-ADPrincipalGroupMembership $sAMAccountName -MemberOf $ADGroup
                Write-Host "Added to $ADGroup"
            }
        }
    }
}