function Send-Mail {
  <#
.SYNOPSIS
  Sends an email alert to notify of new user creation
.DESCRIPTION
  - Send an email from QIBITServices@qibgroup.com.au to IT.Support@qibgroup.com.au with details from a new user
.NOTES
  Version:        1.0
  Author:         Ty Collins
  Creation Date:  25/06/2022
  Future Update Plans: 
#>

  Write-Warning "
|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+DISCLAIMER|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|
##############################################################################################################
##############################################################################################################
||||||||||||||||||||||||||||||||||||   I wrote it, and it works for me.   ||||||||||||||||||||||||||||||||||||
||||||||||||||  If you run it, and don't understand it, don't blame me when you break something  |||||||||||||
##############################################################################################################
##############################################################################################################
" -WarningAction Inquire

  $MailTo = 'Recipient'
  $SMTPServer = 'smtp server for outgoing mail'
  $SmtpUser = 'outgoing mail username'
  $SmtpPassword = 'outgoing mail password'
  $Subject = 'subject line'
  #this next line forces the plaintext password above to be passed as a securestring
  $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SmtpUser, $($smtpPassword | ConvertTo-SecureString -AsPlainText -Force)
  #body below is a html object. Small table to keep the details tidy when being sent. This can be replaced with plain text.
  $Body = 
  @"
    Ther has been a new user created. You can find the details in the table below.<br><br>
    <style type="text/css">
    .tg  
    .tg td{font-family:Arial, sans-serif;font-size:14px;
      overflow:hidden;padding:10px 5px;word-break:normal;}
    .tg th{font-family:Arial, sans-serif;font-size:14px;
      font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}
    .tg .tg-on03{font-family:Arial, Helvetica, sans-serif !important;font-size:12px;text-align:left;vertical-align:top}
    .tg .tg-0lax{text-align:left;vertical-align:top}
    </style>
    <table class="tg">
    <tbody>
      <tr>
        <td class="tg-on03">Name</td>
        <td class="tg-0lax"></td>
        <td class="tg-on03">$Name</td>
      </tr>
      <tr>
        <td class="tg-on03">Role</td>
        <td class="tg-0lax"></td>
        <td class="tg-on03">$Role</td>
      </tr>
      <tr>
        <td class="tg-on03">Email</td>
        <td class="tg-0lax"></td>
        <td class="tg-on03">$Email</td>
      </tr>
      <tr>
        <td class="tg-on03">Password</td>
        <td class="tg-0lax"></td>
        <td class="tg-on03">$Password</td>
      </tr>
    </tbody>
    </table>
"@

  Send-MailMessage -To $MailTo -From $SmtpUser -SmtpServer $SMTPServer -Subject $Subject -Body $Body -Credential $Credentials -BodyAsHtml -UseSsl -Port 587
}