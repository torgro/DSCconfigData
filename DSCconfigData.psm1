$Module = "DSCconfigData"

$configData = @{
    AllNodes = @()
    NonNodeData=@{}
    }

$configData.AllNodes += @{NodeName = "*"}

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
        [switch] $AllNodes
        ,
        [string] $NodeName = ""
)
    if($AllNodes -and $NodeName -ne "")
    {
        throw "Only specify a node or use the AllNode switch, not both"
    }
    
    if($AllNodes -and $NodeName -eq "")
    {
        Write-Verbose "Setting cleartextpasswords allowed for all nodes"
        $configData.AllNodes[0].add("PSDscAllowPlainTextPassword",$true)
    }

    If($NodeName -ne "")
    {
        $node = $configData.AllNodes | Where {$_.NodeName -eq $NodeName}
        Write-Verbose "Did we find a node?"
        if($node -ne $null)
        {
            Write-Verbose "Setting cleartextpasswords allowed for node $NodeName"
            $node.add("PSDscAllowPlainTextPassword",$true)
        }
        else
        {
            throw "Error - node $nodename not found"
        }
    }
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

Export-ModuleMember -Function * -Variable ConfigData