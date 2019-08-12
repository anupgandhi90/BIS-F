﻿[CmdletBinding(SupportsShouldProcess = $true)]
param()
<#
    .Synopsis
      Load Global environment
    .Description
      Setting the global configuration needed for BISF
    .EXAMPLE
    .Inputs
    .Outputs
    .NOTES
      Author: Matthias Schlimm
      Editor: Mike Bijl (Rewritten variable names and script format)
      Company: Login Consultants Germany GmbH

      History
      Last Change: 10.09.2013 MS: Script created
      Last Change: 16.09.2013 MS: function to read values from registry
      Last Change: 17.09.2013 MS: Add global values for Folders
      Last Change: 17.09.2013 MS: edit scriptlogic to get varibales and their values from registry, if not defined use script defined values
      Last Change: 18.09.2013 MS: syntax error line 140 -Erroraction SilentlyContinue
      Last Change: 18.09.2013 MS: add rearm values for OS (Operting System) and OF (Office)
      Last Change: 18.09.2013 MS: replace $date with $(Get-date) to get current timestamp at running scriptlines write to the logfile
      Last Change: 18.09.2013 MS: Add varibale LIC_PVS_CtxImaPath to redirect local hostcache
      Last Change: 18.09.2013 MS: remove $LIB & $Subcall folder from gloabl variable
      Last Change: 18.09.2013 MS: add function CheckPVSDriveLetter and CheckPVSSysVariable
      Last Change: 19.09.2013 MS: remove $LOG = "C:\Windows\Log\$PSScriptName.log"
      Last Change: 19.09.2013 MS: add $regvarfound = @()
      Last Change: 19.09.2013 MS: add function CheckRegHive
      Last Change: 01.10.2013 MS: add global value LIC_PVS_RefSrv_HostName to detect ReferenceServer
      Last Change: 17.12.2013 MS: Errorhandling: add return $false for exit script
      Last Change: 18.12.2013 MS: Line 47: $varfound = @()
      Last Change: 28.01.2014 MS: Add $return for ErrorHandling
      Last Change: 28.01.2014 MS: Add CheckHostIDDir
      Last Change: 03.03.2014 BR: Revisited Script
      Last Change: 10.03.2014 MS: Remove Write-BISFLog in Line 139 and replace with Write-Host
      Last Change: 10.03.2014 MS: [array]$reg_value_data += "15_XX_Custom"
      Last Change: 21.03.2014 MS: last code change before release to web
      Last Change: 01.04.2014 MS: move central functions to 10_XX_LIB_Functions.psm1
      Last Change: 02.04.2014 MS: add variable to redirect Cache Location ->  $LIC_PVS_CtxCache
      Last Change: 02.04.2014 MS: Fix: wrong Log-Location
      Last Change: 15.05.2014 MS: Add get-Version to show current running version
      Last Change: 11.08.2014 MS: remove $returnCheckPVSDriveLetter
      Last Change: 12.08.2014 MS: remove to much entries for logging
      Last Change: 12.08.2014 MS: move function set-logfie from 10_XX_LIB_Functions.psm1 to 10_XX_LIB_Config.ps1, this function would be run from this script only and no more from other scripts
      Last Change: 13.08.2014 MS: add IF ($PVSDiskDrive -eq $null) {$PVSDiskDrive ="C:\Windows\Logs"}
      Last Change: 14.08.2014 MS: change function Set-Logfile if the Drive is not reachable
      Last Change: 15.08.2014 MS: add line 242: get-OSinfo
      Last Change: 15.08.2014 MS: add line 245: CheckXDSoftware
      Last Change: 18.08.2014 MS: move Logfilefolder PVSLogs to new Folder BISLogs\PVSLogs_old and remove the registry entry LIC_PVS_LogPath, their no longer needed
      Last Change: 31.10.2014 MB: Renamed functions: CheckXDSoftware -> Test-XDSoftware / CheckPVSSoftware -> Test-PVSSoftware / CheckPVSDriveLetter -> Get-PVSDriveLetter / CheckRegHive -> Test-BISFRegHive
      Last Change: 31.10.2014 MB: Renamed variables: returnCheckPVSSysVariable -> returnTestPVSEnvVariable
      Last Change: 14.04.2015 MS: Get-TaskSequence to activate or suppress a SystemShutdown
      Last Change: 14.04.2015 MS: detect if running from SCCM/MDT Tasksequence, if so it sets the logfile location to the the task sequence “LogPath”
      Last Change: 02.06.2015 MS: define new gobal variables for all not predefined customobjects in $BISFconfiguration, do i need to store the CLI commands in registry
	  Last Change: 02.06.2015 MS: running from SCCM or MDT ->  changing to $logpath only (prev. $LogFilePath = "$logPath\$LogFolderName"), only files directly in the folder are preserved, not subfolders
      Last Change: 10.08.2015 MS: Bug 50 - added existing funtion $Global:returnTestPVSDriveLetter=Test-PVSDriveLetter -Verbose:$VerbosePreference
      Last Change: 21.08.2015 MS: remove all XX,XA,XD from al files and Scripts
      Last Change: 29.09.2015 MS: Bug 93: check if preperation phase is running to run $Global:returnTestPVSDriveLetter=Test-PVSDriveLetter -Verbose:$VerbosePreference
      Last Change: 16.12.2015 MS: redirect spool directory to PVS WriteCacheDisk, if PVS Target Device Driver is installed only
      Last Change: 16.12.2015 MS: redirect eventlogs (Aplication, Security, System) to PVS WriteCacheDisk, if PVS Target Device Driver is installed only
	  Last Change: 07.01.2016 MS: Feature 20: add VMware Horizon View detection
	  Last Change: 27.01.2016 MS: move $State -eq "Preparation" from BISF.ps1 to function Test-BISFPVSDriveLetter
	  Last Change: 28.01.2016 MS: add Request-BISFsysprep
	  Last Change: 02.03.2016 MS: check PVS DiskMode at Prerequisites, to get an error on startup if Disk is in ReadOnly Mode
	  Last Change: 18.10.2016 MS: change LIC_BISF_MAIN_PersScript to new folderPath, remove wrong clip "}"
      Last Change: 19.10.2016 MS: add $Global:LogFilePath = "$LogPath"  to function Set-LogFile
	  Last Change: 27.07.2017 MS: replace redirection of spool and evt-logs with central function Use-BISFPVSConfig, if using Citrix AppLayering with PVS it's a complex matrix to redirect or not.
	  Last Change: 03.08.2017 MS: add $Gloabl:BootMode = Get-BISFBootMode to get UEFI or Legacy
	  Last Change: 14.08.2017 MS: add cli switch ExportSharedConfiguration to export BIS-F ADMX Reg Settings into an XML File
	  Last Change: 07.11.2017 MS: add $LIC_BISF_3RD_OPT = $false, if vmOSOT or CTXO is enabled and found, $LIC_BISF_3RD_OPT = $true and disable BIS-F own optimizations
	  Last Change: 11.11.2017 MS: Retry 30 times if Logshare on network path is not found with fallback after max. is reached
	  Last Change: 02.07.2018 MS: Bufix 50 - function Set-Logfile -> invoke-BISFLogShare   (After LogShare is changed in ADMX, the old path will also be checked and skips execution)
      Last Change: 20.10.2018 MS: Feature 63 - Citrix AppLayering - Create C:\Windows\Logs folder automatically if it doesn't exist
      Last Change: 12.05.2019 MS: FRQ 97 - Nutanix Xi Frame Support
      #>
