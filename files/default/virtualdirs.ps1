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

# Function to check if Virtual Directory Exists
function Virtualdir-Exists
{
  [CmdletBinding(SupportsShouldProcess=$true)]														
  param
  (
  [Parameter(Mandatory=$true)]
  [string] $name
  
  )	
  write-host "Checking for Virtual Directory Existence"
  
  $test = Get-WebVirtualDirectory -Name $name 
  if ($test -eq $null)
  {
    Write-Host "Virtual Directory $name doesn't Exist"
    return $false
  }	
  Write-Host "Virtual Directory $name Exists"
  return $true
}

#function to create new virtual directory
function New-Virtualdir
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $name,
  [Parameter(Mandatory=$true)]
  [string] $site,					#Example: Demosite or can be the web path such as Demopath/Demodir 
  [Parameter(Mandatory=$true)]
  [string] $path,
  [Parameter(Mandatory=$true)]
  [AllowEmptyString()]
  [hashtable] $myhash
  )
  try
  {
    write-host "Creating new Virtual Directory"
    $newpath=Get-NormalizedPath -path $path
    $returnedvdir=New-WebVirtualDirectory -Name $name -Site $site -PhysicalPath $newpath 
    $myret=Config-VDir -name $name -site $site -myhash $myhash
    write-host "Finished new Virtual Directory"
    return $true
  }
  catch
  {
    write-error -exception ($_.Exception) -erroraction continue;
    return $false
  }


}

#Function to delete Virtual Directory
function Delete-Virtualdir
{
#[CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $name,
  [Parameter(Mandatory=$true)]
  [string] $site		
  )

  try
  {
    write-host "Deleting Web Virtual Directory $name"

    foreach($item in gci IIS:\Sites\$site)
    {
      if($item.Name -eq $name){

        if($item.ElementTagName -eq "virtualDirectory"){
          Remove-Item IIS:\Sites\$site\$name -recurse -ErrorAction stop
          write-host "Finished deleting Web Virutal Directory $name"
          Return $true
        }
        else{
          throw "Found that the item trying to be deleted is not a virtual directory but is a : $($item.ElementTagName)"
        }

      }
    }
  }
  catch
  {
    write-error -exception ($_.Exception) -erroraction continue;
    Return $false
  }
}	


function Check-VDirProperties
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $name,
  [Parameter(Mandatory=$true)]
  [string] $site,
  [Parameter(Mandatory=$true)]
  [AllowEmptyString()]
  [hashtable]$myhash
  
  )
  return Check-Properties -path "IIS:\Sites\$site\$name" -myhash $myhash
}

function Config-VDir
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $name,
  [Parameter(Mandatory=$true)]
  [string] $site,
  [Parameter(Mandatory=$true)]
  [AllowEmptyString()]
  [hashtable]$myhash
  
  )
  return Config-Property -path "IIS:\Sites\$site\$name" -myhash $myhash
}
  