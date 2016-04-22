function Add-DSCconfig
{ 
[cmdletbinding()]
Param(
    [string]$Name
    ,
    [string]$Description
    ,
    [System.Version]$Build
    ,
    [ValidateSet("Development","Test","QA","Production")]
    [string]$Environment
    ,
    [pscustomobject[]]$Attributes
    ,
    [pscustomobject[]]$Role
    ,
    [string]$Document
    ,
    [string[]]$Tag
)

    $guid = [guid]::NewGuid().Guid
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"

    $Config = $null
    $Config = Get-DSCconfig -Name "$Name"

    if($Config)
    { 
        throw "DSC configuration with name '$Name' already exists"
    }

    if(-not $Build)
    {
        $Build = [System.Version]::Parse("1.0.0.0")
    }

    $newConfig = [pscustomobject]@{ 
        Name        = $Name
        Description = $Description
        Build       = $Build
        Environment = $Environment
        Attributes  = $Attributes
        Role        = $Role
        Tag         = $Tag
        Dokument    = $Document
        Guid        = $guid
    }

    Save-DSCdata -Type Configuration -object $newConfig
    
    Write-Verbose -Message "$f - END"
    return $newConfig
}