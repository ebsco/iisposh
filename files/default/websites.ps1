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

# function to check if website exists
function Website-Exists
{
  [CmdletBinding(SupportsShouldProcess=$true)]														
  param
  (
  [Parameter(Mandatory=$true)] 
  [string] $name
  )
  
  write-host "Checking for Website Existence"
  $test = Test-path IIS:\Sites\$name
  if ($test -eq $false)
  {
    Write-Host "Website Doesn't Exist"
    return $false
  }	
  Write-Host "Website Exists"
  return $true
}


# Function to create new website
function New-Iisweb																					
{
  [CmdletBinding(SupportsShouldProcess=$true)]
  param(
  [Parameter(Mandatory=$true)] 
  [string] $name,
  [Parameter(Mandatory=$true)]
  [AllowEmptyString()]
  [hashtable] $myhash,
  [Parameter(Mandatory=$true)]
  [AllowEmptyCollection()]
  [array] $bindings
  
  )
  
  Write-Host "Creating new Website $name" -ForegroundColor Yellow 
  
  try {
    
    #http://forums.iis.net/post/1912661.aspx
    #MSBUG - when no websites exist
    $id = (dir iis:\sites | foreach {$_.id} | sort -Descending | select -first 1) + 1
    
    $newweb = New-Website -Name $name -id $id -ErrorAction stop					
    Write-Host " - Success" -ForegroundColor Green 
    Write-Host " "
    
    #Function to configure Website
    $myret=Configure-Website -name $name -myhash $myhash -bindings $bindings
    
    #Start Website after Configuration? - Should we be doing this automatically for users?
    Change-State -name $name -website -start
    
    write-host "Finished new Web Site creation"
    return $true
  }
  catch
  {
    write-error -exception ($_.Exception) -erroraction continue;
    return $false
  }
}

# Configure properties for each object
function Configure-Website
{
  [CmdletBinding(SupportsShouldProcess=$true)]
  param(
  [Parameter(Mandatory=$true)]
  [string] $name,
  [Parameter(Mandatory=$true)]
  [AllowEmptyString()]
  [hashtable] $myhash,
  [Parameter(Mandatory=$true)]
  [AllowEmptyCollection()]
  [array] $bindings
  
  )
  
  Write-Host "Beginning to configure-website"
  $mynullreturn=Config-Property -path "IIS:\Sites\$name" -myhash $myhash
  
  #No bindings means use default binding which most of the time is port 80 for the website.  Highly suggest not doing that
  if($bindings.Count -gt 0){
    $mynullreturn=Set-Bindings -name $name -bindings $bindings
  }
  else{
    write-host "Skipping setting bindings due to no bindings specified"
  }
  
  write-host "Finished  Configuring web site"
  
  if(Check-WebSiteProperties -name $name -myhash $myhash -bindings $bindings){
    return $true
  }
  else{
    return $false
  }
}


function Check-WebSiteProperties
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $name,
  [Parameter(Mandatory=$true)]
  [AllowEmptyString()]
  [hashtable]$myhash,
  [Parameter(Mandatory=$true)]
  [AllowEmptyCollection()]
  [array] $bindings
  
  )
  write-host "Performing check of Website Properties"
  
  $result1= Check-Properties -path "IIS:\Sites\$name" -myhash $myhash
  if(!$result1){
    write-host "Properties were incorrect"
    return $false
  }
  
  #If bindings is empty - dont check them
  if($bindings.Count -gt 0){
    $result2= Check-Bindings -name $name -bindings $bindings
    if(!$result2){
      write-host "Bindings were incorrect"
      return $false
    }
  }
  else{
    write-host "Skipping Checking Bindings due to no bindings specified"
  }
  
  return $true
}


#Function to Delete Website
function Delete-Website
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $name
  )
  
  try
  {
    write-host "Deleting Web Site $name"
    Change-State -name $name -website -stop
      
    Remove-Website -name $name -ErrorAction stop
    write-host "Finished deleting Web Site $name"
    Return $true
  }
  catch
  {
    write-error -exception ($_.Exception) -erroraction continue;
    Return $false
  }
}	


