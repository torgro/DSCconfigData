function Add-DSCattribute
{ 
[cmdletbinding()]
Param(
    [string]$Name
    ,
    $Value
    ,
    [String]$Type
    ,
    [String]$Description
)
    $guid = [guid]::NewGuid().Guid

    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$F - START"

    $attrib = $null
    $attrib = Get-DSCattribute -Name $Name

    if($attrib)
    { 
        throw "Attribute with name '$Name' already exists"
    }

    $newAttribute = [pscustomobject]@{ 
        Name = $Name
        Value = $Value
        Type = $Type
        Guid = $guid
        Description = $Description
    }

    Save-DSCdata -Type Attribute -object $newAttribute

    return $newAttribute
}

function Add-DSCnode
{
<#
.SYNOPSIS 
    Adds a node to the collection
.Description
    Specify the name of the node to add. By default it adds an Role property and sets the value to "".
.Parameter Name
    Name of the node to be added.
.Parameter Name
    The role of the node beeing added
.EXAMPLE
    Add-DSCnode -Name Server1
.EXAMPLE
    Add-DSCnode -Name Server1 -Role "Web"
.Notes
    NAME: Add-DSCnode 
    AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
    LASTEDIT: April 2014 
    KEYWORDS: DSC scripting and tooling
    HELP:OK
#>
[cmdletbinding()]
Param(
        [Parameter(Mandatory=$true)]
        [string] $Name
        ,
        [String] $Role = ""
)
    if($configData.AllNodes.nodename -contains $Name)
    {
        throw "Node already exists"
    }

    $nodeHash = @{NodeName = $Name;
                  Role = $Role;
    }

    $configData.AllNodes += $nodeHash
}

function Add-DSCproperty
{
<#
.SYNOPSIS 
    Add a property to a node or NonNodeData property
.Description
    You can target a node, all nodes or specify the NonNodeData section. If you specify the nodename "*" 
    as a target, all nodes will have the variable, howver you can override this by setting the same
    property on a specific node. 
.Parameter NonNodeData
    Switch parameter to indicate that the property is to be added to the NonNodeData section
.Parameter Name
    The name of the property
.Parameter Value
    The value to assign to the property
.Parameter NodeName
    The name of the node we want to assign the property to
.EXAMPLE
    Add-DSCproperty -Name ADsiteName -Value NorwaySite
    
    Adds a property called ADsiteName to each node in the allnodes array and sets the value to NorwaySite
.EXAMPLE
    Add-DSCproperty -Name DNSserver -Value resolve.contoso.com -NonNodeData

    Adds a property called DNSserver to the NonNodeData section of the configdata variable
.EXAMPLE
    Add-DSCproperty -Name DNSserver2 -Value resolveit.contoso.com -NodeName Server1

    Adds a property called DNSserver2 to the node named Server1
.Notes
    NAME: Add-DSCproperty 
    AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
    LASTEDIT: April 2014 
    KEYWORDS: DSC scripting and tooling
    HELP:OK
#>
[cmdletbinding()]
Param(
        [switch] $NonNodeData
        ,
        [Parameter(Mandatory=$true)]
        [string] $Name
        ,
        [string] $Value
        ,
        [string] $NodeName
)
    if($NonNodeData)
    {
        Write-Verbose "Adding property to the NonNodeSection"
        $configData.NonNodeData.Add($Name,$value)
    }
    else
    {
        if($NodeName)
        {
            Write-Verbose "Finding node $NodeName"
            $node = $configData.allnodes | where {$_.nodename -eq $NodeName}
            
            if($node -ne $null)
            {
                Write-Verbose "Adding property to node"
                $node.add($name,$Value)
            }
            else
            {
                throw "Node does not exist, please create the node first"
            } 
        }
        else
        {
            Write-Verbose "Adding property to each node"
            $configData.AllNodes | foreach {
                if($_.NodeName -ne "*")
                {
                    $_.add($Name,$value)
                }
            }
        }
    }

}

