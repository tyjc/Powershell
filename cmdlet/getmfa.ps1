function get-MFAStatus {
    <#
.Synopsis
Get the MFA status for users
.DESCRIPTION
Switch to check either all users or users without MFA at all.
.NOTES
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String] $withOutMFAOnly
    )
    Connect-MsolService
    $MsolUsers = Get-MsolUser -EnabledFilter EnabledOnly | Where-Object { $_.IsLicensed -eq $true } | Sort-Object UserPrincipalName
    foreach ($MsolUser in $MsolUsers) {
        $MFAMethod = $MsolUser.StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq $true } | Select-Object -ExpandProperty MethodType
        $Method = ""
        If (($MsolUser.StrongAuthenticationRequirements) -or ($MsolUser.StrongAuthenticationMethods)) {
            Switch ($MFAMethod) {
                "OneWaySMS" { $Method = "SMS token" }
                "TwoWayVoiceMobile" { $Method = "Phone call verification" }
                "PhoneAppOTP" { $Method = "Hardware token or authenticator app" }
                "PhoneAppNotification" { $Method = "Authenticator app" }
            }
        }
        switch ($withOutMFAOnly) {
            true {
                if (-not($MsolUser.StrongAuthenticationMethods)) {
                    [PSCustomObject]@{
                        DisplayName       = $MsolUser.DisplayName
                        UserPrincipalName = $MsolUser.UserPrincipalName
                        isAdmin           = if ($listAdmins -and ($admins.EmailAddress -match $MsolUser.UserPrincipalName)) { $true } else { "-" }
                        MFAEnabled        = $false
                        MFAType           = "-"
                        MFAEnforced       = if ($MsolUser.StrongAuthenticationRequirements) { $true } else { "-" }
                    }
                }
            }
            false {
                [PSCustomObject]@{
                    DisplayName                           = $MsolUser.DisplayName
                    UserPrincipalName                     = $MsolUser.UserPrincipalName
                    isAdmin                               = if ($listAdmins -and ($admins.EmailAddress -match $MsolUser.UserPrincipalName)) { $true } else { "-" }
                    "MFA Enabled"                         = if ($MsolUser.StrongAuthenticationMethods) { $true } else { $false }
                    "MFA Default Type"                    = $Method
                    "SMS token"                           = if ($MsolUser.StrongAuthenticationMethods.MethodType -contains "OneWaySMS") { $true } else { "-" }
                    "Phone call verification"             = if ($MsolUser.StrongAuthenticationMethods.MethodType -contains "TwoWayVoiceMobile") { $true } else { "-" }
                    "Hardware token or authenticator app" = if ($MsolUser.StrongAuthenticationMethods.MethodType -contains "PhoneAppOTP") { $true } else { "-" }
                    "Authenticator app"                   = if ($MsolUser.StrongAuthenticationMethods.MethodType -contains "PhoneAppNotification") { $true } else { "-" }
                    MFAEnforced                           = if ($MsolUser.StrongAuthenticationRequirements) { $true } else { "-" }
                }
            }
        }
    }
}