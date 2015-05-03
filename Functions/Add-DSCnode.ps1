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