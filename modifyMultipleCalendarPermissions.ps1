#path to CSV of users to modify
$filepath = \path\to\users.csv

#Username of individual being granted access to mailboxes
$User = "user name"

#Role to be given to $User eg Editor, Reviewer, PublishingAuthor
#Full list: https://docs.microsoft.com/en-us/powershell/module/exchange/add-mailboxfolderpermission?view=exchange-ps
$Role = 

Import-Csv -Path $filepath | ForEach-Object {
    #uncomment valid line below to modify or add as required.

    #add permissions where none existed
    #Add-MailboxFolderPermission -Identity ($_.name + ':\Calendar') -User $User -AccessRights $Role

    #edit permissions where some existed
    #Set-MailboxFolderPermission -Identity ($_.name + ':\Calendar') -User $User -AccessRights $Role
}