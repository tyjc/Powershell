function Add-SharepointPermissionsAuto {
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
        [Parameter(Mandatory)]
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

    #Intranet URL for invitation to Intranet
    #Update this with actual URL
    $IntranetURL = "www.intranet.com.au"
    #Array of teams ID's - example provided is not a valid ID. Comma seperated.
    $teams = @('bb421719-3a71-452d-a2d0-025f79qq7960')

    switch ($Tenant) {
        Yes { 
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
                Add-TeamUser -GroupId $team -User $targetUser
            }
            Disconnect-MicrosoftTeams
        }
        No {
            #optional lines to split a user email if it is formatted as 'firstname.lastname@url'
            #this was required for my particular usecase. Yours will likely differ. Replace as needed.
            #$Temp = ($targetUser -split "@")[0]
            #$TargetName = $Temp.replace('.', ' ')

            #Connects to MG graph with QIB creds
            #Creates a new guest user for the homehub sharepoint but does not send an invite
            Connect-MgGraph -Scopes User.ReadWrite.All
            New-MgInvitation -InvitedUserDisplayName $TargetName -InvitedUserEmailAddress $targetUser -InviteRedirectUrl $IntranetURL

            #connects to the MSTeams online admin
            #running it this way allows you to authenticate with MFA if required
            Connect-MicrosoftTeams

            #iterates through each column and performs add user
            #uses the email defined in the beginning to add to teams defined by groupID
            foreach ($team in $teams) {
                Add-TeamUser -GroupId $team -User $targetUser
            }
            Disconnect-MicrosoftTeams
            Disconnect-MgGraph
        }
    }
}