#Function to configure website bindings
function Set-Bindings 
{
#Example:set-bindings -name "demosite3" -bindings @(,("http", "9092", "", ""))
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $name,
  [Parameter(Mandatory=$true)]
  [array] $bindings
  
  )
  
    $testbindings = Check-BindingLength -bindings $bindings
    if(!$testbindings){
      throw "Detected bindings LENGTH was incorrect"
    }
  

  try{
    #MAJOR MS BUG - https://connect.microsoft.com/PowerShell/feedback/details/969458/get-webbinding-results-in-error-after-running-remove-webbinding-without-params
    #We dont call get-webbinding again until after bindings are created so this is ok, BUT we need to handle the use case coded below, what happens if no bindings exist on the website.
    #Get-Webbinding| remove-webbinding
    
    $bindingscurrent=@(Get-Webbinding -name $name )
    if($bindingscurrent -ne $null){
      foreach($curbind in $bindingscurrent){
        write-host "Removing current binding: $($curbind.ToString())"
        remove-webbinding -Name $name  -BindingInformation $curbind.bindingInformation -protocol $curbind.Protocol
      }
    }
  }
  catch [System.Management.Automation.PSArgumentException]{
    write-host "Detected no current bidnings exist on website"
  }

  write-host ""
  write-host "Setting up bindings for $name"  


  foreach ($item in $bindings)
  {
    write-host ""
    $protocol = $item[0]
    $port = $item[1]
    $header = $item[2]
    $ip = $item[3]

    if ($ip -eq "" -or $ip -eq $null)
    {
      $ip = "*"
    }
    if($header -eq $null)
    {
      $header=""
    }
    if($port -eq $null){
      $port=""
    }
    
    write-host "Binding info":
    write-host "Protocol: $protocol"
    write-host "port: $port"
    write-host "header: $header"
    write-host "IP: $ip"

    
    if ($header -eq "" -or $header -eq $null)
    {
      write-host "New-Webbinding -name $name -protocol $protocol -port $port -ipaddress $ip"
      New-Webbinding -name $name -protocol $protocol -port $port -ipaddress $ip
    }
    else
    {
      write-host "New-Webbinding -name $name -protocol $protocol -port $port -hostheader $header -ipaddress $ip"
      New-Webbinding -name $name -protocol $protocol -port $port -hostheader $header -ipaddress $ip
    }
    write-host "Successfully Created binding" -ForegroundColor Green
    write-host ""
  }
  
  write-host "Finished setting up bindings for $name"  
}

#Function to check if Bindings are set as requested
function Check-Bindings
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $name,
  [Parameter(Mandatory=$true)]
  [array] $bindings
  
  )
  
  $testbindings = Check-BindingLength -bindings $bindings
  if(!$testbindings){
    throw "Detected bindings LENGTH was incorrect"
  }
  
  
  write-host "Checking Bindings for $name"  
  $checker=$true
  foreach ($item in $bindings)
  {
    $protocol = $item[0]
    $port = $item[1]
    $header = $item[2]
    $ip = $item[3]
    $test = Get-WebBinding -Name $name -Port $port -HostHeader $header -IPAddress $ip
    if (!$test)
    {
      $checker= $false
      break;
    }		
  }
  write-host "Finished checking for bindings."
  write-host "Bindings for $name, are equal?- $checker"  
  return $checker
}

#Check-BindingLength -bindings ('http', '80', "","")
#Check-BindingLength -bindings @(,("a", "b", "c", "d"))
function Check-BindingLength{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [array] $bindings
  )
  write-host "Checking Binding Length"
  if($bindings.Count -eq 0){
    throw "No binding fed into method"
  }
  
  foreach ($item in $bindings)
  {
    if($item.GetType().IsArray){
      #TODO - Make sure each item inside is a primitive (int, string, etc).
      if ($item.length -ne 4){
        write-host "Detected array length was not 4, but was instead : $($item.length)"
        return $false
      }
      else{
        write-host "Array of correct length"
      }
    }
    else{
      throw "Detected passed in parameter is not an array is of type : $($item.GetType())"
    }
  }
  return $true
}