function Add-DSCrole
{ 
[cmdletbinding()]
Param(
    [string]$Name
    ,
    [string]$Description
    ,
    [pscustomobject[]]$Attributes
)
    $guid = [guid]::NewGuid().Guid
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"

    $role = $null
    $role = Get-DSCrole -Name "$Name"

    if($role)
    { 
        throw "Role with name '$Name' already exists"
    }

    $newRole = [pscustomobject]@{ 
        Name = $Name
        Description = $Description
        Attributes = $Attributes
        Guid = $guid
    }

    Save-DSCdata -Type Role -object $newRole
    
    Write-Verbose -Message "$f - END"
    return $newRole
}

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

function Get-DSCattribute
{ 
[cmdletbinding()]
Param(
    [string]$Name
    ,
    [Parameter(ParameterSetName="ByGUID")]
    [String]$Guid
)
BEGIN
{ 
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
    $attributes = Get-DSCdata -Type Attribute
}

PROCESS
{ 
    if ($attributes)
    { 
        if ($Guid)
        {
            Write-Verbose -Message "$f -  Searching by GUID"
            $attributes | where GUID -eq $Guid
        }
        else
        {
            Write-Verbose -Message "$f -  Searching by Name"
            if(-not $Name)
            {
                $Name = "*"
            }
            $attributes | where Name -like "$Name"
        }        
    }
    else
    { 
        Write-Verbose -Message "$f -  No attributes found"
    }
}

END
{ 
    Write-Verbose -Message "$f - END"
}
}

function Get-DSCConfigData
{
<#
.SYNOPSIS 
    Returns a configurationData object
.Description
    By default it contains a node called "*" and an empty NonNodeData element
    
.EXAMPLE
    Get-DSCConfigData 

    Name                           Value
    ----                           -----
    AllNodes                       {System.Collections.Hashtable}
    NonNodeData                    {}
.Notes
    NAME: Get-DSCConfigData 
    AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
    LASTEDIT: April 2014 
    KEYWORDS: DSC scripting and tooling
    HELP:OK
#>
[cmdletbinding()]
Param(

)
    $configData
}

function Get-DSCdata
{ 
[cmdletbinding()]
Param(
    [validateset("Attribute","DSCnode","Role","Configuration")]
    [string]$Type
)
    $DataRoot = "$env:ProgramData\DSCconfig"
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"

    if(-not(Test-Path -Path "$DataRoot\Attribute"))
    { 
        New-Item -Path "$DataRoot\Attribute" -ItemType directory        
    }

    if (-not(Test-Path -Path "$DataRoot\DSCnode"))
    { 
        New-Item -Path "$DataRoot\DSCnode" -ItemType directory
    }

    if (-not(Test-Path -Path "$DataRoot\Role"))
    { 
        New-Item -Path "$DataRoot\Role" -ItemType directory
    }

    if (-not(Test-Path -Path "$DataRoot\Configuration"))
    { 
        New-Item -Path "$DataRoot\Configuration" -ItemType directory
    }

    $data = "$DataRoot\$Type\$Type.json"
    if ((Test-Path -Path "$data"))
    { 
        [string]$json = Get-Content -Path $Data -Encoding UTF8
        Write-Verbose -Message "$f -  Returning data for $Type at '$data'"
        if(-not $json)
        {
            Write-Verbose -Message "$f -  Unable to find content in file '$data', no items saved to disk"
            return $null
        }
        $json | ConvertFrom-Json
    }
    else
    { 
        Write-Verbose -Message "$f -  No data found"
    }

    Write-Verbose -Message "$f - END"
}

function Get-DSCNode
{
<#
.SYNOPSIS 
    Get the properties of a node
.Description
    No data is returned if Name is not specified
.Parameter Name
    Name of the node to retreive the properties for
.EXAMPLE
    Get-DSCNode -Name Server1

    Name                           Value
    ----                           -----
    NodeName                       Server1
    Role

    Properties for Node called Server1
.Notes
    NAME: Get-DSCNode
    AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
    LASTEDIT: April 2014 
    KEYWORDS: DSC scripting and tooling
    HELP:OK
#>
[cmdletbinding()]
Param(
        [string] $Name
)
    if($Name)
    {
        $configData.allnodes | where {$_.nodename -eq $Name}
    }
    else
    {
        $configData.allnodes
    }
}

