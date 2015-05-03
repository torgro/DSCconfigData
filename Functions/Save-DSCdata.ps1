function Save-DSCdata
{
[cmdletbinding()]
Param(
    [validateset("Attribute","DSCnode","Role","Configuration")]
    [string]$Type
    ,
    $object
    ,
    [switch]$Update
)
    $DataRoot = "$env:ProgramData\DSCconfig"
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"

    if(-not (Test-Path -Path $DataRoot))
    { 
        Write-Verbose -Message "$F -  Creating base directory structure"
        $null = Get-DSCdata -Type $Type
    }

    Write-Verbose -Message "$f -  Getting stored data of type $Type"
    $TypeData = Get-DSCdata -Type $Type

    $DataArray = New-Object -TypeName System.Collections.ArrayList
    Write-Verbose -Message "$f -  Adding stored items to array"
    foreach($dataitem in $TypeData)
    {
        [void]$DataArray.Add($dataitem)
    }
    
    if($Update)
    {
        Write-Verbose -Message "$f -  In update mode for item with GUID $($object.GUID)"
        
        $UpdateItem = $DataArray | where GUID -eq $object.GUID
        
        if(-not $UpdateItem)
        {
            throw "Unable to update item $($object.Name) was not found"
        }

        Write-Verbose -Message "$f -  Updating item"
        $i = 0
        foreach($item in (Get-DSCdata -Type $Type))
        {
            if($item.guid -eq $object.guid)
            {
                Write-Verbose -Message "$f-  Found match - new type is $($object.type)"
                $DataArray[$i] = $object
            }
            $i++
        }       
    }
    else
    {
         Write-Verbose -Message "$f -  Adding new item to array"
        [void]$DataArray.Add($object)
    }   

    Write-Verbose -Message "$f -  Converting array of items to JSON and saving to '$DataRoot\$Type\$Type.json'"
    $DataArray | ConvertTo-Json | Set-Content -Path "$DataRoot\$Type\$Type.json"
    Write-Verbose -Message "$f -  Saved to $DataRoot\$Type\$Type.json"
    Write-Verbose -Message "$F - END"
}