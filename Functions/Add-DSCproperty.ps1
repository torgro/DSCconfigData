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