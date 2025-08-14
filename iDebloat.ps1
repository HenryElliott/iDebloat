Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase,System.Xaml

# ---------------------------
# Paths / Globals
# ---------------------------
$AppName         = 'iDebloat'
$AppBrand        = 'Henry Elliott - iDebloat'
$StateRoot       = Join-Path $env:ProgramData $AppName
$LastRunPath     = Join-Path $StateRoot 'last_run.json'
$BackupRootBase  = Join-Path ([Environment]::GetFolderPath('Desktop')) "${AppName}_Backups"
$ScriptSelfPath  = $MyInvocation.MyCommand.Path  # for scheduler

New-Item -ItemType Directory -Force -Path $StateRoot,$BackupRootBase | Out-Null

# ---------------------------
# XAML
# ---------------------------
$xaml = @"
<Window xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
        xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
        Title='$AppBrand' Height='840' Width='920'
        WindowStartupLocation='CenterScreen'
        ResizeMode='CanResize'
        Background='#121212' Foreground='#EEEEEE' FontFamily='Segoe UI' FontSize='13' >

  <Grid Margin='16'>
    <Grid.RowDefinitions>
      <RowDefinition Height='Auto'/>
      <RowDefinition Height='*'/>
      <RowDefinition Height='Auto'/>
      <RowDefinition Height='200'/>
    </Grid.RowDefinitions>

    <TextBlock Text='$AppBrand' FontSize='22' FontWeight='Bold' Margin='0,0,0,12' Foreground='#0099FF'/>

    <TabControl Grid.Row='1' Background='#1E1E1E' BorderBrush='#333' BorderThickness='1'>
      <!-- TASKS -->
      <TabItem Header='Tasks' Name='tabTasks'>
        <Grid Margin='12'>
          <Grid.RowDefinitions>
            <RowDefinition Height='Auto'/>
            <RowDefinition Height='*'/>
            <RowDefinition Height='Auto'/>
          </Grid.RowDefinitions>

          <!-- Profiles -->
          <StackPanel Grid.Row='0' Orientation='Wrap' Margin='0,0,0,10'>
            <StackPanel Orientation='Horizontal' Margin='0,0,0,8'>
              <TextBlock Text='Profiles: ' VerticalAlignment='Center' Margin='0,0,8,0'/>
              <Button Name='btnProfileSafe' Content='Safe' Width='90' Margin='0,0,8,0'/>
              <Button Name='btnProfilePerf' Content='Performance' Width='110' Margin='0,0,8,0'/>
              <Button Name='btnProfileExtreme' Content='Extreme ⚠' Width='120' Margin='0,0,8,0'/>
              <Button Name='btnProfileGaming' Content='Gaming' Width='100' Margin='0,0,8,0'/>
              <Button Name='btnProfileDAW' Content='Workstation / DAW' Width='160' Margin='0,0,8,0'/>
              <Button Name='btnProfilePrivacy' Content='Privacy-Max' Width='120' />
            </StackPanel>
            <CheckBox Name='chkBackup' Content='Backup user data before running' Margin='0,0,0,0' IsChecked='False'/>
          </StackPanel>

          <!-- Grid of tasks -->
          <ScrollViewer Grid.Row='1' VerticalScrollBarVisibility='Auto'>
            <Grid Name='TaskGrid'>
              <Grid.ColumnDefinitions>
                <ColumnDefinition Width='*'/>
                <ColumnDefinition Width='*'/>
                <ColumnDefinition Width='*'/>
              </Grid.ColumnDefinitions>
            </Grid>
          </ScrollViewer>

          <!-- Actions -->
          <StackPanel Grid.Row='2' Orientation='Horizontal' Margin='0,12,0,0' HorizontalAlignment='Center'>
            <Button Name='btnUndoLast' Content='Undo Last Run' Width='150' Height='36' Margin='0,0,10,0'/>
            <Button Name='BtnRun' Content='Run Selected' Width='150' Height='36'/>
            <ProgressBar Name='ProgressBar' Width='280' Height='24' Margin='20,0,0,0' Minimum='0' Maximum='100' Visibility='Collapsed'/>
          </StackPanel>
        </Grid>
      </TabItem>

      <!-- SYSTEM INFO -->
      <TabItem Header='System Info' Name='tabSystem'>
        <StackPanel Margin='12'>
          <TextBlock Text='Windows Version:' FontWeight='Bold' Foreground='#00A2FF'/>
          <TextBlock Name='TxtWinVersion' Margin='0,0,0,8'/>
          <TextBlock Text='Build Number:' FontWeight='Bold' Foreground='#00A2FF'/>
          <TextBlock Name='TxtBuildNumber' Margin='0,0,0,8'/>
          <TextBlock Text='Installed Apps (Appx + MSI):' FontWeight='Bold' Foreground='#00A2FF'/>
          <TextBlock Name='TxtAppsCount' Margin='0,0,0,8'/>
          <TextBlock Text='System Uptime:' FontWeight='Bold' Foreground='#00A2FF'/>
          <TextBlock Name='TxtUptime' Margin='0,0,0,8'/>
        </StackPanel>
      </TabItem>

      <!-- SCHEDULER -->
      <TabItem Header='Scheduler' Name='tabScheduler'>
        <StackPanel Margin='12'>
          <TextBlock Text='Schedule iDebloat to run automatically:' FontWeight='Bold' Foreground='#00A2FF'/>
          <StackPanel Orientation='Horizontal' Margin='0,10,0,0'>
            <TextBlock Text='Time (HH:mm):' VerticalAlignment='Center' Margin='0,0,8,0'/>
            <TextBox Name='txtSchedTime' Width='100' Text='03:00'/>
            <TextBlock Text='   Frequency:' VerticalAlignment='Center' Margin='10,0,8,0'/>
            <ComboBox Name='cmbSchedFreq' Width='140'>
              <ComboBoxItem Content='Daily' IsSelected='True'/>
              <ComboBoxItem Content='At logon'/>
            </ComboBox>
          </StackPanel>
          <StackPanel Orientation='Horizontal' Margin='0,12,0,0'>
            <Button Name='btnCreateSchedule' Content='Create Task' Width='120' Margin='0,0,8,0'/>
            <Button Name='btnRemoveSchedule' Content='Remove Task' Width='120'/>
          </StackPanel>
          <TextBlock Name='txtScheduleStatus' Margin='0,10,0,0'/>
        </StackPanel>
      </TabItem>

      <!-- LOGS -->
      <TabItem Header='Logs' Name='tabLogs'>
        <Grid Margin='12'>
          <TextBox Name='LogBox' Background='Black' Foreground='#BFE3FF' FontFamily='Consolas' TextWrapping='Wrap' VerticalScrollBarVisibility='Auto' IsReadOnly='True'/>
        </Grid>
      </TabItem>
    </TabControl>

    <TextBlock Name='StatusText' Grid.Row='2' FontStyle='Italic' Foreground='#BBBBBB' HorizontalAlignment='Center' Margin='0,8,0,6'/>
    <Border Grid.Row='3' Background='#1E1E1E' CornerRadius='6' BorderBrush='#333' BorderThickness='1'>
      <TextBox Name='txtFooterHelp' Background='Transparent' Foreground='#CCCCCC' IsReadOnly='True' TextWrapping='Wrap'
               Text='Tip: Use a profile to quickly select a recommended set of tweaks. Extreme adds risky options (clearly marked). A system restore point will be created automatically before changes.'/>
    </Border>
  </Grid>
