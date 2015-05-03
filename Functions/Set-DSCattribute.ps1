function Set-DSCattribute
{ 
[cmdletbinding()]
Param(
    
    [Parameter(
        ParameterSetName="ByName",
        ValueFromPipeline=$true
    )]
    [pscustomobject[]]$Attribute
    ,
    [Parameter(ParameterSetName="ByGUID")]
    [String]$Guid
    ,
    [String]$Type
    ,
    [String]$Description
)
BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
}

PROCESS
{
    foreach($Attrib in $Attribute)
    {
        Write-Verbose -Message "$f -  Processing item $($Attrib.Name)"
        if($Type)
        {
            $Attrib.Type = $Type
        }

        if($Description)
        {
            $Attrib.Description = $Description
        }
        Save-DSCdata -Type Attribute -Update -object $Attrib
    }
}

END
{
    Write-Verbose -Message "$f - END"
}
}