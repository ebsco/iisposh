Import-Module webadministration
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
. $scriptPath\common.ps1

function Check-WebProperties
{
	[CmdletBinding(SupportsShouldProcess=$true)] 														
	param
	(	
		[Parameter(Mandatory=$true)]
    [AllowEmptyString()]
		[hashtable] $myhash,
    
    [AllowEmptyString()]
    [Parameter(Mandatory=$true)]
		[string] $filter
		
	)
  write-host "Checking value for webproperties"
  write-host ""
  $checker=$true;
	$webobj = $myhash
  write-host ""
	foreach ($object in $webobj.keys)								
		{
			$prop = $object
			$value = $webobj.Item($object)
			$split = $prop.split(".")
			$attrib = $split[0]
			$name = $split[1]
			$value1 = Get-WebConfigurationProperty -Filter $filter/$attrib -name $name
      
			$value2 = $value1.value
			if ($value2 -eq $null)
			{
				$value2 = $value1
			}
      
      write-host "Setting at location: $filter/$attrib and name:$name is of value $value2"
      write-host "    User parameter value: $value"
      
			if ($value2 -ne $value)
			{
        write-host "Value comparison failed - must need an update"
				$checker= $false
        break;
			}
      write-host ""
		}
    write-host "Finished checking value for webproperties, output : $checker"
		return $checker
}

function Config-Web
{
	[CmdletBinding(SupportsShouldProcess=$true)] 														
	param
	(	
		[Parameter(Mandatory=$true)]
    [AllowEmptyString()]
		[hashtable] $myhash,
    
    [AllowEmptyString()]
    [Parameter(Mandatory=$true)]
		[string] $filter
		
	)
  write-host "Changing value for webproperties"
  write-host ""
	$webobj = $myhash
  write-host ""
  
  $filter=$filter.Trim("/")
	foreach ($object in $webobj.keys)								
		{
			$prop = $object
			$value = $webobj.Item($object).replace(";",",")
			$split = $prop.split(".")
			$attrib = $split[0]
			$name = $split[1]
      write-host "Setting parameter name: $name at location: $filter/$attrib to value: $value"
			Set-WebConfigurationProperty -Filter $filter/$attrib -name $name -value $value 
      write-host "Set property successfully"
      write-host ""
		}
    
    write-host ""
    if(Check-WebProperties $myhash -filter $filter){
       write-host "All values updated correctly"
    }
    else{
      write-host "Some value is different that what was passed in, erroring"
      throw "Validation of set properties found error"
    }
    
    
    write-host "Finished Changing value for webproperties"
		
}