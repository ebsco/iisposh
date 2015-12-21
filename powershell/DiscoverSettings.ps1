param (
  [switch] $apppool,
  [switch] $website,
  [switch] $webapp,
  [switch] $virtualdir,
  [switch] $bindings,
  
  [string] $websitestr,
  [string] $webappstr,
  [string] $apppoolstr,
  [string] $virtualdirstr
)


Import-module WebAdministration
$ErrorActionPreference="STOP"
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
. $scriptPath\..\files\default\iis_web_tools.ps1

function Get-WebAppPool([string] $name){
	$pools=gci "IIS:\AppPools"
	foreach($pool in $pools){
		if($pool.Name -eq $name){
			return $pool
		}
	}
	
	throw "Unable to find Application Pool:$name"

}

function Get-WebsiteProper([string] $sitename){
	$websites=@(Get-Website)
	foreach($site in $websites){
		if($site.Name -eq $sitename){
			return $site
		}
	}
	
	throw "Unable to find Webste:$sitename"

}



function Print-ChildElementAttributes ($prefix, $propobjpath){

  #write-host "Prefix:    $($prefix)"
  #write-host "propobj:$($propobj.GetType().BaseType.Name)"
  
  if([string]::IsNullOrEmpty($prefix)){
    $notepropertynames= gi $propobjpath | gm -MemberType NoteProperty | select Name | Where-Object {!($_.Name  -like "PS*")}
  }
  else{
    $notepropertynames= Get-ItemProperty -path $propobjpath -Name $prefix | gm -MemberType NoteProperty | select Name | Where-Object {!($_.Name  -like "PS*")}
  }
  
  foreach($props in $notepropertynames){
    if([string]::IsNullOrEmpty($prefix)){
      $myfqdn=$props.Name
    }
    else{
      $myfqdn=$prefix+"."+$props.Name
    }
    
    
     $propnames=@(Get-ItemProperty -path $propobjpath -Name $myfqdn -EA SilentlyContinue| gm -MemberType NoteProperty -EA SilentlyContinue | select Name | Where-Object {!($_.Name  -like "PS*")}) 
     #write-host "PropNames:$($propnames.Count)"
     
     if($propnames.Count -eq 0){
     #write-host "FQDN:  $myfqdn"
     #write-host "`"$($myfqdn)`" => `"$(($propobjpath | Get-ItemProperty -Name $myfqdn).Value)`""
     try{
     $val=get-itemProperty $propobjpath -Name $myfqdn 
     
      if($val.Value -ne $null){
      write-host "`"$($myfqdn)`" =>  `"$($val.Value)`","
      }
      else{
      write-host "`"$($myfqdn)`" =>  `"$($val)`","
      }
      }
      catch{
        write-warning "Trying to evaluate property $myfqdn failed."
      }
     }
     else{
      Print-ChildElementAttributes  $myfqdn $propobjpath
     }
     #write-host ""
  }
}

function Print-WebAppPoolAttributes([string] $name){
	$pool=Get-WebAppPool $name
	write-host "---------------------------------------"
	write-host "App Pool Settings"
  write-host "---------------------------------------"
	
   
	Print-ChildElementAttributes ""  $pool.PSPAth
  write-host "---------------END----------------------"
}

function Print-Bindings(){
	$bindings=@(Get-WebBinding)
	foreach($binding in $bindings){
		write-host "---------------------------------------"
		write-host "Binding Global Settings"
    write-host "Not including property ToString because this is an LWRP parameter that needs to match the documentation"
		$binding.Attributes | Format-List -Property Name,Value
		write-host "---------------END----------------------"
		
		for ($i=0 ; $i -lt $binding.ChildElements.Count; $i++){
			Print-ChildElementAttributes ""  $binding.ChildElements[$i]
		}
	}
}

function Print-Website([string] $siteName){
	$site=Get-WebsiteProper $siteName
 
  
		write-host "---------------------------------------"
		write-host "Site Settings"
		#$site.Attributes | Format-List -Property Name,Value
      Print-ChildElementAttributes ""  "IIS:\Sites\$siteName"
		
	write-host "---------------END----------------------"
}

function Print-WebApp([string] $website, [string] $name){
	$wa=Get-WebApplication $name
  if($wa -eq $null){
    throw "Unable to find Web Application in website `"$website`" and name `"$name`""
  }
	write-host "---------------------------------------"
	write-host "Web App Settings"
  write-host "Some settings are missing here, we know this please read comments in script for explanation"
  write-host "---------------------------------------"

		Print-ChildElementAttributes ""  "IIS:\sites\$website\$name"
  
  write-host "---------------END----------------------"
}

function Print-WebVirtualDir([string] $website, [string] $name){
	$vdir=Get-WebVirtualDirectory $name
    if($vdir -eq $null){
    throw "Unable to find Web Virtual Directory in website `"$website`" and name `"$name`""
  }
	write-host "---------------------------------------"
	write-host "Web Virtual Dir Settings"
  write-host "---------------------------------------"
	#$pool.Attributes | Format-List -Property Name,Value
  $vdir.Attributes| %{
      $val=get-itemProperty "IIS:\sites\$website\$name" -Name $_.Name
      if($val.Value -ne $null){
      write-host "`"$($_.Name)`" =>  `"$($val.Value)`","
      }
      else{
      write-host "`"$($_.Name)`" =>  `"$($val)`","
      }
  }
   
	for ($i=0 ; $i -lt $vdir.ChildElements.Count; $i++){
		Print-ChildElementAttributes ""  $vdir.ChildElements[$i]
	}
  write-host "---------------END----------------------"
}

#Helping to get all the properties.
if($apppool){
  if([string]::IsNullOrEmpty($apppoolstr) ){
    throw "You must supply an app pool string"
  }
  Print-WebAppPoolAttributes $apppoolstr
}
elseif($website){
 if([string]::IsNullOrEmpty($websitestr) ){
    throw "You must supply a website string"
  }
  Print-Website $websitestr
}
elseif($bindings){
  Print-Bindings
}
elseif($virtualdir){
 if([string]::IsNullOrEmpty($websitestr) ){
    throw "You must supply a website string"
  }
  
   if([string]::IsNullOrEmpty($virtualdirstr) ){
    throw "You must supply a Virtual Directory string"
  }
  
  Print-WebVirtualDir $websitestr $virtualdirstr
}
elseif($webapp){
 if([string]::IsNullOrEmpty($websitestr) ){
    throw "You must supply a website string"
  }
   if([string]::IsNullOrEmpty($webappstr) ){
    throw "You must supply a web application string"
  }
  
    #Please see the method New-WebApp in iis_web_tools.ps1 for full explanation.  The basic gist is when a webapp is created, they remove some of the virtual directory settings from our reach.
  #We could work around it, but that has other implications that are detailed over in other script.
  Print-WebApp $websitestr $webappstr
}
else{
  write-host "Please activate a switch: -pool, -website, -webapp, -virtualdir"
}




