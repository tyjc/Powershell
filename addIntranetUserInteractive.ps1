function Add-SharepointPermissionsInteractively {
  <#
.SYNOPSIS
  Creates an account and applies permissions within the Intranet.
.DESCRIPTION
  - Switch determines if account is within Tenancy or outside
  - If yes, will skip inviting the user to the Sharepoint site, and will move on to adding the user to all required teams
  - If no, it will connect to MS graph, invite the user to the sharepoint (without an invite email being sent), and then add to teams
.NOTES
  Author:         Ty Collins
  Creation Date:  12/06/2022
#>


  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [String] $Tenant,
    [Parameter()]
    [String] $TargetUser
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

  #Imports CSV list of 'default' teams.
  #Update this with actual file location
  $teams = Import-Csv "\path\to\csv\csv.csv"
  #Intranet URL for invitation to Intranet
  #Update this with actual URL
  $intranetURL = "www.intranet.com.au"

  Write-Host "Loading needed modules"
  Import-Module MicrosoftTeams
  Import-Module Microsoft.Graph.Identity.SignIns
  Import-Module AzureAD
  Write-Host "All Modules Loaded"

  switch ($Tenant) {
    Yes { 
      #prompts user for the email address of the new user
      #stores as $targetuser variable for later use
      $targetUser = Read-Host "Enter the email address of the user to be added to Intranet (Please capitalise first and last name)"
      #optional lines to split a user email if it is formatted as 'firstname.lastname@url'
      #this was required for my particular usecase. Yours will likely differ. Replace as needed.
      #$Temp = ($targetUser -split "@")[0]
      #$TargetName = $Temp.replace('.', ' ')

      #connects to the MSTeams online admin
      #running it this way allows you to authenticate with MFA if required
      Connect-MicrosoftTeams

      #iterates through each column and performs add user
      #uses the email defined in the beginning to add to teams defined by groupID
      foreach ($team in $teams) {
        Add-TeamUser -GroupId $team.groupID -User $TargetUser
        #optional line to print each team being added.
        #Write-Host "Adding $($team.teamName)"
      }
      Write-Host "All teams added"
      Start-Sleep -Seconds 2
      Write-Host "Disconnecting all sessions"
      Disconnect-MicrosoftTeams
      Disconnect-MgGraph
      Write-Host "Sessions disconnected"
    }
    No {
      #prompts user for the email address of the new user
      #stores as $targetuser variable for later use
      $targetUser = Read-Host "Enter the email address of the user to be added to Intranet (Please capitalise first and last name)"
      #optional lines to split a user email if it is formatted as 'firstname.lastname@url'
      #this was required for my particular usecase. Yours will likely differ. Replace as needed.
      #$Temp = ($targetUser -split "@")[0]
      #$TargetName = $Temp.replace('.', ' ')

      #Connects to MG graph with creds
      #Creates a new guest user for the Intranet but does not send an invite
      Write-Host "Connecting to MS Graph to add user to Intranet - Please use your Account to sign in when prompted"
      Connect-MgGraph -Scopes User.ReadWrite.All
      Write-Host "Connection established"
      Write-Host "Creating invitation"
      New-MgInvitation -InvitedUserDisplayName $TargetName -InvitedUserEmailAddress $targetUser -InviteRedirectUrl $intranetURL
      Write-Host "Invitation created and guest user added"

      #connects to the MSTeams online admin
      #running it this way allows you to authenticate with MFA if required
      Write-Host "Connecting to Teams to add teams memberships"
      Connect-MicrosoftTeams
      Write-Host "Connected"

      #iterates through each column and performs add user
      #uses the email defined in the beginning to add to teams defined by groupID
      foreach ($team in $teams) {
        Add-TeamUser -GroupId $team.groupID -User $TargetUser
        #optional line to print each team being added.
        #Write-Host "Adding $($team.teamName)"
      }
      Write-Host "All teams added"
      Start-Sleep -Seconds 2
      Write-Host "Disconnecting all sessions"
      Disconnect-MicrosoftTeams
      Disconnect-MgGraph
      Write-Host "Sessions disconnected"
    }
  }
}