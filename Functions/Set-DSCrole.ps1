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