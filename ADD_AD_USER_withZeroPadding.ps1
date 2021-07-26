<#
.SYNOPSIS
This script takes in a list of AD users from a .txt file and takes in a AD group name.
It then attempts to find the AD user by both EID and SAN. 
It then attempts to add them to the AD group specified.
Finally if there are any errors finding the SAN, it will generate a log file on the local system here: C:\ERRORS\MyErrors.txt

.DESCRIPTION
This script takes in a list of AD users from a .txt file and takes in a AD group name.
It then attempts to find the AD user by both EID and SAN. 
It then attempts to add them to the AD group specified.
Finally if there are any errors finding the SAN, it will generate a log file on the local system here: C:\ERRORS\MyErrors.txt

Use the 'pathToFile' parameter to point to the file that contains the list of AD user IDs. 
Use the 'AdGroupName' parameter to point to the AD group name the users need to be added to.
You will need to create this directory on the system you run this on: C:\ERRORS a error log will be generated here.
Audit the log file in the above location after running the script, to confirm all users were added.
NOTE: 
When you audit, just visually compare any users in the errors file with members in the group. They could have been added by EID, but confirm.

.PARAMETER Path 
Used to specify the location of the file containing the list of users to place in the desired group.

.EXAMPLE
PS C:\Scripts> .\AD_USER_ADD.ps1 -pathToFile C:\Users.txt -adGroupName VPNUsers

The above example will add all the users in the 'Users.txt' file to the 'VPNUsers' security group; if 'VPNUsers' is a valid group name.
#> 

param (
    [Parameter(Mandatory=$True)]$pathToFile,
    [Parameter(Mandatory=$True)]$adGroupName
)

#Variables
[System.Collections.ArrayList]$newListOfIds = @()
[System.Collections.ArrayList]$employeeIdArrayList = @()
[System.Collections.ArrayList]$samIdArrayList = @()

#confirms file is a .txt file, exits with error message if not, imports content into variable if it is
if ($pathToFile -like '*.txt'){
    $listofIds = Get-Content -Path $pathToFile
} else {
    Write-Host "File must be a .txt file! Try again."
    Exit
}

#tests the group name to confirm it is valid, if not it exits with an error message.
Try{
    $isokay = $True
    $silent = Get-ADGroup $adGroupName -ErrorAction Continue
} Catch {
    $isokay = $false
}
if ($isokay -eq $false) {
    Write-Host "Group name is not valid. Please run script again and supply a valid group name."
    Exit
}
<#checks to see if the id in the list is a number and also less than 6 characters long; if both are true, it pads zeros
to the front of the number until it is 6 characters long. (Example: 1234 would become 001234.); else it just adds it, as is.#>
foreach ($_ in $listofIds) {
    if ($_.Length -lt 6 -and $_ -match '[0-9]') {
        $newValue1 = $_.PadLeft(6,'0')
        $newListOfIds.Add($newValue1)
    } else {
        $newListOfIds.Add($_)
    }
}
#cleans up the ERRORS folder
Remove-Item C:\ERRORS\* -Force -Recurse

#matches content in the .txt file to an AD User with that EmployeeID and adds it to an arraylist
foreach ($_ in $newListOfIds) {
    $employeeId  = Get-ADUser -Filter 'EmployeeID -like $_'
    $employeeIdArrayList.Add($employeeId)  
}
#matches content in the .txt file to an AD User with that SAMAccountName and adds it to an arraylist
#puts any errors in a MyErrors.txt file for review
foreach ($_ in $newListOfIds) {
    try {
        $samIDVar = Get-ADUser $_ -ErrorAction Stop -ErrorVariable x
        $samIdArrayList.Add($samIDVar)
    }     
    catch {
        $Myerror = "SAMId Error: $x"
        $Myerror | Out-File -FilePath C:\ERRORS\MyErrors.txt -Append
    }
}
#for every AD user account in the EID array list, tries to add it to the group specified. Errors go to the MyErrors.txt file for review.
foreach ($_ in $employeeIdArrayList) {
    try {
        Add-ADGroupMember -Identity $adGroupName -Members $_ -ErrorAction Stop -ErrorVariable y
    }
    catch {
        $Myerror1 = "SAMId Error: $y"
        $Myerror1 | Out-File -FilePath C:\ERRORS\MyErrors.txt -Append
    }
}
#for every AD user account in the SAMID array list, tries to add it to the group specified. Errors go to the MyErrors.txt file for review.
foreach ($_ in $samIdArrayList) {
    try {
        Add-ADGroupMember -Identity $adGroupName -Members $_ -ErrorAction Stop -ErrorVariable z
    }
    catch {
        $Myerror2 = "SAMId Error: $z"
        $Myerror2 | Out-File -FilePath C:\ERRORS\MyErrors.txt -Append
    }
}
#test changes