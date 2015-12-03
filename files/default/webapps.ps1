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

# Function to check if web application exists
function Webapp-Exists
{
  [CmdletBinding(SupportsShouldProcess=$true)]														
  param
  (
  [Parameter(Mandatory=$true)]
  [string] $name,
  [Parameter(Mandatory=$true)]
  [string] $site
  
  )	

  write-host "Checking for Web Application Existence"
  
  $test = Get-WebApplication -site $site -name $name
  if ($test -eq $null)
  {
    Write-Host "Web Application $name doesn't Exist"
    return $false
  }	
  Write-Host "Web Application $name Exists"
  return $true
}

# function to create new web application
function New-WebApp
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $name,
  [Parameter(Mandatory=$true)]
  [string] $site, 				#Example: Demosite or can be the web path such as Demopath/Demodir 
  [Parameter(Mandatory=$true)]
  [string] $pool,
  [Parameter(Mandatory=$true)]
  [string] $path,
  [Parameter(Mandatory=$true)]
  [AllowEmptyString()]
  [hashtable] $myhash
  )
  try 
  {
    #There is a bug in Windows code (2008 R2)that when you create a New-WebApplication, it will not create a New-WebVirtualDirectory
    #To reproduce try the following sequence:
    #New-WebApplication -name "Test1" -site "Default Web Site" -physicalpath "C:\temp" -ErrorAction stop
    #Get-WebApplication
    #Get-WebVirtualDirectory #<- Notice how your Test1 folder is NOT listed
    
    #Now try the following:
    #New-WebVirtualDirectory -Name "Test2" -Site "Default Web Site" -PhysicalPath "C:\temp"        
    #ConvertTo-WebApplication -ApplicationPool "DefaultAppPool" -PSPath "IIS:\Sites\Default Web Site\Test2"
    #Get-WebApplication
    #Get-WebVirtualDirectory #<- Notice how your Test2 folder is listed
    
    #So now we have a dilemma.  We need to create the Virtual Directory with a different name because how you access both WebApps and Virtual directories is the same
    #IIS:\Site\SITE_NAME\VDIR_NAME
    #IIS:\Site\SITE_NAME\WEB_APP_NAME
    #For now I dont think we have any other choice but to not allow an end user to manage the virtual directory side of the IIS Web Application.  This eliminates items like setting the logon method for
    #the web application.  It can be controlled at the pool level, but we need to understand if end users need to control this setting, this will be a big change.  Also to be clear, this is not an issue
    #for virtual directories INSIDE the WebApplication, only for the directory where the WebApplication itself resides.
    
    
    #If we want to allow properties like "logonMethod" to be changed we would need to use the below 2 lines instead but would need another name for the virtual dir - like WANAME_virtdir
    #Implementation to allow both WebApp and Virtual dir to coexist       
    #New-WebVirtualDirectory -Name $name -Site $site -PhysicalPath $path 
    #ConvertTo-WebApplication -applicationpool $pool -PSPath "IIS:\Sites\$site\$name"
    
    #TODO (if we use the lines to allow bow webapp and virtual dir) the Delete-Webapp  would need to be updated to delete the Webapp and the virtual dir
    #found another bug where VirtualDir always requires the AppName.
    
    
    write-host "Creating new Web Application"
    $newpath=Get-NormalizedPath -path $path
    $returnedWebApp=New-WebApplication -name $name -site $site -applicationpool $pool -physicalpath $newpath -ErrorAction stop	 
    Config-Property -path "IIS:\Sites\$site\$name" -myhash $myhash
    
    write-host "Finished new Web Application"
    return $true
  }
  catch
  {
    write-error -exception ($_.Exception) -erroraction continue;
    return $false
  }
}

#Function to Delete Web Application
function Delete-Webapp
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $site,
  [Parameter(Mandatory=$true)]
  [string] $name		
  )
  
  try
  {
    write-host " Deleting Web App $name"
    Remove-WebApplication -site $site -name $name -ErrorAction stop
    write-host "Finished Deleting Web App off of site $site and App $name"
    Return $true
  }
  catch
  {
    write-error -exception ($_.Exception) -erroraction continue;
    Return $false
  }
}	

function Check-WebappProperties
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

function Config-Webapp
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
  