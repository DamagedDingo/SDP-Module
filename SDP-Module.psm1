
function Resolve-Ticket {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Resolution,
        [Parameter(Mandatory = $true)]
        [Int]$RequestID,
        [Parameter(Mandatory = $true)]
        [ValidateSet("Resolved", "Closed")]
        [string]$Status,
        [Parameter(Mandatory = $False)]
        [string]$ServerURL = (Get-Content 'C:\SDP\SandboxURL.txt'),
        [Parameter(Mandatory = $False)]
        [string]$apikey = (Get-Content 'C:\SDP\Sandbox.key')
    )
    
    begin {
        $LogFolder = "C:\Script_logs\$RequestID"
        $LogFileName = "$RequestID.Resolve-Ticket"

        $LogFolderTest = test-path $LogFolder
        If (!$LogFolderTest) {
            New-Item -ItemType Directory -Path $LogFolder
        }
        $LogFile = "$LogFolder\$LogFileName.txt"

        Write-Output "New Log Started:" (Get-Date) | Out-File -FilePath $LogFile -Append
        Write-Output "Begin Resolve-Ticket API Call"  | Out-File -FilePath $LogFile -Append
    }
    
    process {
        $inputData = @"
{
    "request": {
        "resolution": {
            "content": "$Resolution"
        },
        "status": {
            "name": "$Status"
        }
    }
}
"@
        $URI = $ServerURL + "/api/v3/requests/$RequestID" + "?TECHNICIAN_KEY=$ApiKey&input_data=$inputdata&format=json"
        $API_response = Invoke-WebRequest -Method PUT -Uri $URI -UseBasicParsing
    }
    
    end {
        Write-Output $API_response | Out-File -FilePath $LogFile -Append
        Write-Host "End Resolve-Ticket API Call`n"  | Out-File -FilePath $LogFile -Append
    }
}


function Set-Group_Tech {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Int]$RequestID,
        [Parameter(Mandatory = $true)]
        [string]$Group,
        [Parameter(Mandatory = $true)]
        [string]$Technician,
        [Parameter(Mandatory = $False)]
        [string]$ServerURL = (Get-Content 'C:\SDP\SandboxURL.txt'),
        [Parameter(Mandatory = $False)]
        [string]$apikey = (Get-Content 'C:\SDP\Sandbox.key')
    )
    
    begin {
        $LogFolder = "C:\Script_logs\$RequestID"
        $LogFileName = "$RequestID.Set-Group_Tech"

        $LogFolderTest = test-path $LogFolder
        If (!$LogFolderTest) {
            New-Item -ItemType Directory -Path $LogFolder
        }
        $LogFile = "$LogFolder\$LogFileName.txt"

        Write-Output "New Log Started:" (Get-Date) | Out-File -FilePath $LogFile -Append
        Write-Output "Begin: Set Group and Technician API Call:" | Out-File -FilePath $LogFile -Append
    }
    
    process {
        $inputData = @"
{
    "request": {
        "group": {
            "name": "$Group"
        },
        "technician": {
            "name": "$Technician"
        }
    }
}
"@
        $URI = $ServerURL + "/api/v3/requests/$RequestID/assign?TECHNICIAN_KEY=$ApiKey&input_data=$inputdata&format=json"
        $API_response = Invoke-WebRequest -Method PUT -Uri $URI -UseBasicParsing
        $API_response_object = $API_response | ConvertFrom-Json
    }
    
    end {
        Write-Output "Status_code: $($API_response_object.response_status.messages.status_code)" | Out-File -FilePath $LogFile -Append 
        Write-Output "Message: $($API_response_object.response_status.messages.message)" | Out-File -FilePath $LogFile -Append 
        Write-Output "Result: $($API_response_object.response_status.messages.type)" | Out-File -FilePath $LogFile -Append 
        Write-Output "End: Set Group and Technician API Call:`n" | Out-File -FilePath $LogFile -Append 
    }
}


function Add-Notes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Int]$RequestID,
        [Parameter(Mandatory = $true)]
        [string]$NoteContents,
        [Parameter(Mandatory = $False)]
        [string]$ServerURL = (Get-Content 'C:\SDP\SandboxURL.txt'),
        [Parameter(Mandatory = $False)]
        [string]$apikey = (Get-Content 'C:\SDP\Sandbox.key')
    )
    
    begin {
        $LogFolder = "C:\Script_logs\$RequestID"
        $LogFileName = "$RequestID.Add-Notes"

        $LogFolderTest = test-path $LogFolder
        If (!$LogFolderTest) {
            New-Item -ItemType Directory -Path $LogFolder
        }
        $LogFile = "$LogFolder\$LogFileName.txt"

        Write-Output "New Log Started:" (Get-Date) | Out-File -FilePath $LogFile -Append
        Write-Output "Begin: Add Notes API v1 Call:" | Out-File -FilePath $LogFile -Append
    }
    
    process {
        $inputData = @"
<API version='1.0' >
<Operation>
    <Details>
        <Notes>
            <Note>
                <parameter>
                    <name>isPublic</name>
                    <value>true</value>
                </parameter>
                <parameter>
                    <name>notesText</name>
                    <value>$NoteContents</value>
                </parameter>
            </Note>
        </Notes>
    </Details>
</Operation>
</API>
"@
        $postparams = @{OPERATION_NAME = 'ADD_NOTE'; TECHNICIAN_KEY = $apikey; INPUT_DATA = $inputData; FORMAT = 'XML'}
        $API_response = Invoke-WebRequest -Uri "$ServerURL/sdpapi/request/$RequestID/notes" -Method POST -Body $postparams
       
    }
    
    end {
        Write-Output "$($API_response.content)" | Out-File -FilePath $LogFile -Append
        Write-Output "End: Add Notes API v1 Call:`n" | Out-File -FilePath $LogFile -Append 
    }
}









