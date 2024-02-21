##API request to schoolbase for list of current pupils, with ADSName, which in our institution holds on premise email

$domain = 'SchoolbaseDomain'
$token = 'API Token'
$uri = 'RequestUri'

$postparams = @{'x-schoolbase-domain'='$domain';'x-schoolbase-token'='$token'}

$response = Invoke-RestMethod -Uri $uri -Method POST -Headers $postparams

$response | select PupilADSName,FirstName,LastName | Export-Csv
