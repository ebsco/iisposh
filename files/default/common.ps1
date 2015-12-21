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
$SCRIPTPATH = split-path -parent $MyInvocation.MyCommand.Definition


function Get-NormalizedPath{
[CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [AllowEmptyString()]
  [Parameter(Mandatory=$true)]
  [string] $path
  )
  #Test-path breaks with an empty or null string
  if([String]::IsNullOrEmpty($path)){
    return $path
  }
  
  if(Test-path $path){
  $newpath=$path.Replace("/", [IO.Path]::DirectorySeparatorChar).TrimEnd([IO.Path]::DirectorySeparatorChar)
  write-host "Normalized Path :$newpath"
  return $newpath
  }
  else{
    return $path
  }
}


#function to configure webapp, virtualdir, and website properties
function Config-Property
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $path,
  [Parameter(Mandatory=$true)]
  [AllowEmptyString()]
  [hashtable] $myhash
  
  )
  
  write-host "Starting configuration of  $path and the properties within"
  $webobj =  $myhash
  
  foreach ($object in $webobj.keys)								
  {
    $property = $object
	$value = $webobj.Item($object)
	#Check the case sensitivity  - Windows 2012R2 properties are case sensitive
	$property = Convert-PropertyCase -property $object -path $path
    if (Iisposh-Needs-ChangedValues)
    {
      $value = Get-Changedvalue -name $object -value $value
    }
    
    #If it is a path get the normalized path
    $value=Get-NormalizedPath -path $value
    $currentvalue=Get-ItemCurrentValue -path $path -propName $property

    Write-Host "Setting $property = $value" -ForegroundColor Yellow
    Write-Host "Current Value = $currentvalue"
    
    $itemprop = Get-ItemProperty $path -Name $property	  
    if ($itemprop.ToString() -ne $value.ToString())												  	
    {
      try
      {
        Set-ItemProperty $path -Name $property -Value "$value" -ErrorAction Stop 	 
        Write-Host " - Success" -ForegroundColor Green 
        Write-Host " "
        $exitcode = $true
      }
      catch
      {
        write-error -exception ($_.Exception) -erroraction continue;
        Write-Host " - Error Setting Property" -ForegroundColor Red
        exit(1)
      }
      
    }
    else																	  
    {
      Write-Host " - Already Set" -ForegroundColor Green 					  
      Write-Host " "
    }	
  }
  
  write-host "Finished configuration of $path and the properties within"
  return $exitcode  
}

# Function to convert vlaues from string to integer in the case very powershell in Server 2008 pulls the string value but expects an integer value when setting the value
# Value will be nullif no prop names match items in iis_changelist.xml
function Get-Changedvalue
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $name,
  [string] $value
  )
  write-host "Checking if property name $name, needs a value switch"
  
  if ($name -eq "recycling.logEventOnRecycle")
  {
    $value = Get-LogEventOnRecycle -value $value
  }
  elseif ($name -eq "logfile.logExtFileFlags")
  {
    $value = Get-LogExtFileFlags -value $value
  }
  else
  {
    
    
    $xmlpath = $SCRIPTPATH + "\iis_changelist.xml"
    
    $xml = [xml](Get-Content -Path $xmlpath)
    $elements = $xml.configuration.properties.property
    foreach ($property in $elements)
    {
      $prop_name = $property.name
      
      if ($name -eq $prop_name)
      {
        $original_value = $value 			
        foreach ($element in $elements)
        {
          $element_name = $element.name
          if ($element_name -eq $prop_name)
          {
            $values = $element.value
            foreach($element_value in $values)
            {
              $stringvalue = $element_value.string
              $intvalue = $element_value.value
              switch ($value)
              {
                $stringvalue{$value = $intvalue}	
                
              }
            }
          }
        }
      }
      
      if ($value -eq $original_value)
      {
        write-error "Requested Value is not a valid option check your property values"		
        exit(1)
      }
    }
  }
  write-host "Finished property name $name evaluation, returning $value"
  
  return $value
}

# Function to get the value to set recycling.logeventonrecycle
function Get-LogEventOnRecycle
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $value
  
  )
  
  write-host "Performing Integer lookup for LogEventOnRecycle"
  $accepted_values = @(("Time",1),("Requests",2),("Schedule",4),("Memory",8),("IsapiUnhealthy",16),("OnDemand",32),("ConfigChange",64),("PrivateMemory",128))
  $retval=search-forValueInteger -inputvalues $value -acceptablevalues $accepted_values
  write-host "Finished Integer lookup for LogEventOnRecycle, output : $retval"
  
  return $retval  
  
}

