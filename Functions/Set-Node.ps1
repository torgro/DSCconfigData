function Set-Node
{ 
[cmdletbinding()]
Param(
    [Parameter(
        ParameterSetName="ByName",
        ValueFromPipeline=$true
    )]
    [pscustomobject[]]$Node
    ,
    [Parameter(ParameterSetName="ByGUID")]
    [String]$Guid
    ,
    [string]$Description
    ,
    [pscustomobject[]]$Attributes
    ,
    [pscustomobject]$Role
)

BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
    if($Guid)
    {
        $Node = Get-Node -Guid $Guid
    }
}

PROCESS
{ 
    foreach ($DSCnode in $Node)
    { 
        Write-Verbose -Message "$f -  Processing item '$($DSCnode.Name)'"
        if ($Description)
        { 
            $DSCnode.Description = $Description
        }

        if ($Attributes)
        { 
            foreach($attrib in $Attributes)
            {
                if($attrib.guid -in $DSCnode.Attributes.guid)
                {
                    Write-Error "Node already have an attribute with name '$attrib.Name'"
                }
                else
                {
                    $DSCnode.Attributes += $attrib
                }
            }   
        }

        if ($Role)
        {
            $DSCnode.Role = $Role
        }
        Save-DSCdata -Type DSCnode -object $DSCnode -Update
    }
}

END
{
    Write-Verbose -Message "$f - END"
}
}