function Resolve-Ticket {
    <#
.DESCRIPTION
    Used to set Resolution content and set the ticket status.
    Must have all default fields completed first i.e Group/Technician/Status
.PARAMETER ServerURL
    Service Desk Plus API Key defaults to 'C:\SDP\SandboxURL.txt' or you can provide a plain text version.
.PARAMETER apikey
    Service Desk Plus API Key defaults to 'C:\SDP\Sandbox.key' or you can provide a plain text version.
.PARAMETER RequestID
    Request ID of the ticket to modify
.PARAMETER Resolution
    The plain text resolution to add to the ticket
.PARAMETER Status
    Validated set currently supports "Resolved", "Closed".
.EXAMPLE
    Resolve-Ticket -Resolution "Software has been installed on users computer" -RequestID 498417 -Status Resolved
    Resolve-Ticket -Resolution "Software has been installed on users computer" -RequestID 498417 -Status Resolved -Verbose *> "C:\SDP\Logs\Log.txt"
    Resolve-Ticket -Resolution "Duplicate Request" -RequestID 498417 -Status Closed -ServerURL "http://Servicedesk.Plus:8080" -apikey "54C597FC-D5EF-4214-BB2E-65CA0890132C"
.NOTES
    Author: Gary Smith
    Date:   January 22, 2019    
#>
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
        Invoke-WebRequest -Method PUT -Uri $URI -UseBasicParsing -Verbose
    }
    
    end {
    }
}

function Set-Group_Tech {
    <#
.DESCRIPTION
    Used to set the Group and the Technician.
.PARAMETER ServerURL
    Service Desk Plus API Key defaults to 'C:\SDP\SandboxURL.txt' or you can provide a plain text version.
.PARAMETER apikey
    Service Desk Plus API Key defaults to 'C:\SDP\Sandbox.key' or you can provide a plain text version.
.PARAMETER RequestID
    Request ID of the ticket to modify
.PARAMETER Group
    Enter the Group name to assign the ticket to.
.PARAMETER Technician
    Enter the Technician name to assign the ticket to.
.EXAMPLE
    Set-Group_Tech -RequestID 498412 -Group "Service Desk" -Technician "John Doe"
    Set-Group_Tech -RequestID 498412 -Group "Service Desk" -Technician "John Doe" -Verbose *> "C:\SDP\Logs\Log.txt"
    Set-Group_Tech -RequestID 498412 -Group "Service Desk" -Technician "John Doe" -ServerURL "http://Servicedesk.Plus:8080" -apikey "54C597FC-D5EF-4214-BB2E-65CA0890132C"
.NOTES
    Author: Gary Smith
    Date:   January 22, 2019    
#>
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
        Invoke-WebRequest -Method PUT -Uri $URI -UseBasicParsing -Verbose
        #$API_response = Invoke-WebRequest -Method PUT -Uri $URI -UseBasicParsing -Verbose
        #$API_response_object = $API_response | ConvertFrom-Json
    }
    
    end {
    }
}

function Add-Notes {
    <#
.DESCRIPTION
    Used to set add notes to tickets.
.PARAMETER ServerURL
    Service Desk Plus API Key defaults to 'C:\SDP\SandboxURL.txt' or you can provide a plain text version.
.PARAMETER apikey
    Service Desk Plus API Key defaults to 'C:\SDP\Sandbox.key' or you can provide a plain text version.
.PARAMETER RequestID
    Request ID of the ticket to modify
.PARAMETER NoteContents
    Plain text that will be added to the body of the note
.EXAMPLE
    Add-Notes -RequestID 498412 -NoteContents "Automatic Script was run to add software to computer ComputerName."
    Add-Notes -RequestID 498412 -NoteContents "Automatic Script was run to add software to computer ComputerName." -Verbose *> "C:\SDP\Logs\Log.txt"
    Add-Notes -RequestID 498412 -NoteContents "Automatic Script was run to add software to computer ComputerName."
.NOTES
    Author: Gary Smith
    Date:   January 22, 2019    
#>
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
        #$API_response = Invoke-WebRequest -Uri "$ServerURL/sdpapi/request/$RequestID/notes" -Method POST -Body $postparams -Verbose
        Invoke-WebRequest -Uri "$ServerURL/sdpapi/request/$RequestID/notes" -Method POST -Body $postparams -Verbose
    }
    
    end {
    }
}









