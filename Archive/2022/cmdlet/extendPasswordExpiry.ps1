function Reset-PasswordExpiry {
    <#
  .SYNOPSIS
    Effectively extends password expiry by x days, where x is maximum password age
  .DESCRIPTION
    prompts user name of the user who requires a password extension
    stores as $username variable for passing to AD
    sets password last set date to 'never' then to todays date, effectively resetting the clock on the password update
  .NOTES
    Author:         Ty Collins
    Creation Date:  12/10/2021
#>


    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String] $Username,
        [Parameter(Mandatory)]
        [String] $Changepwdflag
    )

    Import-Module ActiveDirectory

    Write-Host "Changing the password last set to 'Never' for $Username"
    Set-ADUser -Identity $Username -Replace @{pwdlastset = "0" }
    Write-Host "Changed password last set to 'Never'"
    Write-Host "Changing the password last set to '$(Get-Date -format 'd')' for $username"
    Set-ADUser -Identity $Username -Replace @{pwdlastset = "-1" }
    Write-Host "Changed the password last set to '$(Get-Date -format 'd')' for $username"
    
    switch ($Changepwdflag) {
        y { 
            Set-ADUser -Identity $Username -ChangePasswordAtLogon $true -Confirm 
        }
        n { 
            Write-Host "Change password on Next Login has not been enabled." 
        }
    }
}