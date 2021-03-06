﻿function Add-DSCrole
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