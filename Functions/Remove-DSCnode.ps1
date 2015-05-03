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
