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
