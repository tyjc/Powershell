# Function to write log messages to a dated text file
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,  # The message text to log

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$LogFilePath = "C:\\Scripts\\IntuneLogs",  # Default log directory path

        [Parameter()]
        [ValidateSet('Information', 'Warning', 'Error')]
        [string]$Level = "Information"  # Message severity level
    )

    # Create the log directory if it doesn't already exist
    if (!(Test-Path $LogFilePath)) {
        New-Item -Path $LogFilePath -ItemType Directory -Force | Out-Null
    }

    # Create a log filename with the current date
    $date = Get-Date -Format "MM-dd-yyyy"
    $logFile = Join-Path $LogFilePath "log-$date.txt"

    # Capture the current time for the log entry
    $timeStamp = Get-Date -Format "HH:mm:ss"

    # Format the log entry string
    $logEntry = "$timeStamp [$Level] - $Message"

    # Try to write the log entry to the file, and handle any errors
    try {
        Add-Content -Path $logFile -Value $logEntry -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to write to log file: $_"
    }
}

# Initial log entry indicating start of the process
Write-Log -Message "Attempting to upload device details to SnipeIT..."

# Table mapping model names to their SnipeIT Model ID numbers
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

# Attempt to get detailed system information and handle failure
try {
    $ComputerInfo = Get-ComputerInfo -ErrorAction Stop
}
catch { 
    Write-Log -Message "Failed to get computer information" -Level Error
    break
}

# Log progress message
Write-Log -Message "Creating hashtable of device details"

# Create a hashtable with device details for SnipeIT upload
$ComputerDetails = @{
    name         = $computerInfo.CsName                  # Computer name
    manufacturer = $computerInfo.CsManufacturer          # Manufacturer name
    model_id     = $computerInfo.CsModel                 # Model name (to be replaced with SnipeIT ID)
    serial       = $computerInfo.BiosSeralNumber         # BIOS serial number
    status_id    = 4                                     # Default asset status in SnipeIT
    notes        = 'Uploaded via IntuneScript'           # Note for record tracking
}

# Log that the hashtable is created
Write-Log -Message "Hashtable created"

# Log that model ID replacement process is starting
Write-Log -Message "Replacing computer model name with internal Snipe ID"

# Loop through the model replacement table and replace model names with corresponding SnipeIT IDs
foreach ($object in $ReplaceTable) {
    $ReplaceTable.GetEnumerator() | % {
        $ComputerDetails.model_id = $ComputerDetails.model_id -replace $_.Key, $_.Value
    }
}

# Log start of API request preparation
Write-Log -Message "Building API POST request..."

# Convert hashtable to JSON format for API request body
$hashbody = $ComputerDetails | ConvertTo-Json

# Build the HTTP headers for the SnipeIT API call
$headers = @{}
$headers.Add("accept", "application/json")
$headers.Add("Authorization", "Bearer Token")  # Placeholder for actual SnipeIT API token
$headers.Add("content-type", "application/json")

# Log before sending POST request
Write-Log -Message "Attempting to POST to SnipeIT..."

# Perform the POST request to upload data to SnipeIT
$response = Invoke-WebRequest -Uri 'http://inventory.sjs.local/api/v1/hardware' -Method POST -Headers $headers -ContentType 'application/json' -Body $hashbody

# Log the response code and description for verification
Write-Log -Message "Response code: $($response.StatusCode) Response Description: $($response.StatusDescription)"
