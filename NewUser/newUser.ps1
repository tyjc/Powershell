function test-ADUser {

    <#
    .SYNOPSIS
        Checks AD for user. Returns 
        $true   =   Username and SAMAccount name match
        $false  =   Username does not exist at all
        $newID  =   Username and SAMAccount name do not match, requring a new user ID with a numbered suffix ie, 'f.oobar02@contoso.org'
    #>
    
    param (
        [Parameter(Mandatory)]
        [String] $SAMAccountName
    )
    try {
        Get-ADUser -Server contoso.org -Identity $SAMAccountName
        if (((Get-ADUser -Filter "SAMAccountName -eq '$StaffSAMname'" -Properties description).description) -eq $user.StaffID) {
            return 'true'
        }           
        else {
            return 'newID'
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        return 'false'
    }
}
    
#Gets current date to be used throughout the script. This should appear at the top of variable list to avoid any odd behaviour.
$Date = get-date -format "dd-MM-yyyy"

#Create folder for days log, and begins transcript of PS
New-Item -Path "path\to\logs\NewStaff_$($date)" -ItemType Directory
Start-Transcript -Path "path\to\logs\NewStaff_$($date)\PSTranscripts\StaffPSTranscript_$($date).txt"
    
#Creates encrypted credentials for use with SQL operations.
$SQLSecFile = "path\to\credentials\SQLPassword.txt"
$SQLSecUser = "path\to\credentials\SQLUserName.txt"
$MySQLCredential = New-Object -TypeName System.Management.Automation.PSCredential  -ArgumentList (Get-Content $SQLSecUser), (Get-Content $SQLSecFile | ConvertTo-SecureString)
    
#SQL variables.
#Query to extract new staff from a SQL database.
$Query = 'path\to\queries\staffFutureStarter.sql'
#Sets the $user variable to results of the above SQL query.
#Optional encryption line is required for running of the query.
$Staff = Invoke-Sqlcmd -Encrypt Optional -ServerInstance sql01.contoso.org -InputFile $query -Credential $MySQLCredential
    
#User variables for creation.
#Generic password as one must be set in new-aduser as it is a required field, though end users will not be told this, and will be instructed to change password immediately.
$Password = 'Password123!'
#Converts from plain text to secure string as the password field in new-aduser only accepts secure strings.
$SecurePassword = (ConvertTo-SecureString -AsPlainText $Password -Force)
    
#Filepath for the log to be created after each run of the script.
#Generates seperate logs for 'existing' staff and for 'new' staff, to make helpdesk role easier to audit new users.
$LogPath = "path\to\logs\NewStaff_$($Date)\NewStaffLog_$($Date).csv"
$ExistingStaffLog = "path\to\logs\NewStaff\NewStaff_$($Date)\ExistingStaffLog_$($Date).csv"
    
    
#Foreach loop iterates through each user present in the SQL Query.
foreach ($User in $Staff) {
    #Loop variables.
    #Sets variable for staff's first initial.
    #Modify string as required to suit SQL output.
    $StaffFirstInitial = $user.StaffPreferred.Substring("", "1")
    #Strip whitespace from surname for use in email and samaccount.
    #This will remove errant spacing present from poor data entry, or multi-word surnames without hyphens.
    #Modify string as required to suit SQL output.
    $CleanSurname = $User.StaffSurname -replace " ", ""
    #Sets variable for SAM name for search purposes and use in account creation.
    $StaffSAMName = "$($StaffFirstInitial).$($CleanSurname)"
    #Set variable for Staff Email.
    #This variable is used for users who are being created who do not have a clashing first initial and surname as an existing staff member.
    $stafffutureemail = "$($StaffFirstInitial).$($CleanSurname)@contoso.org"
    
    #Swtich runs the test-aduser function to determine if the user is pre-existing, can be created with default naming convention, or will require a new ID to be created.
    switch (test-ADUser -SAMAccountName $StaffSamName) {
        #Actions carried out when a user already exists.
        'true' {
            #Switch determines if the user exists and is either enabled or disabled.
            switch ((Get-ADUser -Server contoso.org -Identity $StaffSAMName -Properties *).enabled) {
                #If switch returns true, account exists and is enabled. writes to csv.
                $true { 
                    [pscustomobject]@{
                        #Modify string as required to suit SQL output.
                        Username  = $user.StaffNameExternal
                        StartDate = $user.StartDate
                        Notes     = 'Pre-Existing enabled user'
                    } | Export-Csv -Path $ExistingStaffLog -Append -NoTypeInformation 
                }
                #If switch returns false, account exists but is not enabled. Sets variables and re-enables account.
                $false {
                    #Switch determines the 'location' of the user, to set site specific OU paths and groups.
                    #Modify string as required to suit SQL output.
                    Switch ( $user.StaffSite ) {
                        #Italy site.
                        I {
                            $city = 'Italy'
                            #List of AD Groups.
                            $groups = ('')
                            #Switch to apply specific AD Groups dependant on staff type, i.e. HR/Finance.
                            switch ( $user.StaffCategoryType ) {
                                HR { 
                                    $path = 'OU=Italy-HR,DC=contoso,DC=org'
                                    #Additional groups as required.
                                    $groups += '' 
                                }
                                Finance { 
                                    $path = 'OU=Italy-Fin,DC=contoso,DC=org'
                                    #Additional groups as required.
                                    $groups += '' 
                                }
                            }
                        }
                        #Spain site.
                        S {
                            $city = 'Spain'
                            #List of AD Groups.
                            $groups = ('')
                            #Switch to apply specific AD Groups dependant on staff type, i.e. HR/Finance.
                            switch ( $user.StaffCategoryType ) {
                                HR { 
                                    $path = 'OU=Spain-HR,DC=contoso,DC=org'
                                    #Additional groups as required.
                                    $groups += '' 
                                }
                                Finance { 
                                    $path = 'OU=Spain-Fin,DC=contoso,DC=org'
                                    #Additional groups as required.
                                    $groups += '' 
                                }
                            }
                        }
                    }
                    #Adds the user to all relevant groups defined through the location switches preceeding.
                    foreach ($group in $groups) {
                        Add-ADGroupMember -Server 'contoso.org' `
                            -Identity $group `
                            -Members $StaffSAMName 
                    }
                    #Initial Set-ADuser cmdlet will set the default A5 license that the majority of staff use.
                    #Replace is able to add exchange extension attributes for alternative uses, i.e. licensing.
                    Set-ADUser -Server contoso.org `
                        -Identity $user.staffID `
                        -Enabled $true `
                        -City $city `
                        -Replace @{'extensionattribute1' = "Staff"; 'extensionattribute2' = "A5" }
                    #Get-ADUser passes along the account details through the pipeline to then move the account back to the correct OU.
                    Get-ADUser -server contoso.org -Identity $user.StaffID | Move-ADObject -TargetPath $path
                    [pscustomobject]@{
                        Username  = $user.StaffNameExternal
                        StartDate = $user.StartDate
                        Notes     = 'User was re-enabled by script, please check OU and Extension Attributes'
                    } | Export-Csv -Path $LogPath -Append -NoTypeInformation 
                }
            }
        }
        #Actions taken when no user account matching the SAM name can be found.
        'false' {
            #Switch determines the 'location' of the user, to set site specific OU paths and groups.
            Switch ( $user.StaffSite ) {
                #Italy site.
                I {
                    $city = 'Italy'
                    #List of AD Groups.
                    $groups = ('')
                    #Switch to apply specific AD Groups dependant on staff type, i.e. HR/Finance.
                    switch ( $user.StaffCategoryType ) {
                        HR { 
                            $path = 'OU=Italy-HR,DC=contoso,DC=org'
                            #Additional groups as required.
                            $groups += '' 
                        }
                        Finance { 
                            $path = 'OU=Italy-Fin,DC=contoso,DC=org'
                            #Additional groups as required.
                            $groups += '' 
                        }
                    }
                }
                #Spain site.
                S {
                    $city = 'Spain'
                    #List of AD Groups.
                    $groups = ('')
                    #Switch to apply specific AD Groups dependant on staff type, i.e. HR/Finance.
                    switch ( $user.StaffCategoryType ) {
                        HR { 
                            $path = 'OU=Spain-HR,DC=contoso,DC=org'
                            #Additional groups as required.
                            $groups += '' 
                        }
                        Finance { 
                            $path = 'OU=Spain-Fin,DC=contoso,DC=org'
                            #Additional groups as required.
                            $groups += '' 
                        }
                    }
                }
            }
            #New-ADUser to create the new account, setting all account fields where possible
            #Modify string as required to suit SQL output.
            New-ADUser -Server contoso.org `
                -SAMAccountName $StaffSAMName `
                -GivenName $user.staffpreferred `
                -Surname $user.staffsurname `
                -DisplayName $user.staffnameexternal `
                -Name $user.StaffNameExternal `
                -City $city `
                -AccountPassword $SecurePassword `
                -Description $user.staffid `
                -Enabled 1 `
                -OtherAttributes @{'extensionattribute1' = 'staff'; 'extensionattribute2' = 'A5' } `
                -Path $Path `
                -UserPrincipalName $stafffutureemail `
                -EmailAddress $stafffutureemail
            #Adds the user to all relevant groups defined through the location switches preceeding.
            foreach ($group in $groups) {
                Add-ADGroupMember -Server 'contoso.org' `
                    -Identity $group `
                    -Members $StaffSamName
            }
        }
        #When test-ADUser returns 'newid' a new id with a numbered suffix needs to be generated.
        'newid' {
            [int]$AccountNumber = 1
            #Do loop iterates through integers until a username is reached that does not already exist.
            #Once a new username is found, it is set on the 'newstaffemail' and 'newstaffusername' variables.
            #Note: Can forsee this train of events becoming a problem as the test-aduser function has no way to currently test for existing 'f.oobar02' emails. It currently makes the assumption, if the original email exists, and it does not belong to that individual, a new suffix will be needed. Food for thought 18/09/23.
            do {
                $AccountNumber ++
                $NewStaffUsername = $StaffSAMName + '{0:d2}' -f $accountnumber
                $NewStaffEmail = $NewStaffUsername + '@contoso.org'
            }until(
                -not (Get-ADUser -Filter { SAMAccountName -eq $NewStaffUsername })
            )
            #Switch determines the 'location' of the user, to set site specific OU paths and groups.
            Switch ( $user.staffSite ) {
                #Italy site.
                I {
                    $city = 'Italy'
                    #List of AD Groups.
                    $groups = ('')
                    #Switch to apply specific AD Groups dependant on staff type, i.e. HR/Finance.
                    switch ( $user.StaffCategoryType ) {
                        HR { 
                            $path = 'OU=Italy-HR,DC=contoso,DC=org'
                            #Additional groups as required.
                            $groups += '' 
                        }
                        Finance { 
                            $path = 'OU=Italy-Fin,DC=contoso,DC=org'
                            #Additional groups as required.
                            $groups += '' 
                        }
                    }
                }
                #Spain site.
                S {
                    $city = 'Spain'
                    #List of AD Groups.
                    $groups = ('')
                    #Switch to apply specific AD Groups dependant on staff type, i.e. HR/Finance.
                    switch ( $user.StaffCategoryType ) {
                        HR { 
                            $path = 'OU=Spain-HR,DC=contoso,DC=org'
                            #Additional groups as required.
                            $groups += '' 
                        }
                        Finance { 
                            $path = 'OU=Spain-Fin,DC=contoso,DC=org'
                            #Additional groups as required.
                            $groups += '' 
                        }
                    }
                }
            }
            #New-ADUser to create the new account, setting all account fields where possible
            #Modify string as required to suit SQL output.
            New-ADUser -Server contoso.org `
                -SamAccountName $StaffSamName `
                -GivenName $user.staffpreferred `
                -Surname $user.staffsurname `
                -DisplayName $user.staffnameexternal `
                -Name $user.StaffNameExternal `
                -City $city `
                -AccountPassword $SecurePassword `
                -Description $user.staffid `
                -Enabled 1 `
                -OtherAttributes @{'extensionattribute1' = 'staff'; 'extensionattribute2' = 'A5' } `
                -Path $Path `
                -UserPrincipalName $stafffutureemail `
                -EmailAddress $NewStaffEmail
            #Adds the user to all relevant groups defined through the location switches preceeding.
            foreach ($group in $groups) {
                Add-ADGroupMember -Server 'contoso.org' `
                    -Identity $group `
                    -Members $StaffSAMName
            }
            #Adds the user to all relevant groups defined through the location switches preceeding.
            foreach ($group in $groups) {
                Add-ADGroupMember -Server 'contoso.org' `
                    -Identity $group `
                    -Members $NewStaffUsername
            }
        }
    }
}
Stop-Transcript