function Get-DSCrole
{
[cmdletbinding()]
Param(
    [string]$Name
    ,
    [Parameter(ParameterSetName="ByGUID")]
    [String]$Guid
)
BEGIN
{ 
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
    $roles = Get-DSCdata -Type Role
}

PROCESS
{ 
    if ($roles)
    { 
        if ($Guid)
        {
            Write-Verbose -Message "$f -  Searching by GUID"
            $roles | where GUID -eq $Guid
        }
        else
        {            
            if(-not $Name)
            {
                $Name = "*"
            }
            Write-Verbose -Message "$f -  Searching by Name '$Name'"
            $roles | where Name -like "$Name"
        }        
    }
    else
    { 
        Write-Verbose -Message "$f -  No roles found"
    }
}

END
{ 
    Write-Verbose -Message "$f - END"
}
}

function Get-Node
{
[cmdletbinding()]
Param(
    [string]$Name
    ,
    [Parameter(ParameterSetName="ByGUID")]
    [String]$Guid
)
BEGIN
{ 
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
    $Nodes = Get-DSCdata -Type DSCnode
}

PROCESS
{
    if($Nodes)
    {
        if($Guid)
        {
            Write-Verbose -Message "$f -  Searching by GUID"
            $Nodes | where guid -eq $Guid
        }
        else
        {
            if(-not $Name)
            {
                $Name = "*"
            }
            Write-Verbose -Message "$f -  Searching by Name '$Name'"
            $Nodes | where Name -like "$Name"
        }
    }
    else
    { 
        Write-Verbose -Message "$f -  No nodes found"
    }
}

END
{ 
    Write-Verbose -Message "$f - END"
}
}

function Remove-DSCattribute
{
[cmdletbinding()]
Param(
    [Parameter(
        ParameterSetName="ByObject",
        ValueFromPipeline=$true
    )]
    [pscustomobject[]]$Attribute
    ,
    [Parameter(ParameterSetName="ByName")]
    [string]$Name
    ,
    [Parameter(ParameterSetName="ByGUID")]
    [string]$guid
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$F - START"

    if ($Guid)
    {         
        $Attribute = Get-DSCattribute -Guid $Guid
    }
}

PROCESS
{
    foreach($dscAttrib in $Attribute.GetEnumerator())
    {
        Write-Verbose -Message "$f -  Removing item with name '$($dscAttrib.Name)'"
        Save-DSCdata -Type Attribute -object $dscAttrib -Delete
    }
}

END
{
    Write-Verbose -Message "$f - END"
}
}

function Remove-DSCnode
{
<#
.SYNOPSIS 
    Removes a node from the collection
.Description
    Specify the name of the node to remove  
.Parameter Name
    Name of the node to be removed
.EXAMPLE
    Remove-DSCnode -Name Server1
.Notes
    NAME: Remove-DSCnode 
    AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
    LASTEDIT: April 2014 
    KEYWORDS: DSC scripting and tooling
    HELP:OK
#>
[cmdletbinding()]
Param(
        [string] $Name
)
    $configData.allnodes = $configData.allnodes | where {$_.Nodename -notcontains $name}
}


function Remove-DSCrole
{
[cmdletbinding()]
Param(
    [Parameter(
        ParameterSetName="ByObject",
        ValueFromPipeline=$true
    )]
    [pscustomobject[]]$Role
    ,
    [Parameter(ParameterSetName="ByName")]
    [string]$Name
    ,
    [Parameter(ParameterSetName="ByGUID")]
    [string]$guid
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$F - START"

    if ($Guid)
    {         
        $Role = Get-DSCrole -Guid $Guid
    }
}

PROCESS
{
    foreach($dscrole in $role.GetEnumerator())
    {
        Write-Verbose -Message "$f -  Removing item with name '$($dscrole.Name)'"
        Save-DSCdata -Type Role -object $dscrole -Delete
    }
}

END
{
    Write-Verbose -Message "$f - END"
}
}

function Remove-Node
{
[cmdletbinding()]
Param(
    [Parameter(
        ParameterSetName="ByObject",
        ValueFromPipeline=$true
    )]
    [pscustomobject[]]$Node
    ,
    [Parameter(ParameterSetName="ByName")]
    [string]$Name
    ,
    [Parameter(ParameterSetName="ByGUID")]
    [string]$guid
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$F - START"

    if ($Guid)
    {         
        $Node = Get-Node -Guid $Guid
    }
}

PROCESS
{
    foreach($dscNode in $Node.GetEnumerator())
    {
        Write-Verbose -Message "$f -  Removing item with name '$($dscNode.Name)'"
        Save-DSCdata -Type DSCnode -object $node -Delete
    }
}

END
{
    Write-Verbose -Message "$f - END"
}
}