function search-forValueInteger
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param(
  
  [Parameter(Mandatory=$true)]
  [string] $inputvalues,
  
  [Parameter(Mandatory=$true)]
  [array] $acceptablevalues
  )
    
  write-host "Searching accepted values for input values"
    
  $retvalue=0
  $arr_input_values = @($inputvalues -split ",")
  foreach($item in $arr_input_values)
  {
    $name = $item
    $found=$false
    foreach($it in $acceptablevalues)
    {
      if ($name -eq $it[0])
      {
        $retvalue = $retvalue + $it[1] -as [int]
         $found=$true;
       break;
      }
    }
    
    if(!$found){
      throw "Unable to find matching value for:  $name"
    }
  }
  
  write-host "Finished searching accepted values, return value: $retvalue"
  return $retvalue
}

# Function to get the value of Logfile.LogExtFileFlags
function Get-LogExtFileFlags
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $value
  
  )
  write-host "Performing Integer lookup for LogExtFileFlags"
  $accepted_values = @(("Date",1),("Time",2),("ClientIp",4),("UserName",8),("SiteName",16),("ComputerName",32),("ServerIP",64),("Method",128),("UriStem",256),("UriQuery",512),("HttpStatus",1024),("Win32Status",2048),("BytesSent",4096),("BytesRecv",8192),("TimeTaken",16384),("ServerPort",32768),("UserAgent",65536),("Cookie",131072),("Referer",262144),("ProtocolVersion",524288),("Host",1048576),("HttpSubStatus",2097152))
  $logvalue=search-forValueInteger -inputvalues $value -acceptablevalues $accepted_values
  write-host "Finished Integer lookup for LogExtFileFlags, output : $logvalue"
  
  return $logvalue
}

function Get-ItemCurrentValue
{
 [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $path,
  [Parameter(Mandatory=$true)]
  [string] $propName
  )
  $itemprop = Get-ItemProperty $path -Name $propName	   	 	 
    $currentvalue = $itemprop.value
    if ($currentvalue -eq $null)
    {
      $currentvalue = $itemprop.$propName
      if ($currentvalue -eq $null)
      {
        $currentvalue = $itemprop
      }
    }
    if($currentvalue -eq $null){
      return ""
    }
    
    return "$currentvalue"
  
}

# Function to check if properties are already set
function Check-Properties
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $path,
  [Parameter(Mandatory=$true)]
  [AllowEmptyString()]
  [hashtable] $myhash
  
  )
  write-host "Checking Properties for equality"
  
  $hashdata =  $myhash
  
  
  foreach ($object in $hashdata.keys)								
  {
    $prop = $object
    $value = $hashdata.Item($object)
    
    #If it is a path get the normalized path
    $value=Get-NormalizedPath -path $value
    
    Write-Host "Checking if $prop = $value" -ForegroundColor darkGreen 
        
    $currentvalue=Get-ItemCurrentValue -path $path -propName $prop
    
    Write-Host " : Current Value = $currentvalue"
    if ($currentvalue -ne $value.ToString())
    {
      
      return $false
    }
  }
  write-host "Finished Checking Properties for equality"
  return $true
}


#Function to change state (start/stop) Website or Application Pool
function Change-State
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $name,
  [switch] $website,
  [switch] $pool,
  [switch] $stop,
  [switch] $start  
  )
  
  $actionperformed=$false
  try
  {
    for($i=0; $i -lt 10; $i++){
      try{
        if ($website)
        {
          if ($start)
          {
            write-host "Starting WebSite"
            Start-Website -name $name -erroraction stop	
            WaitForWebsiteExpectedState -website $name -expectedState "Started"
            $actionperformed=$true
            break;
          }
          if ($stop)
          {
            write-host "Stopping WebSite"
            Stop-Website -name $name -erroraction stop	
            WaitForWebsiteExpectedState -website $name -expectedState "Stopped"
            $actionperformed=$true
            break;
          }		
        }
        if ($pool)
        {
          if ($start)
          {
            write-host "Starting WebAppPool"
            Start-WebAppPool -name $name -erroraction stop	
            WaitForPoolExpectedState -PoolName $name -expectedState "Started"
            $actionperformed=$true
            break;
          }
          if ($stop)
          {
            write-host "Stopping WebAppPool"
            $poolstate=Get-WebAppPoolState -Name $name
            if($poolstate.Value -eq "Started"){ #Cannot stop a pool that is being stopped or already stopped
              Stop-WebAppPool -name $name -erroraction stop	
            }
            WaitForPoolExpectedState -PoolName $name -expectedState "Stopped"
            $actionperformed=$true
            break;
          }		
        }
      }
      catch [Exception]{
         write-host "Warning Exception:" 
         $_.Exception | fl -property * | out-host
         
        if ($_.Exception.GetType().Name -eq "COMException") {
          write-host "Tried to change state -retrying..."
          Sleep 1 
        }
        else{
          throw
        }
      }
    }
    
    if($actionperformed){
      write-host "Finished changing State of AppPool or Website"
    }
    else{
      throw "Unable to perform desired action, maximum retry hit"
    }
  }
  catch
  {
    write-error -exception ($_.Exception) -erroraction continue;
    throw "Error: Changing Running State"
  }	
}	