</Window>
"@

# ---------------------------
# Build Window
# ---------------------------
$reader  = New-Object System.Xml.XmlNodeReader ([xml]$xaml)
$Window  = [Windows.Markup.XamlReader]::Load($reader)

# Controls
$TaskGrid        = $Window.FindName('TaskGrid')
$BtnRun          = $Window.FindName('BtnRun')
$btnUndoLast     = $Window.FindName('btnUndoLast')
$ProgressBar     = $Window.FindName('ProgressBar')
$StatusText      = $Window.FindName('StatusText')
$LogBox          = $Window.FindName('LogBox')
$chkBackup       = $Window.FindName('chkBackup')

$TxtWinVersion   = $Window.FindName('TxtWinVersion')
$TxtBuildNumber  = $Window.FindName('TxtBuildNumber')
$TxtAppsCount    = $Window.FindName('TxtAppsCount')
$TxtUptime       = $Window.FindName('TxtUptime')

$btnProfileSafe     = $Window.FindName('btnProfileSafe')
$btnProfilePerf     = $Window.FindName('btnProfilePerf')
$btnProfileExtreme  = $Window.FindName('btnProfileExtreme')
$btnProfileGaming   = $Window.FindName('btnProfileGaming')
$btnProfileDAW      = $Window.FindName('btnProfileDAW')
$btnProfilePrivacy  = $Window.FindName('btnProfilePrivacy')

