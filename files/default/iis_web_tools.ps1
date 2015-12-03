$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
. $scriptPath\common.ps1
. $scriptPath\virtualdirs.ps1
. $scriptPath\webapps.ps1
. $scriptPath\websites.ps1
. $scriptPath\pools.ps1
. $scriptPath\webprops.ps1
