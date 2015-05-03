function Get-DSCrole
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
    $roles = Get-DSCdata -Type Role
}

PROCESS
{ 
    if ($roles)
    { 
        if ($Guid)
        {
            Write-Verbose -Message "$f -  Searching by GUID"
            $roles | where GUID -eq $Guid
        }
        else
        {
            Write-Verbose -Message "$f -  Searching by Name"
            if(-not $Name)
            {
                $Name = "*"
            }
            $roles | where Name -like "$Name"
        }        
    }
    else
    { 
        Write-Verbose -Message "$f -  No roles found"
    }
}

END
{ 
    Write-Verbose -Message "$f - END"
}
}