#Function to get state (Started/Stopped) of Website or Application Pool
function Get-RunningState
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $name,
  [switch] $website,
  [switch] $pool		
  )
  
  if ($website)
  {
    write-host "Getting Running State of Website: $name"
    $web = Get-Website | where {$_.name -eq $name}
    $state = $web.state
    if ($state -eq "Started")
    {
      write-host "Website is Running"
      return $true
    }
    write-host "Website is NOT Running"
    return $false
  }
  if ($pool)
  {
    write-host "Getting Running State of App Pool: $name"
    $apppool = Get-WebAppPoolState -name $name
    $state = $apppool.value
    if ($state -eq "Started")
    {
      write-host "App Pool is Running"
      return $true
    }
    
    write-host "App Pool is NOT Running"
    return $false
  }
}	


#Function to restart Website of Application Pool
function Restart-Webobject
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $name,
  [switch] $website,
  [switch] $pool		
  )
  
  try
  {
    if ($website)
    {
      write-host "Restarting Website: $name"
      Change-State -name $name -website -stop
      Change-State -name $name -website -start
    }
    if ($pool)
    {
      write-host "Restarting AppPool: $name"
      Change-State -name $name -pool -stop
      Change-State -name $name -pool -start
    }
    return $true
  }
  catch
  {
    write-error -exception ($_.Exception) -erroraction continue;
    return $false
  }
}	


function Iisposh-Needs-ChangedValues
{
  $checkOS = (Get-WmiObject -Class Win32_OperatingSystem).caption
  return $checkOS -match "2008" -or $checkOS -match "Windows 7 Professional"
}


function WaitForPoolExpectedState
{
[CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $PoolName,
  [Parameter(Mandatory=$true)]
  [string] $expectedState		
  )
  
  write-host "Current Pool :"$PoolName".  Waiting to go to state:$expectedState"
  $stateCorrect=$false
    for($i=0 ; $i -lt 30; $i++)
    {
      $pool=get-item "IIS:\AppPools\$PoolName"
      if($pool -eq $null)
      {
        throw "Pool:$pool doesnt exist"
      }
        
      if($pool.state -eq $expectedState)
      {
        write-host "Pool $PoolName in Expected State"
        $stateCorrect=$true
        break;
      }

      Sleep -Seconds 1
    }
    if(!$stateCorrect){
      throw "Was not able to verify that pool $PoolName was is correct state $expectedState"
    }
}

function WaitForWebsiteExpectedState
{
[CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $website,
  [Parameter(Mandatory=$true)]
  [string] $expectedState		
  )
  
  write-host "Current Website:"$website".  Waiting to go to state:$expectedState"
  $stateCorrect=$false
    for($i=0 ; $i -lt 30; $i++)
    {
      $site=get-item "IIS:\Sites\$website"

      if($site -eq $null)
      {
        throw "Site:$website doesnt exist"
      }
        
      if($site.state -eq $expectedState)
      {
        write-host "Site $website in Expected State"
        $stateCorrect=$true
        break;
      }
      
      Sleep -Seconds 1
    }
    if(!$stateCorrect){
      throw "Was not able to verify that website $website was is correct state $expectedState"
    }
}

Function Get-AllNoteProperties
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$false)]
  [string] $prefix,
  [Parameter(Mandatory=$true)]
  [string] $propobjpath
  )
    
  if([string]::IsNullOrEmpty($prefix))
  {
    $notepropertynames= Get-ItemProperty $propobjpath | Get-Member -MemberType NoteProperty | select Name | Where-Object {!($_.Name  -like "PS*")}
  }
  else
  {
    $notepropertynames= Get-ItemProperty -Path $propobjpath -Name $prefix | Get-Member -MemberType NoteProperty | select Name | Where-Object {!($_.Name  -like "PS*")}
  }

    foreach($props in $notepropertynames)
    {
        if([string]::IsNullOrEmpty($prefix))
        {
          $myfqdn=$props.Name
        }
        else{
          $myfqdn=$prefix+"."+$props.Name
        }

   
       $propnames=@(Get-ItemProperty -Path $propobjpath -Name $myfqdn -ErrorAction SilentlyContinue | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue | select Name | Where-Object {!($_.Name  -like "PS*")})
              
         if($propnames.Count -eq 0)
         {
            $myfqdn
         }
         else
         {
            Get-AllNoteProperties $myfqdn $propobjpath
         }
     }  
}



function Convert-PropertyCase
{
  [CmdletBinding(SupportsShouldProcess=$true)] 														
  param
  (	
  [Parameter(Mandatory=$true)]
  [string] $property,
  [Parameter(Mandatory=$true)]
  [string] $path
  )

    $nprops = Get-AllNoteProperties -propobjpath $path
    foreach ($prop in $nprops)
    {
        if ($prop -eq $property)
        {
            return $prop
        }
    
    }
    throw "Property Doesn't exist in IIS. Please check the spelling of the property!"
}

 