$txtSchedTime     = $Window.FindName('txtSchedTime')
$cmbSchedFreq     = $Window.FindName('cmbSchedFreq')
$btnCreateSchedule= $Window.FindName('btnCreateSchedule')
$btnRemoveSchedule= $Window.FindName('btnRemoveSchedule')
$txtScheduleStatus= $Window.FindName('txtScheduleStatus')

# ---------------------------
# Helpers
# ---------------------------
function Write-Log {
  param([string]$Message, [ValidateSet('INFO','WARN','ERROR')] [string]$Level='INFO')
  $timestamp = (Get-Date).ToString('HH:mm:ss')
  $line = "$timestamp [$Level] $Message"
  $LogBox.AppendText($line + "`r`n")
  $LogBox.ScrollToEnd()
  $StatusText.Text = "${Level}: $Message"
}

function Create-RestorePoint {
  Write-Log "Creating system restore point..."
  try {
    Checkpoint-Computer -Description "$AppName Restore Point" -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop
    Write-Log "Restore point created."
    return $true
  } catch {
    Write-Log "Failed to create restore point: $_" 'WARN'
    return $false
  }
}

function Backup-UserData {
  $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
  $dest  = Join-Path $BackupRootBase "Backup_$stamp"
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  Write-Log "Backing up user data to $dest"
  $dirs = @('Documents','Desktop','Pictures','Downloads') | ForEach-Object { Join-Path $env:USERPROFILE $_ }
  foreach ($d in $dirs) {
    if (Test-Path $d) {
      $name = Split-Path $d -Leaf
      $target = Join-Path $dest $name
      Write-Log "Copying $name ..."
      Copy-Item $d $target -Recurse -Force -ErrorAction SilentlyContinue
    }
  }
  Write-Log "Backup complete."
}

function Update-SystemInfo {
  try {
    $os  = Get-CimInstance Win32_OperatingSystem
    $TxtWinVersion.Text  = $os.Caption
    $TxtBuildNumber.Text = $os.BuildNumber
    $appx = (Get-AppxPackage -AllUsers).Count
    $msi  = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue).Count
    $TxtAppsCount.Text   = "$($appx + $msi)"
    $uptime = (Get-Date) - $os.LastBootUpTime
    $TxtUptime.Text = ('{0}d {1}h {2}m' -f $uptime.Days,$uptime.Hours,$uptime.Minutes)
  } catch {
    $TxtWinVersion.Text  = 'Error'
    $TxtBuildNumber.Text = 'Error'
    $TxtAppsCount.Text   = 'Error'
    $TxtUptime.Text      = 'Error'
  }
}
Update-SystemInfo

# ---------------------------
# Task Model
# ---------------------------
class DebloatTask {
  [string]$Id
  [string]$Name
  [string]$Description
  [ScriptBlock]$Action
  [ScriptBlock]$Undo
  [string[]]$DependsOn
  [bool]$Risky = $false
  [object]$CheckBox
  DebloatTask([string]$id,[string]$name,[string]$desc,[ScriptBlock]$action,[ScriptBlock]$undo,[string[]]$deps,[bool]$risky){
    $this.Id=$id; $this.Name=$name; $this.Description=$desc; $this.Action=$action; $this.Undo=$undo; $this.DependsOn=$deps; $this.Risky=$risky
  }
}

$Tasks = New-Object System.Collections.Generic.List[DebloatTask]

function Add-Task {
  param($id,$name,$desc,$action,$undo,[string[]]$deps=@(),[bool]$risky=$false)
  $Tasks.Add([DebloatTask]::new($id,$name,$desc,$action,$undo,$deps,$risky)) | Out-Null
}

# ---------------------------
# Define Tasks
# ---------------------------
# 1) Remove Bloatware (Appx sample list)
Add-Task 'bloatware' 'Remove Bloatware' 'Remove common preinstalled UWP apps.' {
  $apps = @(
    'Microsoft.XboxApp','Microsoft.XboxGamingOverlay','Microsoft.XboxSpeechToTextOverlay',
    'Microsoft.BingNews','Microsoft.GetHelp','Microsoft.Getstarted','Microsoft.Microsoft3DViewer',
    'Microsoft.MicrosoftSolitaireCollection','Microsoft.MixedReality.Portal','Microsoft.People',
    'Microsoft.SkypeApp','Microsoft.ZuneMusic','Microsoft.ZuneVideo','Microsoft.WindowsMaps'
  )
  foreach ($a in $apps) {
    Get-AppxPackage -AllUsers -Name $a | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $a | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
  }
} { Write-Log "Reinstall from Microsoft Store if needed." 'INFO' } @()

