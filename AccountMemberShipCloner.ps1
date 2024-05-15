function Copy-ADPrincipalGroupMembership{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$OriginalUserName,
        [Parameter(Mandatory)]
        [string]$RecievingUserName,
        [Parameter(Mandatory)]
        [string]$Server,
        [Parameter()]
        [switch]$Replace
    )

    try{
        
        $OriginalUser=Get-ADPrincipalGroupMembership -Identity $OriginalUserName -Server $Server
        $RecievingUser=Get-ADPrincipalGroupMembership -Identity $RecievingUserName -Server $Server

        <#This set of if, and elseif detec if you are passing a groups or a user#>
        if($OriginalUser -and $RecievingUser){
            $CompareResults=Compare-Object -ReferenceObject $OriginalUser -DifferenceObject $RecievingUser -Property SamAccountName
            $Adds=$CompareResults | Where-Object SideIndicator -eq "<="
            $Removes=$CompareResults | Where-Object SideIndicator -eq "=>"
        }elseif($OriginalUserName){
            $Adds=$OriginalUser
            $Removes=$null
        }elseif($RecievingUser){
            $Removes=$RecievingUser
            $Adds=$null
        }

        <#Add and remove necesary groups#>
        if($Adds){
            foreach($Add in $Adds){
                Write-Debug "Adding $RecievingUserName to group $($Add.SamAccountName)"
                Add-ADGroupMember -Identity $Add.SamAccountName -Members $RecievingUserName -Server $Server
            }
        }

        <#if you use parameter -replace it will delete the groups that user recivier have re#>
        if($Replace){
            if($Removes){
                foreach($Remove in $Removes){
                    Write-Debug "Removing $RecievingUserName from group $($Remove.SamAccountName)"
                    Remove-ADGroupMember -Identity $Remove.SamAccountName -Members $RecievingUserName -Server $Server -Confirm:$false
            }
        }
        
}
    }catch{
        Write-Error $_.Exception.Message
    }
}
<#debug option is to show throught terminal what is the script doing#>
Copy-ADPrincipalGroupMembership -OriginalUserName "TestUser1" -RecievingUserName "TestUser2" -Server "wservertest.local" -Replace -Debug

