function Get-DSCattribute
{ 
[cmdletbinding()]
Param(
    [string]$Name
    ,
    [Parameter(ParameterSetName="ByGUID")]
    [String]$Guid
)
BEGIN
{ 
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
    $attributes = Get-DSCdata -Type Attribute
}

PROCESS
{ 
    if ($attributes)
    { 
        if ($Guid)
        {
            Write-Verbose -Message "$f -  Searching by GUID"
            $attributes | where GUID -eq $Guid
        }
        else
        {
            Write-Verbose -Message "$f -  Searching by Name"
            if(-not $Name)
            {
                $Name = "*"
            }
            $attributes | where Name -like "$Name"
        }        
    }
    else
    { 
        Write-Verbose -Message "$f -  No attributes found"
    }
}

END
{ 
    Write-Verbose -Message "$f - END"
}
}