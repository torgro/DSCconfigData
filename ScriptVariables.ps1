$Module = "DSCconfigData"

$configData = @{
    AllNodes = @()
    NonNodeData=@{}
    }

$configData.AllNodes += @{NodeName = "*"}