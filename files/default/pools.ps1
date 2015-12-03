################################################################################
###
###	Script Name: iis_web_tools.ps1
###	Author: Darrell Johnson
###	Date 3/23/2015
###	Description: Includes functions to create and configure websites, apppools, virtual directories, and web applications
###
###
#################################################################################
Import-Module webadministration

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
. $scriptPath\common.ps1


# function to check if application pool exists
function Pool-Exists
{
  [CmdletBinding(SupportsShouldProcess=$true)]														
  param
  (
  [Parameter(Mandatory=$true)]
  [string] $name
  )
  write-host "Checking for Web App Pool Existence"
  
  #Todo - Make sure this is actually a pool.  See Delete-Virtualdir for example
  $test = Test-path IIS:\AppPools\$name
  if ($test -eq $false)
  {
    Write-Host "Application Pool Doesn't Exist: $name"
    return $false
  }	
  Write-Host "Application Pool Exists: $name"
  return $true
}


# Function to create new application pool
function New-Pool
{
  [CmdletBinding(SupportsShouldProcess=$true)]
  param(
  [parameter(mandatory=$true,valueFromPipeline=$true)]
  [string]$name,
  [Parameter(Mandatory=$true)]
  [AllowEmptyString()]
  [hashtable]$myhash
  )
  try {	
    
    Write-Host "Creating new App Pool $name" -ForegroundColor Yellow
    $newpool = New-WebAppPool -Name $name -ErrorAction stop	
    Write-Host " - Success" -ForegroundColor Green 
    Write-Host " "
    # Call Function to Configure Application pool
    Config-Property -path "IIS:\AppPools\$name" -myhash $myhash
    Change-State -name $name -pool -start
    
    write-host "Finished new App Pool"
    return $true
  }
  catch
  {
    write-error -exception ($_.Exception) -erroraction continue;
    return $false
  }
}

#
function Check-PoolProperties
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $name,
  [Parameter(Mandatory=$true)]
  [AllowEmptyString()]
  [hashtable]$myhash
  
  )
  return Check-Properties -path "IIS:\AppPools\$name" -myhash $myhash
}

function Config-Pool
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $name,
  [Parameter(Mandatory=$true)]
  [AllowEmptyString()]
  [hashtable]$myhash
  
  )
  return Config-Property -path "IIS:\AppPools\$name" -myhash $myhash
}
  
  
#function to delete application pool
function Delete-Pool
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $name		
  )
  
  try
  {
    write-host "Deleting App Pool $name"
    Change-State -name $name -pool -stop
      
    Remove-WebAppPool -name $name -ErrorAction stop
    write-host "Finished Deleting App Pool $name"
    Return $true
  }
  catch
  {
    write-error -exception ($_.Exception) -erroraction continue;
    Return $false
  }
}	