function Save-DSCdata
{
[cmdletbinding()]
Param(
    [validateset("Attribute","DSCnode","Role","Configuration")]
    [string]$Type
    ,
    $object
    ,
    [switch]$Update
    ,
    [switch]$Delete
)
    $DataRoot = "$env:ProgramData\DSCconfig"
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"

    if(-not (Test-Path -Path $DataRoot))
    { 
        Write-Verbose -Message "$F -  Creating base directory structure"
        $null = Get-DSCdata -Type $Type
    }

    Write-Verbose -Message "$f -  Getting stored data of type $Type"
    $TypeData = Get-DSCdata -Type $Type

    $DataArray = New-Object -TypeName System.Collections.ArrayList
    Write-Verbose -Message "$f -  Adding stored items to array"
    foreach($dataitem in $TypeData)
    {
        [void]$DataArray.Add($dataitem)
    }
    
    if($Update)
    {
        Write-Verbose -Message "$f -  In update mode for item with GUID $($object.GUID)"
        
        $UpdateItem = $DataArray | where GUID -eq $object.GUID
        
        if(-not $UpdateItem)
        {
            throw "Unable to DELETE item $($object.Name) was not found"
        }

        Write-Verbose -Message "$f -  Updating item"
        $i = 0
        foreach($item in (Get-DSCdata -Type $Type))
        {
            if($item.guid -eq $object.guid)
            {
                Write-Verbose -Message "$f-  Found match - new type is $($object.type)"
                $DataArray[$i] = $object
            }
            $i++
        }       
    }

    if($Delete)
    {
        Write-Verbose -Message "$f -  In DELETE mode for item with GUID $($object.GUID)"

        $DeleteItem = $DataArray | where GUID -eq $object.GUID

        if(-not $DeleteItem)
        {
            throw "Unable to DELETE item $($object.Name) was not found"
        }

        Write-Verbose -Message "$f -  Deleting item"

        $DataArray = $DataArray | where GUID -ne $object.GUID
    }

    if(-not $Update -and -not $Delete)
    {
        Write-Verbose -Message "$f -  Adding new item to array"
        [void]$DataArray.Add($object)
    }   

    Write-Verbose -Message "$f -  Converting array of items to JSON"
    $jsonContent = $DataArray | ConvertTo-Json
    Write-Verbose -Message "$f -  Saving to '$DataRoot\$Type\$Type.json'"
    Set-Content -Path "$DataRoot\$Type\$Type.json" -Value $jsonContent
    Write-Verbose -Message "$f -  Saved to $DataRoot\$Type\$Type.json"
    Write-Verbose -Message "$F - END"
}

function Set-AllowClearTextPassword
{
<#
.SYNOPSIS 
    Adds a property to allow clear text password in your DSC
.Description
    Can be targeted at the node level or for all nodes
.Parameter AllNodes
    If set, applies the clear text password for all nodes
.Parameter NodeName
    If set, applies the clear text password for a specific node
.EXAMPLE
    Set-AllowClearTextPassword -AllNodes
    Enables clear text password for all nodes
.EXAMPLE
    Set-AllowClearTextPassword -NodeName Server1
    Enables clear text passwords for the node Server1
.Notes
    NAME: Set-AllowClearTextPassword 
    AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
    LASTEDIT: April 2014 
    KEYWORDS: DSC scripting and tooling
    HELP:OK
#>
[cmdletbinding()]
Param(
        [Parameter(ParameterSetName="AllNodes")]
        [switch] $AllNodes
        ,
        [Parameter(ParameterSetName="SingleNode")]
        [string] $NodeName = ""
        ,
        [switch] $Disabled
)
    [bool]$ClearTextAllowed = $true
    if($Disabled)
    {
        $ClearTextAllowed = $false
    }
    
    if($AllNodes)
    {
        Write-Verbose "Setting cleartextpasswords allowed for all nodes"
        $configData.AllNodes[0].add("PSDscAllowPlainTextPassword", $ClearTextAllowed)
    }

    If($NodeName -ne "")
    {
        Write-Verbose -Message "Searhing for node with name '$NodeName'"
        $node = $configData.AllNodes | Where {$_.NodeName -eq $NodeName}
        Write-Verbose "Did we find a node?"
        if($node -ne $null)
        {
            Write-Verbose "Setting cleartextpasswords allowed for node $NodeName"
            $node.add("PSDscAllowPlainTextPassword", $ClearTextAllowed)
        }
        else
        {
            throw "Error - node $nodename not found"
        }
    }
}


