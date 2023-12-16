function update-CalendarPermission {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, HelpMessage = "Enter domain short form to prefill log in screen.")]
        [String] $Business,
        [Parameter(Mandatory, HelpMessage = "User who owns the calendar we are providing access to")]
        [String] $TargetCalendar,
        [Parameter(Mandatory, HelpMessage = "User who will be receiving permission to the calendar")]
        [String] $TargetUser,
        [Parameter(Mandatory, HelpMessage = "Level of access being granted to a user, if unsure, 'Reviewer' is a good start")]
        [String] $AccessRights,
        [Parameter(Mandatory, HelpMessage = "method of modifying permissions, 'Set' to update existing permission, 'add' to add new permission")]
        [String] $Method
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
    

    #connects to exchange online using the details provided
    #this will request a password if you are not 'signed in' with an active session
    switch ($Business) {
    ($Business -eq 'Business1') { Connect-ExchangeOnline -UserPrincipalName tycollins@Business1.com.au }
    ($Business -eq 'Business2') { Connect-ExchangeOnline -UserPrincipalName tycollins@Business2.com.au }
    ($Business -eq 'Business3') { Connect-ExchangeOnline -UserPrincipalName tycollins@Business3.com.au }
    ($Business -eq 'Business4') { Connect-ExchangeOnline -UserPrincipalName tycollins@Business4.com.au }
    }

    switch ($Method) {
        Set { Set-MailboxFolderPermission -Identity ${targetCalendarUser}:\Calendar -User $targetMailUser -AccessRights $accessRights -confirm }
        Add { Add-MailboxFolderPermission -Identity ${targetCalendarUser}:\Calendar -User $targetMailUser -AccessRights $accessRights -confirm }
    }

    #disconnects from the exchange session
    Disconnect-ExchangeOnline

}