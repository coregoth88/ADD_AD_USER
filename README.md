# ADD_AD_USER
PowerShell Script for adding AD users to specified groups.
PREREQUISITES:
1. Create the following local directory on the system you are running the script from: 'C:\ERRORS'. Errors the script generates will be staged here
2. Set your PowerShell Execution Policy to 'RemoteSigned'. To do this first open PowerShell with Admin rights to the system, type in 'Get-ExecutionPolicy'
if it returns with 'RemoteSigned' you are good to go. If not, type in 'Set-ExecutionPolicy -ExecutionPolicy RemoteSigned'
3. Install the Active Directory module for PowerShell on the system you run this script from. First, see if it is installed by typing 'Import-Module ActiveDirectory'
then type in 'Get-Module' to see if ActiveDirectory is listed. If not, type in 'Install-Module ActiveDirectory' and approval at any prompts given
4. Finally, you must run this script using your AD account that has the permissions needed to be able to add users to AD groups

NOTE ON HELP:
I have built in a 'help' portion into this script. 
To see that, in your PowerShell window type in 'help C:\PATHtoSCRIPT\ADD_BULK_AD_USER.ps1 -full' and it will return the help documentation I wrote for this script