function Set-DSCattribute
{ 
[cmdletbinding()]
Param(
    [Parameter(
        ParameterSetName="ByObject",
        ValueFromPipeline=$true
    )]
    [pscustomobject[]]$Attribute
    ,
    [Parameter(ParameterSetName="ByGUID")]
    [String]$Guid
    ,
    [String]$Type
    ,
    [String]$Description
)
BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
    if ($Guid)
    { 
        $Attribute = Get-DSCattribute -Guid $Guid
    }
}

PROCESS
{
    foreach($Attrib in $Attribute)
    {
        Write-Verbose -Message "$f -  Processing item $($Attrib.Name)"
        if($Type)
        {
            $Attrib.Type = $Type
        }

        if($Description)
        {
            $Attrib.Description = $Description
        }
        Save-DSCdata -Type Attribute -Update -object $Attrib
    }
}

END
{
    Write-Verbose -Message "$f - END"
}
}

function Set-DSCrole
{ 
[cmdletbinding()]
Param(
    [Parameter(
        ParameterSetName="ByName",
        ValueFromPipeline=$true
    )]
    [pscustomobject[]]$Role
    ,
    [Parameter(ParameterSetName="ByGUID")]
    [String]$Guid
    ,
    [string]$Description
    ,
    [pscustomobject[]]$Attributes
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
    if($Guid)
    {
        $Role = Get-DSCrole -Guid $Guid
    }
}

PROCESS
{ 
    foreach ($DSCrole in $Role)
    { 
        Write-Verbose -Message "$f -  Processing item $($DSCrole.Name)"
        if ($Description)
        { 
            $DSCrole.Description = $Description
        }

        if ($Attributes)
        { 
            foreach($attrib in $Attributes)
            {
                if($attrib -in $DSCrole.Attributes.guid)
                {
                    Write-Error "Role already have an attribute with name '$attrib.Name'"
                }
                else
                {
                    $DSCrole.Attributes += $attrib
                }
            }            
        }
        Save-DSCdata -Type Role -object $DSCrole -Update
    }
}

END
{
    Write-Verbose -Message "$f - END"
}
}

function Set-Node
{ 
[cmdletbinding()]
Param(
    [Parameter(
        ParameterSetName="ByName",
        ValueFromPipeline=$true
    )]
    [pscustomobject[]]$Node
    ,
    [Parameter(ParameterSetName="ByGUID")]
    [String]$Guid
    ,
    [string]$Description
    ,
    [pscustomobject[]]$Attributes
    ,
    [pscustomobject]$Role
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
    if($Guid)
    {
        $Node = Get-Node -Guid $Guid
    }
}

PROCESS
{ 
    foreach ($DSCnode in $Node)
    { 
        Write-Verbose -Message "$f -  Processing item '$($DSCnode.Name)'"
        if ($Description)
        { 
            $DSCnode.Description = $Description
        }

        if ($Attributes)
        { 
            foreach($attrib in $Attributes)
            {
                if($attrib.guid -in $DSCnode.Attributes.guid)
                {
                    Write-Error "Node already have an attribute with name '$attrib.Name'"
                }
                else
                {
                    $DSCnode.Attributes += $attrib
                }
            }   
        }

        if ($Role)
        {
            $DSCnode.Role = $Role
        }
        Save-DSCdata -Type DSCnode -object $DSCnode -Update
    }
}

END
{
    Write-Verbose -Message "$f - END"
}
}

$Module = "DSCconfigData"

$configData = @{
    AllNodes = @()
    NonNodeData=@{}
    }

$configData.AllNodes += @{NodeName = "*"}


