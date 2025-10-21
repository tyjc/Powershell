function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,  # The message to log

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$LogFilePath = "C:\\Scripts\\IntuneLogs",  # Default log directory

        [Parameter()]
        [ValidateSet('Information', 'Warning', 'Error')]
        [string]$Level = "Information"  # Log level
    )

    # Create the log directory if it doesn't exist
    if (!(Test-Path $LogFilePath)) {
        New-Item -Path $LogFilePath -ItemType Directory -Force | Out-Null
    }

    # Build the log file path with current date
    $date = Get-Date -Format "MM-dd-yyyy"
    $logFile = Join-Path $LogFilePath "$ScriptName log-$date.txt"

    # Get the current timestamp for the log entry
    $timeStamp = Get-Date -Format "HH:mm:ss"

    # Create the formatted log entry
    $logEntry = "$timeStamp [$Level] - $Message"

    try {
        # Append the log entry to the file
        Add-Content -Path $logFile -Value $logEntry -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to write to log file: $_"
    }
}

$ScriptName = 'UploadToSnipe'  # Script name used in log file

# Check if the "UploadedtoSnipe" tag exists; exit if it does
if (Get-Content -Path C:\Scripts\IntuneLogs\UploadedtoSnipe.tag) {
    Write-Log -Message "Device already uploaded to Snipe, exiting"
    break
}

Write-Log -Message "Attempting to upload device details to SnipeIT..."

# Mapping of computer model names to internal SnipeIT IDs
$ReplaceTable = @{
    "OptiPlex 3020"                             = "24"
    "HP EliteDesk 800 G6 DM"                    = "10"
    "HP ProDesk 400 G3 SFF"                     = "20"
    "HP ProDesk 400 G4 SFF "                    = "31"
    "HP ProDesk 400 G5 Desktop Mini"            = "8"
    "HP ProDesk 400 G6 SFF"                     = "35"
    "HP ProDesk 400 G6 Desktop Mini PC"         = "36"
    "HP ProDesk 400 G7 Small Form Factor PC"    = "34"
    "HP Pro Mini 400 G9 Desktop PC"             = "11"
    "HP Z2 Mini G9 Workstation Desktop PC"      = "33"
    "HP Z2 Mini G9 Workstation"                 = "33"
    "HP 250 G6"                                 = "21"
    "HP 250 G6 Notebook PC"                     = "41"
    "HP 255 G8"                                 = "22"
    "HP EliteBook 850 G8 Notebook PC"           = "38"
    "HP EliteBook 1040 14 inch G10 Notebook PC" = "39"
    "HP Elite Mini 800 G9 Desktop PC"           = "40"
}       

# Attempt to retrieve local computer information
try {
    $ComputerInfo = Get-ComputerInfo -ErrorAction Stop
}
catch { 
    Write-Log -Message "Failed to get computer information" -Level Error
    break
}

Write-Log -Message "Creating hashtable of device details"

# Build a hashtable with computer details to send to SnipeIT
$ComputerDetails = @{
    name         = $computerInfo.CsName
    manufacturer = $computerInfo.CsManufacturer
    model_id     = $computerInfo.CsModel
    serial       = $computerInfo.BiosSeralNumber
    status_id    = 4
    notes        = 'Uploaded via IntuneScript'
}

Write-Log -Message "Hashtable created"

Write-Log -Message "Replacing computer model name with internal Snipe ID"

# Loop through each key-value pair in the ReplaceTable
# If the computer's model matches the key, replace it with the SnipeIT ID
foreach ($entry in $ReplaceTable.GetEnumerator()) {
    $ComputerDetails.model_id = $ComputerDetails.model_id -replace $entry.Key, $entry.Value
}

Write-Log -Message "Building API POST request"

# Convert hashtable to JSON and prepare headers for the API request
$hashbody = $ComputerDetails | ConvertTo-Json
$headers = @{}
$headers.Add("accept", "application/json")
$headers.Add("Authorization", "Bearer ---")
$headers.Add("content-type", "application/json")

Write-Log -Message "Attempting to POST to SnipeIT"

# Send the POST request to SnipeIT API
try {
    $response = Invoke-WebRequest -Uri 'http://inventory.sjs.local/api/v1/hardware' -Method POST -Headers $headers -ContentType 'application/json' -Body $hashbody
}
catch {
    Write-Log -Message "Failed to Upload to Snipe" -Level Error
    Break
}

Write-Log -Message "Setting tag to mark job complete"

# Create a file to indicate the upload was successful
Set-Content -Path "C:\\Scripts\\IntuneLogs\\UploadedtoSnipe.tag" -Value "TRUE"

# Log the response from the API
Write-Log -Message "Response code: $($response.StatusCode) Response Description: $($response.StatusDescription)"
