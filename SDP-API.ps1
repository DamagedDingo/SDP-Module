

function Add-APINotes {
    <#
.DESCRIPTION
    Used to set notes on a ticket via a Custom Script API Call.
    WARNING: Please be aware that there is a limitation on the amount of characters that the 'Action Executor' field can support.
.PARAMETER ServerURL
    Service Desk Plus API Key defaults to 'C:\SDP\SandboxURL.txt' or you can provide a plain text version.
.PARAMETER apikey
    Service Desk Plus API Key defaults to 'C:\SDP\Sandbox.key' or you can provide a plain text version.
.PARAMETER RequestID
    Request ID of the ticket to modify pulled from the imported JSON data provided by Service Desk Plus
.PARAMETER NoteContents
    Plain text that will be added to the body of the note, or you can use a feild name collected from Service Desk Plus.
    Useful for writing logs to your ticket notes. i.e Script Ran 1/1/1981 - Actions taken were 'Whatever'
.EXAMPLE
    Add to 'Custom Triggers' in Service Desk Plus Admin. 
    cmd /c start /wait powershell.exe -WindowStyle Hidden -command "& { . D:\ManageEngine\ServiceDesk\integration\custom_scripts\SDP-API.ps1; Add-APINotes $COMPLETE_JSON_FILE *>> C:\SDP\Logs\Log.txt}"
.NOTES 
    Author: Gary Smith
    Date:   January 22, 2019    
#>
    [CmdletBinding()]
    param (
        [string]$JSON_path
    )
    
    begin {
        $ServerURL = Get-Content 'C:\SDP\SandboxURL.txt'
        $apikey = Get-Content 'C:\SDP\Sandbox.key'

        $JSON_data = Get-Content $JSON_path
        $JSON_data = $JSON_data | ConvertFrom-Json
        $RequestID = $JSON_data.request.WORKORDERID

        # $NoteContents can be changed to the name of the field
        # that you wish to use to populate the note or plain text as needed.
        $NoteContents = $JSON_data.request."Choose Software"
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
        Invoke-WebRequest -Uri "$ServerURL/sdpapi/request/$RequestID/notes" -Method POST -Body $postparams -Verbose #>
    }
    
    end {
    }
}

function Export-JSON {
    <#
.DESCRIPTION
    Sample function to export the $COMPLETE_JSON_FILE to text. 
.PARAMETER JSON_path
    $COMPLETE_JSON_FILE is passed into the function and saved as $JSON_path. $JSON_path is then used to get the contents of the file.
.EXAMPLE
    Add to 'Custom Triggers' in Service Desk Plus Admin. 
    cmd /c start /wait powershell.exe -WindowStyle Hidden -command "& { . D:\ManageEngine\ServiceDesk\integration\custom_scripts\SDP-API.ps1; Export-JSON $COMPLETE_JSON_FILE *>> C:\SDP\Logs\JSON.txt}"
.NOTES 
    Author: Gary Smith
    Date:   January 22, 2019    
#>
    [CmdletBinding()]
    param (
        [string]$JSON_path
    )
    
    begin {
        $JSON_data = Get-Content $JSON_path
    }
    
    process {
        $JSON_data
    }
    
    end {
    }
}