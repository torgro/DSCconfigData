function Add-Node
{ 
[cmdletbinding()]
Param(
    [string]$Name
    ,
    [string]$Description
    ,
    [pscustomobject[]]$Attributes
    ,
    [pscustomobject]$Role
)
    $guid = [guid]::NewGuid().Guid
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"

    $Node = $null
    $Node = Get-Node -Name "$Name"

    if($Node)
    { 
        throw "Node with name '$Name' already exists"
    }

    $newNode = [pscustomobject]@{ 
        Name = $Name
        Description = $Description
        Attributes = $Attributes
        Guid = $guid
        Role = $Role
    }

    Save-DSCdata -Type DSCnode -object $newNode
    
    Write-Verbose -Message "$f - END"
    return $newNode
}