Begin {

	####################################################################
	# Setting default variables ($PSScriptroot/$logfile/$PSCommand,$PSScriptFullname/$scriptlibrary/LogFileName) independent on running script from console or ISE and the powershell version.
	If ($($host.name) -like "* ISE *") {
		# Running script from Windows Powershell ISE
		$PSScriptFullName = $psise.CurrentFile.FullPath.ToLower()
		$PSCommand = (Get-PSCallStack).InvocationInfo.MyCommand.Definition
	}
 Else {
		$PSScriptFullName = $MyInvocation.MyCommand.Definition.ToLower()
		$PSCommand = $MyInvocation.Line
	}
	[string]$PSScriptName = (Split-Path $PSScriptFullName -leaf).ToLower()
	If (($PSScriptRoot -eq "") -or ($PSScriptRoot -eq $null)) { [string]$PSScriptRoot = (Split-Path $PSScriptFullName).ToLower() }

	####################################################################
	#maximize Window
	If ($Host.Name -match "console") {
		$MaxHeight = $host.UI.RawUI.MaxPhysicalWindowSize.Height
		$MaxWidth = $host.UI.RawUI.MaxPhysicalWindowSize.Width
	}


	# initialize script array
	If (($PVSDiskDrive -eq $null) -or ($PVSDiskDrive -eq "")) { $PVSDiskDrive = "C:\Windows\Logs" }

	# Predefined BISF configuration values
	[array]$BISFconfiguration = @(
		[pscustomobject]@{description = "LogFileFolder"; value = "LIC_BISF_LogPath"; data = "$PVSDiskDrive\BISFLogs"; FoundinReg = "$false" },
		[pscustomobject]@{description = "CitrixFolder"; value = "LIC_BISF_CtxPath"; data = "$PVSDiskDrive\Citrix"; FoundinReg = "$false" },
		[pscustomobject]@{description = "RedirectedLocalHostCache"; value = "LIC_BISF_CtxImaPath"; data = "$PVSDiskDrive\Citrix\IMA"; FoundinReg = "$false" },
		[pscustomobject]@{description = "RedirectedCitrixLicense"; value = "LIC_BISF_CtxCache"; data = "$PVSDiskDrive\Citrix\Cache"; FoundinReg = "$false" },
		[pscustomobject]@{description = "RedirectedEventLogs"; value = "LIC_BISF_EvtPath"; data = "$PVSDiskDrive\EventLogs"; FoundinReg = "$false" },
		[pscustomobject]@{description = "RedirectedPrintSpoolPath"; value = "LIC_BISF_SpoolPath"; data = "$PVSDiskDrive\Spool"; FoundinReg = "$false" },
		[pscustomobject]@{description = "CitrixUPMLogPath"; value = "LIC_BISF_UPMPath"; data = "$PVSDiskDrive\UPM"; FoundinReg = "$false" },
		[pscustomobject]@{description = "BISFPrepScripts"; value = "LIC_BISF_PrepFldr"; data = "Preparation"; FoundinReg = "$false" },
		[pscustomobject]@{description = "BISFPersScripts"; value = "LIC_BISF_PersFldr"; data = "Personalization"; FoundinReg = "$false" },
		[pscustomobject]@{description = "BISFPersScriptMain"; value = "LIC_BISF_MAIN_PersScript"; data = "$Main_Folder\PersBISF_Start.ps1"; FoundinReg = "$false" },
		[pscustomobject]@{description = "CustomScriptsFolder"; value = "LIC_BISF_CustomFldr"; data = "Custom"; FoundinReg = "$false" },
		[pscustomobject]@{description = "OSRearm_Enable"; value = "LIC_BISF_RearmOS_run"; data = "0"; FoundinReg = "$false" },
		[pscustomobject]@{description = "RearmOS_UserAccount"; value = "LIC_BISF_RearmOS_user"; data = $false; FoundinReg = "$false" },
		[pscustomobject]@{description = "RearmOS_Date"; value = "LIC_BISF_RearmOS_date"; data = $false; FoundinReg = "$false" },
		[pscustomobject]@{description = "RearmOF_Enable"; value = "LIC_BISF_RearmOF_run"; data = "0"; FoundinReg = "$false" },
		[pscustomobject]@{description = "RearmOF_UserAccount"; value = "LIC_BISF_RearmOF_user"; data = $false; FoundinReg = "$false" },
		[pscustomobject]@{description = "RearmOF_Date"; value = "LIC_BISF_RearmOF_date"; data = $false; FoundinReg = "$false" },
		[pscustomobject]@{description = "MTDHostname"; value = "LIC_BISF_RefSrv_HostName"; data = "$computer"; FoundinReg = "$false" },
		[pscustomobject]@{description = "OptDrive_DriveLetter"; value = "LIC_BISF_OptDrive"; data = $false; FoundinReg = "$false" },
		[pscustomobject]@{description = "ZCMAgent_args"; value = "LIC_BISF_ZCM_CFG"; data = ""; FoundinReg = "$false" },
		[pscustomobject]@{description = "3rd Party Optimizer"; value = "LIC_BISF_3RD_OPT"; data = "$false"; FoundinReg = "$false" }
	)

	####################################################################
	####### functions #####
	####################################################################

	function Set-Logfile {
		IF (!(Test-Path "$env:windir\Logs")) {
			Write-BISFLog -Msg "Folder $env:windir\Logs NOT Exist, will be created now !" -Type W -ShowConsole
			new-item -ItemType Directory -path "$env:windir\Logs" | out-null

		}
		Try {
			#Try to Create BISFLogsFolder
			$LogPath = "$PVSDiskDrive\$LogFolderName"
			IF ($LIC_BISF_LogShare) {
				Invoke-BISFLogShare -Verbose:$VerbosePreference
				for ($i = 0; $i -le 30; $i++) {
					IF (!(Test-Path $LIC_BISF_LogShare)) {
						Write-BISFLog -Msg "Retry $($i): Path $LIC_BISF_LogShare not reachable" -Type W -SubMsg -ShowConsole
						$LogShareReachable = $false
						Start-Sleep -Seconds 1
					}
					ELSE {
						Write-BISFLog -Msg "Path $LIC_BISF_LogShare reachable" -SubMsg -ShowConsole -Color DarkCyan
						$LogShareReachable = $true
						break
					}
				}
				IF ($LogShareReachable -eq $true)
				{ $LogPath = "$LIC_BISF_LogShare\$computer" } ELSE { $LogPath = "$PVSDiskDrive\$LogFolderName"; Write-BISFLog -Msg "Fallback to logpath $LogPath" -Type W -ShowConsole -SubMSg }
			}
			Write-BISFLog -Msg "Creating log folder on path $LogPath" -ShowConsole -SubMsg -Color DarkCyan
			New-Item -Path $LogPath -ItemType Directory -ErrorAction Stop
		}
		Catch [System.IO.DirectoryNotFoundException] {
			Write-BISFLog -Msg "Cannot create BISFLog folder, the volume is not formatted" -Type W -SubMsg
			$LogPath = "C:\Windows\Logs\$LogFolderName"
			New-Item -Path $LogPath -ItemType Directory -Force
		}
		Catch [System.IO.IOException] {
			Write-BISFLog -Msg "BISFLog folder already exists"
			#$LogPath = $LogPath
		}
		Catch [System.UnauthorizedAccessException] {
			Write-BISFLog -Msg "Cannot create BISFLog folder, the drive is not writeable" -Type W -SubMsg
			$LogPath = "C:\Windows\Logs\$LogFolderName"
			New-Item -Path $LogPath -ItemType Directory -Force
		}
		Catch {
			Write-BISFLog -Msg "Unhandeled Exception occured" -Type W -SubMsg
			$LogPath = "C:\Windows\Logs\$LogFolderName"
			New-Item -Path $LogPath -ItemType Directory -Force
		}
		Finally {

			$ErrorActionPreference = "Continue"
			#IF ($LIC_BISF_LogShare -and $state -eq "Personalization") {
			Write-BISFLog -Msg "Move BIS-F log to $LogPath" -ShowConsole -Color DarkCyan -SubMsg
			Get-ChildItem -Path "C:\Windows\Logs\*" -include "*.bis", "*.xml" | Move-Item -Destination $LogPath -Force
			IF (($NewLogPath) -and ($NewLogPath -ne $LogPath)) {
				Write-BISFLog -Msg "Move BIS-F log from $NewLogPath to $LogPath" -ShowConsole -Color DarkCyan -SubMsg
				Get-ChildItem -Path "$($NewLogPath)\*" -include "*.bis", "*.xml" | Move-Item -Destination $LogPath -Force
			}

			#}
			$Global:Logfile = "$LogPath\$LogFileName"
			$Global:LogFilePath = $LogPath
			$Global:NewLogPath = $LogPath
		}
		return $logfile
	}




	function Get-ActualConfig {
		[CmdletBinding(SupportsShouldProcess = $true)]
		param()
		#Write-BISFLog -Msg "read values from registry $hklm_software_LIC_CTX_BISF_SCRIPTS"
		# Get all values and data from the BISF registry key
		$regvalues = Get-BISFRegistryValues "$hklm_software_LIC_CTX_BISF_SCRIPTS"
		# Check for every key found if this is a valid configuration item and update the data of the value
		Foreach ($regvalue in $regvalues) {
			# look if there is a value in the $BISFconfiguration with the same name as the registry value
			$predefineddata = ($BISFconfiguration | Where { $_.value -eq ($regvalue.value) }).data
			If ($predefineddata -ne $null) {
				$defaultdata = ($BISFconfiguration | Where { $_.value -eq ($regvalue.value) }).data
				($BISFconfiguration | Where { $_.value -eq ($regvalue.value) }).data = $regvalue.data # Update the data property in the array with the regvalue data
				($BISFconfiguration | Where { $_.value -eq ($regvalue.value) }).FoundInReg = $true # Update the FoundInReg property in the array with $true
				#Write-BISFLog -Msg "The value `"$($regvalue.value)`" with data `"$($regvalue.data)`" read from registry $hklm_software_LIC_CTX_BISF_SCRIPTS overwrites the default value `"$defaultdata`""
			}
			ELSE {
				#Write-BISFLog -Msg "The value `"$($regvalue.value)`" with data `"$($regvalue.data)`" read from registry $hklm_software_LIC_CTX_BISF_SCRIPTS is not a valid configuration item."
				New-BISFGlobalVariable -Name $($regvalue.value) -Value $($regvalue.data)
			}
		}
	}
}