# 2) Remove Microsoft Edge
Add-Task 'edge' 'Remove Microsoft Edge' 'Force uninstall Chromium Edge.' {
  $path = "C:\Program Files (x86)\Microsoft\Edge\Application"
  if (Test-Path $path) {
    Push-Location "$path\*\Installer"
    try { .\setup.exe --uninstall --force-uninstall --system-level } catch {}
    Pop-Location
  }
} { Write-Log 'Install Edge from Microsoft if needed.' 'WARN' } @()

# 3) Remove OneDrive
Add-Task 'onedrive' 'Remove OneDrive' 'Uninstall and remove OneDrive.' {
  Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
  $od = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"; if (-not (Test-Path $od)) { $od = "$env:SystemRoot\System32\OneDriveSetup.exe" }
  if (Test-Path $od) { Start-Process $od '/uninstall' -NoNewWindow -Wait }
  Remove-Item "$env:USERPROFILE\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
} { Write-Log 'Reinstall OneDrive from Microsoft if needed.' 'WARN' } @()

# 4) Disable Cortana
Add-Task 'cortana' 'Disable Cortana' 'Turn off Cortana via policy.' {
  New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Force | Out-Null
  Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'AllowCortana' -Type DWord -Value 0
} { Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'AllowCortana' -ErrorAction SilentlyContinue } @('telemetry')

# 5) Disable Telemetry & Ads
Add-Task 'telemetry' 'Disable Telemetry & Ads' 'Stops DiagTrack, dmwappush, CEIP tasks & disables ads.' {
  Stop-Service DiagTrack -Force -ErrorAction SilentlyContinue
  Set-Service  DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue
  Stop-Service dmwappushservice -Force -ErrorAction SilentlyContinue
  Set-Service  dmwappushservice -StartupType Disabled -ErrorAction SilentlyContinue

  $paths = @(
   '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
   '\Microsoft\Windows\Application Experience\ProgramDataUpdater',
   '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator',
   '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip',
   '\Microsoft\Windows\Feedback\Siuf\DmClient',
   '\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload'
  )
  foreach ($p in $paths) { Get-ScheduledTask -TaskPath $p -ErrorAction SilentlyContinue | Disable-ScheduledTask | Out-Null }

  New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Force | Out-Null
  Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -Type DWord -Value 0
} {
  Set-Service DiagTrack -StartupType Manual -ErrorAction SilentlyContinue
  Set-Service dmwappushservice -StartupType Manual -ErrorAction SilentlyContinue
  foreach ($p in @(
    '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
    '\Microsoft\Windows\Application Experience\ProgramDataUpdater',
    '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator',
    '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip',
    '\Microsoft\Windows\Feedback\Siuf\DmClient',
    '\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload'
  )){ Get-ScheduledTask -TaskPath $p -ErrorAction SilentlyContinue | Enable-ScheduledTask | Out-Null }
} @()

