# Test Module using Dynamic Parameters. 
# Allowing module to work with anyones modified SDP instance.

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
        [Parameter(Mandatory = $False)]
        [string]$ServerURL = (Get-Content 'C:\SDP\SandboxURL.txt'),
        [Parameter(Mandatory = $False)]
        [string]$apikey = (Get-Content 'C:\SDP\Sandbox.key')
    )
    DynamicParam {
        #SQL Block to get all values into a Var
        $QueryTimeout = 120
        $ConnectionTimeout = 30
        $Dynamic_Values = @{}

        $Query = 'SELECT * FROM [StatusDefinition] WHERE ISDELETED = 0'

        $conn = New-Object System.Data.SqlClient.SQLConnection
        $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName, $DatabaseName, $ConnectionTimeout
        $conn.ConnectionString = $ConnectionString
        $conn.Open()
        $cmd = New-Object system.Data.SqlClient.SqlCommand($Query, $conn)
        $cmd.CommandTimeout = $QueryTimeout
        $ds = New-Object system.Data.DataSet
        $da = New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
        [void]$da.fill($ds)
        $conn.Close()

        switch ($Query) {
            {$query -like '*StatusDefinition*'} {
                $Status = $ds.Tables[0].Rows.StatusName
                $Dynamic_Values.Status += $Status 
            }
            Default {}
        }

        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        # Parameter 'Status'
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $false
        #$ParameterAttribute.Position = 0
        $AttributeCollection.Add($ParameterAttribute)
        [string[]]$arrSet = $Dynamic_Values.Status
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
        $AttributeCollection.Add($ValidateSetAttribute)
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter('Status', [string[]], $AttributeCollection)
        $RuntimeParameterDictionary.Add('Status', $RuntimeParameter)
        #
        return $RuntimeParameterDictionary
    }
    begin {
        [string[]]$Status = $PSBoundParameters['Status']
        Write-Output $Status -NoEnumerate
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