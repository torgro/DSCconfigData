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