####################################################################
####### end functions #####
####################################################################

Process {
	Write-BISFLog -Msg "Setting LogFile to $(Set-Logfile -Verbose:$VerbosePreference)" -ShowConsole -Color DarkCyan -SubMsg
	Get-ActualConfig -Verbose:$VerbosePreference # Update the $BISFconfiguration with possible registry values
	Write-BISFLog -Msg "Update LogFile to $(Set-Logfile -Verbose:$VerbosePreference)" -ShowConsole -Color DarkCyan -SubMsg
	Get-BISFVersion -Verbose:$VerbosePreference
	Get-BISFOSCSessionType -Verbose:$VerbosePreference
	IF ($LIC_BISF_PrepLastRunTime) { Write-BISFLog -Msg "Last BIS-F Preparation would be performed on $LIC_BISF_PrepLastRunTime started from user $LIC_BISF_PrepLastRunUser" -ShowConsole -Color DarkCyan -SubMsg }
	Set-BISFLastRun -Verbose:$VerbosePreference
	Write-BISFLog -Msg "Running $State Phase" -ShowConsole -Color DarkCyan -SubMsg
	Invoke-BISFLogRotate -Versions 5 -Directory "$LogFilePath" -Verbose:$VerbosePreference
	Invoke-BISFLogShare -Verbose:$VerbosePreference
	Get-BISFOSinfo -Verbose:$VerbosePreference
	IF ($ExportSharedConfiguration) {
		#check switch ExportSharedConfiguration
		IF ($LIC_BISF_CLI_EX_PT) {
			#check Path in Registry if set
			$XMLOSname = $OSName.replace(' ', '')
			$XMLOSBitness = $OSBitness
			$XMLExportFile = "$LIC_BISF_CLI_EX_PT" + "\BISFconfig_" + $XMLOSname + "_" + $XMLOSBitness + ".xml"
			Write-BISFlog "Export Registry to $XMLExportFile" -ShowConsole -Color Cyan
			Export-BISFRegistry "$Reg_LIC_Policies" -ExportType xml -exportpath "$XMLexportfile"
		}
		ELSE {
			Write-BISFLog "Error: The custom path for the shared configuration is not configured in the ADMX !!" -Type E
		}

		Write-BISFLog "Press any key to exit ..." -ShowConsole -Color Red
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
		$Global:TerminateScript = $true; Exit

	}

	Get-BISFPSVersion -Verbose:$VerbosePreference
	Test-BISFRegHive -Verbose:$VerbosePreference
	$Global:returnGetHypervisor = Get-BISFHypervisor -Verbose:$VerbosePreference
	$Global:returnTestAppLayeringSoftware = Test-BISFAppLayeringSoftware -Verbose:$VerbosePreference
	$Global:returnTestXDSoftware = Test-BISFXDSoftware -Verbose:$VerbosePreference
	$Global:returnTestPVSSoftware = Test-BISFPVSSoftware -Verbose:$VerbosePreference
	$Global:returnTestVMHVSoftware = Test-BISFVMwareHorizonViewSoftware -Verbose:$VerbosePreference
	$Global:returnTestXiFrameSoftware = Test-BISFXiFrameSoftware -Verbose:$VerbosePreference
	$Global:returnRequestSysprep = Request-BISFSysprep -Verbose:$VerbosePreference
	$Global:DiskMode = Get-BISFDiskMode -Verbose:$VerbosePreference
	$Global:BootMode = Get-BISFBootMode

	Get-ActualConfig -Verbose:$VerbosePreference # Update the $BISFconfiguration with possible registry values

	# Create Powershell variables from the BISFConfiguration items.
	ForEach ($BISFconfig in $BISFconfiguration) { New-BISFGlobalVariable -Name $BISFconfig.value -Value $BISFconfig.data }

	Use-BISFPVSConfig -Verbose:$VerbosePreference  #27.07.2017 MS: new created

	$TSenvExist = Get-BISFTaskSequence -Verbose:$VerbosePreference
	IF($TSenvExist -eq "true") {
		$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
		$logPath = $tsenv.Value("LogPath")
		Write-BISFLog -Msg "Set Log folder path to task sequence Log folder $logPath"
		$LogFilePath = "$logPath"   # 02.06.2015 MS: changing to $logpath only (prev. $LogFilePath = "$logPath\$LogFolderName"), only files directly in the folder are preserved, not subfolders
		$oldlogfile = $LogFile
		$Global:Logfile = "$LogFilePath\$LogFileName"


		if (!(Test-Path -Path $LogFilePath)) {
			New-Item -Path $LogFilePath -ItemType Directory -Force
		}

		IF (Test-Path ($oldLogfile) -PathType Leaf ) {
			Move-Item -Path "$OldLogfile" -Destination "$LogFile"
			Write-BISFLog "LogFile $logfile" -ShowConsole -Color DarkCyan -SubMsg
		}
	}

}
End {
	Add-BISFFinishLine
}