# 6) Disable Background Apps
Add-Task 'background' 'Disable Background Apps' 'Prevent UWP apps from running in background.' {
  New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' -Force | Out-Null
  Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' -Name 'GlobalUserDisabled' -Type DWord -Value 1
} { Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' -Name 'GlobalUserDisabled' -Type DWord -Value 0 } @()

# 7) Performance Tweaks (visual effects, menu delay)
Add-Task 'performance' 'Apply Performance Tweaks' 'Bias visual effects for speed; lower menu delay.' {
  Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Type DWord -Value 2
  Set-ItemProperty 'HKCU:\Control Panel\Desktop' -Name 'MenuShowDelay' -Type String -Value '0'
} {
  Remove-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -ErrorAction SilentlyContinue
  Remove-ItemProperty 'HKCU:\Control Panel\Desktop' -Name 'MenuShowDelay' -ErrorAction SilentlyContinue
} @()

# 8) Install Brave + VS Code (silent via winget)
Add-Task 'apps' 'Install Brave + VS Code' 'Installs Brave and VS Code silently (winget).' {
  winget install --id=Brave.Brave --silent --accept-package-agreements --accept-source-agreements
  winget install --id=Microsoft.VisualStudioCode --silent --accept-package-agreements --accept-source-agreements
} { Write-Log 'Uninstall from Apps & Features if desired.' 'INFO' } @()

# 9) SysMain off (SSD rigs)
Add-Task 'sysmain' 'Disable SysMain (SSD)' 'Stops SysMain (Superfetch) to reduce random I/O.' {
  Stop-Service SysMain -Force -ErrorAction SilentlyContinue
  Set-Service SysMain -StartupType Disabled -ErrorAction SilentlyContinue
} { Set-Service SysMain -StartupType Manual -ErrorAction SilentlyContinue } @()

# 10) Delivery Optimization local-only
Add-Task 'do_local' 'Delivery Optimization → Local Only' 'Avoid P2P update sharing.' {
  New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Force | Out-Null
  Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Name 'DODownloadMode' -Type DWord -Value 0
  Stop-Service DoSvc -Force -ErrorAction SilentlyContinue
  Set-Service DoSvc -StartupType Manual -ErrorAction SilentlyContinue
} { Remove-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Recurse -ErrorAction SilentlyContinue } @()

# 11) Ultimate Performance plan
Add-Task 'ultimate' 'Ultimate Performance Plan' 'Activates the Ultimate Performance power plan.' {
  powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
  powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
} { Write-Log 'Switch power plan in Control Panel to revert.' 'INFO' } @()

# 12) Hibernation off
Add-Task 'hibernate' 'Disable Hibernation' 'Frees disk and speeds boots on some systems.' {
  powercfg /h off
} { powercfg /h on } @()

# 13) Edge Preload Off
Add-Task 'edge_preload_off' 'Edge Preload/Boost Off' 'Disable Edge Startup Boost & background mode.' {
  New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Force | Out-Null
  Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'StartupBoostEnabled' -Type DWord -Value 0
  Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'BackgroundModeEnabled' -Type DWord -Value 0
} { Remove-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Recurse -ErrorAction SilentlyContinue } @()

# 14) Widgets off (Win11)
Add-Task 'widgets' 'Disable Widgets (Win11)' 'Hides Widgets button.' {
  Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarDa' -Type DWord -Value 0
} { Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarDa' -Type DWord -Value 1 } @()

# 15) Defender Real-Time OFF (Risky)
Add-Task 'defender_off' 'Defender Real-Time OFF ⚠' 'Disables Defender real-time monitoring (risky).' {
  New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' -Force | Out-Null
  Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' -Name 'DisableRealtimeMonitoring' -Type DWord -Value 1
} { Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' -Name 'DisableRealtimeMonitoring' -Type DWord -Value 0 } @() $true

# 16) TCP tuning (RSS/RSC on, ECN off)
Add-Task 'tcp_tune' 'TCP Tuning' 'Enable RSS/RSC; Leave autotuning normal; disable ECN.' {
  & netsh int tcp set global rss=enabled | Out-Null
  & netsh int tcp set global rsc=enabled | Out-Null
  & netsh int tcp set global autotuninglevel=normal | Out-Null
  & netsh int tcp set global ecncapability=disabled | Out-Null
} {
  & netsh int tcp set global rss=default | Out-Null
  & netsh int tcp set global rsc=default | Out-Null
  & netsh int tcp set global autotuninglevel=normal | Out-Null
  & netsh int tcp set global ecncapability=default | Out-Null
} @()

# --- New: Gaming/DAW/Privacy tasks ---
# 17) Game Mode ON
Add-Task 'game_mode' 'Game Mode ON' 'Enable Windows Game Mode.' {
  New-Item 'HKCU:\Software\Microsoft\GameBar' -Force | Out-Null
  Set-ItemProperty 'HKCU:\Software\Microsoft\GameBar' -Name 'AllowAutoGameMode' -Type DWord -Value 1
} {
  Set-ItemProperty 'HKCU:\Software\Microsoft\GameBar' -Name 'AllowAutoGameMode' -Type DWord -Value 0
} @()

# 18) Disable Game DVR / Captures
Add-Task 'game_dvr_off' 'Game DVR OFF' 'Disable background game capture (saves CPU/Disk).' {
  New-Item 'HKCU:\System\GameConfigStore' -Force | Out-Null
  Set-ItemProperty 'HKCU:\System\GameConfigStore' -Name 'GameDVR_Enabled' -Type DWord -Value 0
  New-Item 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' -Force | Out-Null
  Set-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' -Name 'AppCaptureEnabled' -Type DWord -Value 0
} {
  Set-ItemProperty 'HKCU:\System\GameConfigStore' -Name 'GameDVR_Enabled' -Type DWord -Value 1 -ErrorAction SilentlyContinue
  Set-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' -Name 'AppCaptureEnabled' -Type DWord -Value 1 -ErrorAction SilentlyContinue
} @()

# 19) HAGS (Hardware-Accelerated GPU Scheduling) ON (requires reboot)
Add-Task 'hags_on' 'GPU Scheduling (HAGS) ON' 'Enable hardware GPU scheduling (reboot needed).' {
  New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Force | Out-Null
  Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name 'HwSchMode' -Type DWord -Value 2
} {
  Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -Name 'HwSchMode' -Type DWord -Value 1
} @()

# 20) USB selective suspend OFF (helps audio interfaces / DAW stability)
Add-Task 'usb_ss_off' 'USB Selective Suspend OFF' 'Reduce USB power saving for stable audio/MIDI.' {
  New-Item 'HKLM:\SYSTEM\CurrentControlSet\Services\USB' -Force | Out-Null
  Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\USB' -Name 'DisableSelectiveSuspend' -Type DWord -Value 1
} {
  Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\USB' -Name 'DisableSelectiveSuspend' -Type DWord -Value 0
} @()

# 21) Privacy-Max: Disable Location & Tailored experiences / tips
Add-Task 'privacy_location' 'Disable Location Service' 'Turn off location platform via policy.' {
  New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' -Force | Out-Null
  Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' -Name 'DisableLocation' -Type DWord -Value 1
} {
  Remove-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' -Recurse -ErrorAction SilentlyContinue
} @()

Add-Task 'privacy_tailored' 'Disable Tailored Experiences & Tips' 'Reduce ads/telemetry-driven suggestions.' {
  New-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' -Force | Out-Null
  Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' -Name 'TailoredExperiencesWithDiagnosticDataEnabled' -Type DWord -Value 0
  New-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Force | Out-Null
  # Common tips/ads flags:
  'SubscribedContent-338387Enabled','SubscribedContent-353694Enabled','SubscribedContent-353696Enabled','SubscribedContent-353698Enabled','SubscribedContent-310093Enabled' | %{
    Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name $_ -Type DWord -Value 0 -ErrorAction SilentlyContinue
  }
} {
  # No-op safe undo
  Write-Log 'You can re-enable tips/tailored experiences from Settings > Privacy.' 'INFO'
} @()

# ---------------------------
# Dependency map (sample)
# ---------------------------
$Dependencies = @{
  'cortana'    = @('telemetry')
}

function Validate-Dependencies {
  $selected = $Tasks | Where-Object { $_.CheckBox.IsChecked }
  foreach ($t in $selected) {
    if ($Dependencies.ContainsKey($t.Id)) {
      foreach ($dep in $Dependencies[$t.Id]) {
        if (-not ($selected.Id -contains $dep)) {
          [System.Windows.MessageBox]::Show("Task '$($t.Name)' requires '$dep'. Please also select it.","Dependency Warning",'OK','Warning') | Out-Null
          return $false
        }
      }
    }
  }
  return $true
}

function Validate-Conflicts {
  # Add any mutually-exclusive combos here if you define them later
  return $true
}

# ---------------------------
# Build Task Grid (3 columns)
# ---------------------------
$colCount = 3
$rowCount = [math]::Ceiling($Tasks.Count / $colCount)
for ($r=0; $r -lt $rowCount; $r++) {
  $rowDef = New-Object System.Windows.Controls.RowDefinition
  $TaskGrid.RowDefinitions.Add($rowDef)
}

for ($i=0; $i -lt $Tasks.Count; $i++) {
  $task = $Tasks[$i]
  $cb = New-Object System.Windows.Controls.CheckBox
  $cb.Content   = $(if ($task.Risky) { "$($task.Name) (⚠)" } else { $task.Name })
  $cb.ToolTip   = $task.Description
  $cb.Margin    = [System.Windows.Thickness]::new(10,6,10,6)
  $cb.Foreground= [System.Windows.Media.Brushes]::LightGray
  $task.CheckBox = $cb

  [System.Windows.Controls.Grid]::SetRow($cb, [math]::Floor($i / $colCount))
  [System.Windows.Controls.Grid]::SetColumn($cb, $i % $colCount)
  $TaskGrid.Children.Add($cb) | Out-Null
}

# ---------------------------
# Profiles
# ---------------------------
function Apply-Profile {
  param([ValidateSet('Safe','Performance','Extreme','Gaming','DAW','Privacy')]$Profile)
  foreach ($t in $Tasks) { $t.CheckBox.IsChecked = $false }

  switch ($Profile) {
    'Safe' {
      'bloatware','telemetry','background','performance','edge_preload_off','do_local' | ForEach-Object {
        ($Tasks | ? Id -eq $_).CheckBox.IsChecked = $true
      }
    }
    'Performance' {
      'bloatware','telemetry','background','performance','edge_preload_off','do_local','sysmain','ultimate','hibernate','tcp_tune','widgets' | ForEach-Object {
        ($Tasks | ? Id -eq $_).CheckBox.IsChecked = $true
      }
    }
    'Extreme' {
      'bloatware','telemetry','background','performance','edge_preload_off','do_local','sysmain','ultimate','hibernate','tcp_tune','widgets','defender_off' | ForEach-Object {
        ($Tasks | ? Id -eq $_).CheckBox.IsChecked = $true
      }
    }
    'Gaming' {
      'bloatware','telemetry','background','performance','edge_preload_off','sysmain','ultimate','tcp_tune','game_mode','game_dvr_off','hags_on','widgets' | ForEach-Object {
        ($Tasks | ? Id -eq $_).CheckBox.IsChecked = $true
      }
    }
    'DAW' {
      'bloatware','telemetry','performance','edge_preload_off','do_local','usb_ss_off','ultimate','hibernate' | ForEach-Object {
        ($Tasks | ? Id -eq $_).CheckBox.IsChecked = $true
      }
    }
    'Privacy' {
      'bloatware','telemetry','background','edge_preload_off','privacy_location','privacy_tailored','widgets' | ForEach-Object {
        ($Tasks | ? Id -eq $_).CheckBox.IsChecked = $true
      }
    }
  }
  Write-Log "Profile applied: $Profile"
}

$btnProfileSafe.Add_Click({ Apply-Profile 'Safe' })
$btnProfilePerf.Add_Click({ Apply-Profile 'Performance' })
$btnProfileExtreme.Add_Click({
  $res = [System.Windows.MessageBox]::Show("Extreme includes risky tweaks (e.g., Defender real-time OFF). Proceed?","Extreme Profile",'YesNo','Warning')
  if ($res -eq 'Yes') { Apply-Profile 'Extreme' }
})
$btnProfileGaming.Add_Click({ Apply-Profile 'Gaming' })
$btnProfileDAW.Add_Click({ Apply-Profile 'DAW' })
$btnProfilePrivacy.Add_Click({ Apply-Profile 'Privacy' })

# ---------------------------
# Scheduler
# ---------------------------
$TaskName = "${AppName}_Daily"

function Update-ScheduleStatus {
  try {
    $exists = Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
    $txtScheduleStatus.Text = "Scheduled task '$TaskName' exists."
  } catch {
    $txtScheduleStatus.Text = "No scheduled task found."
  }
}
Update-ScheduleStatus

$btnCreateSchedule.Add_Click({
  try {
    $freq = ($cmbSchedFreq.SelectedItem.Content).ToString()
    $timeText = $txtSchedTime.Text
    if ($freq -eq 'Daily') {
      [datetime]::ParseExact($timeText,'HH:mm',$null) | Out-Null
      $trigger = New-ScheduledTaskTrigger -Daily -At $timeText
    } else {
      $trigger = New-ScheduledTaskTrigger -AtLogOn
    }
    $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-ExecutionPolicy Bypass -File `"$ScriptSelfPath`""
    $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
    $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    $task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $settings
    Register-ScheduledTask -TaskName $TaskName -InputObject $task -Force | Out-Null
    Write-Log "Scheduled task created: $TaskName at $timeText ($freq)."
    Update-ScheduleStatus
  } catch {
    Write-Log "Scheduler error: $_" 'ERROR'
  }
})

$btnRemoveSchedule.Add_Click({
  try {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
    Write-Log "Scheduled task removed: $TaskName."
  } catch {
    Write-Log "Remove scheduler error: $_" 'ERROR'
  }
  Update-ScheduleStatus
})

# ---------------------------
# Last Run / Undo
# ---------------------------
function Save-LastRun {
  param([string[]]$Ids)
  $obj = [pscustomobject]@{ date=(Get-Date); tasks=$Ids }
  $json = $obj | ConvertTo-Json -Depth 5
  $json | Set-Content -Path $LastRunPath -Encoding UTF8
}

function Undo-LastRun {
  if (-not (Test-Path $LastRunPath)) {
    Write-Log "No last run record found." 'WARN'
    return
  }
  try {
    $data = Get-Content $LastRunPath -Raw | ConvertFrom-Json
    $ids  = $data.tasks
    if (-not $ids -or $ids.Count -eq 0) { Write-Log "Last run is empty." 'WARN'; return }
    $sel = $Tasks | Where-Object { $ids -contains $_.Id }
    Write-Log "Undoing last run: $($ids -join ', ')"
    foreach ($t in $sel) {
      try {
        & $t.Undo
        Write-Log "Undo OK: $($t.Name)"
      } catch {
        Write-Log "Undo failed ($($t.Name)): $_" 'ERROR'
      }
    }
    Write-Log "Undo complete."
  } catch {
    Write-Log "Undo error: $_" 'ERROR'
  }
}

$btnUndoLast.Add_Click({
  $res = [System.Windows.MessageBox]::Show("Undo the last run?","Undo Confirmation",'YesNo','Question')
  if ($res -eq 'Yes') { Undo-LastRun }
})

# ---------------------------
# Run Selected
# ---------------------------
function Invoke-TaskAsync {
  param([DebloatTask]$Task)
  [System.Threading.Tasks.Task]::Run([Action]{
    try {
      Write-Log "Starting: $($Task.Name)"
      & $Task.Action
      Write-Log "Completed: $($Task.Name)"
    } catch {
      Write-Log "Error in '$($Task.Name)': $_" 'ERROR'
    }
  })
}

$BtnRun.Add_Click({
  $BtnRun.IsEnabled = $false

  # simple battery heads-up
  try {
    $onBattery = (Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue) -ne $null
    if ($onBattery) {
      [System.Windows.MessageBox]::Show("You're on battery. Some tweaks are better on AC power.","Heads up",'OK','Information') | Out-Null
    }
  } catch {}

  if (-not (Validate-Dependencies)) { $BtnRun.IsEnabled = $true; return }
  if (-not (Validate-Conflicts))    { $BtnRun.IsEnabled = $true; return }

  $selectedTasks = $Tasks | Where-Object { $_.CheckBox.IsChecked }
  if ($selectedTasks.Count -eq 0) {
    Write-Log "No tasks selected." 'WARN'
    $BtnRun.IsEnabled = $true
    return
  }

  # Risky confirmation
  if ($selectedTasks | Where-Object { $_.Risky }) {
    $res = [System.Windows.MessageBox]::Show("Risky tasks selected (⚠). Proceed?","Confirm Risky Tweaks",'YesNo','Warning')
    if ($res -ne 'Yes') { $BtnRun.IsEnabled = $true; return }
  }

  if ($chkBackup.IsChecked) { Backup-UserData }

  if (-not (Create-RestorePoint)) {
    $res = [System.Windows.MessageBox]::Show("Could not create a system restore point. Continue anyway?","Restore Point Warning",'YesNo','Warning')
    if ($res -ne 'Yes') { $BtnRun.IsEnabled = $true; return }
  }

  $ProgressBar.Visibility = 'Visible'
  $ProgressBar.Value = 0
  $StatusText.Text = 'Running selected tasks...'

  $taskCount    = $selectedTasks.Count
  $runningTasks = @()
  foreach ($task in $selectedTasks) { $runningTasks += Invoke-TaskAsync -Task $task }

  while ($runningTasks.Count -gt 0) {
    Start-Sleep -Milliseconds 200
    $runningTasks = $runningTasks | Where-Object { -not $_.IsCompleted }
    $completed = $taskCount - $runningTasks.Count
    $ProgressBar.Value = [math]::Round(($completed / $taskCount) * 100)
  }

  Save-LastRun -Ids ($selectedTasks.Id)

  Write-Log "All selected tasks completed."
  $ProgressBar.Visibility = 'Collapsed'
  $BtnRun.IsEnabled = $true
})

# ---------------------------
# Show
# ---------------------------
[void]$Window.ShowDialog()
