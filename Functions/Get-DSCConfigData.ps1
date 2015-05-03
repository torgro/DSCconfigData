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