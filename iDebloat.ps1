Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase,System.Xaml

$xaml = @"
<Window xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
        xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
        Title='Henry Elliott - iDebloat' Height='700' Width='700' 
        WindowStartupLocation='CenterScreen'
        ResizeMode='CanResize'
        Background='#121212' Foreground='#EEEEEE' FontFamily='Segoe UI' FontSize='13' >

    <Grid Margin='20'>
        <Grid.RowDefinitions>
            <RowDefinition Height='Auto'/>
            <RowDefinition Height='*'/>
            <RowDefinition Height='Auto'/>
            <RowDefinition Height='Auto'/>
            <RowDefinition Height='Auto'/>
        </Grid.RowDefinitions>

        <TextBlock Text='Select tasks to perform:' FontSize='20' FontWeight='Bold' Margin='0,0,0,15' Foreground='#0099FF'/>

        <Border Grid.Row='1' Background='#1E1E1E' CornerRadius='6' Padding='12' BorderBrush='#333' BorderThickness='1' >
            <Grid x:Name='TaskGrid'>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width='*'/>
                    <ColumnDefinition Width='*'/>
                    <ColumnDefinition Width='*'/>
                </Grid.ColumnDefinitions>
            </Grid>
        </Border>

        <StackPanel Grid.Row='2' Orientation='Horizontal' HorizontalAlignment='Center' Margin='0,15,0,10' >
            <Button x:Name='BtnRun' Content='Run Selected' Width='160' Height='40' Background='#0078D7' Foreground='White' FontWeight='Bold'
                    BorderThickness='0' Cursor='Hand' >
                <Button.Style>
                    <Style TargetType='Button'>
                        <Setter Property='Template'>
                            <Setter.Value>
                                <ControlTemplate TargetType='Button'>
                                    <Border Background='{TemplateBinding Background}' CornerRadius='5' >
                                        <ContentPresenter HorizontalAlignment='Center' VerticalAlignment='Center' />
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property='IsMouseOver' Value='True'>
                                            <Setter Property='Background' Value='#005A9E'/>
                                        </Trigger>
                                        <Trigger Property='IsPressed' Value='True'>
                                            <Setter Property='Background' Value='#003E73'/>
                                        </Trigger>
                                    </ControlTemplate.Triggers>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                    </Style>
                </Button.Style>
            </Button>

            <ProgressBar x:Name='ProgressBar' Width='280' Height='24' Margin='20,0,0,0' Minimum='0' Maximum='100' Visibility='Collapsed'
                         Foreground='#0099FF' Background='#2E2E2E' BorderBrush='#333' BorderThickness='1' />
        </StackPanel>

        <TextBlock x:Name='StatusText' Grid.Row='3' FontStyle='Italic' Foreground='#BBBBBB' HorizontalAlignment='Center' Margin='0,4,0,15' />

        <Border Grid.Row='4' Background='#1E1E1E' CornerRadius='6' BorderBrush='#333' BorderThickness='1' >
            <TextBox x:Name='LogBox' Height='200' Background='Transparent' Foreground='#CCCCCC' FontFamily='Consolas'
                 TextWrapping='Wrap' VerticalScrollBarVisibility='Auto' IsReadOnly='True' BorderThickness='0' />
        </Border>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader ([xml]$xaml))
$Window = [Windows.Markup.XamlReader]::Load($reader)

$TaskGrid = $Window.FindName("TaskGrid")
$BtnRun = $Window.FindName("BtnRun")
$ProgressBar = $Window.FindName("ProgressBar")
$StatusText = $Window.FindName("StatusText")
$LogBox = $Window.FindName("LogBox")

class DebloatTask {
    [string]$Id
    [string]$Name
    [string]$Description
    [ScriptBlock]$Action
    [object]$CheckBox

    DebloatTask ([string]$id, [string]$name, [string]$desc, [ScriptBlock]$action) {
        $this.Id = $id
        $this.Name = $name
        $this.Description = $desc
        $this.Action = $action
    }
}

$Tasks = @()

$Tasks += [DebloatTask]::new("bloatware", "Remove Bloatware", "Remove unnecessary pre-installed Windows apps.", {
    $bloatList=@("Microsoft.3DBuilder","Microsoft.XboxApp","Microsoft.GetHelp","Microsoft.Getstarted")
    foreach ($app in $bloatList) {
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where DisplayName -EQ $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }
})

$Tasks += [DebloatTask]::new("edge", "Remove Microsoft Edge", "Uninstall the Chromium Microsoft Edge browser.", {
    $path = "C:\Program Files (x86)\Microsoft\Edge\Application"
    if (Test-Path $path) {
        Push-Location "$path\*\Installer"
        try { .\setup.exe --uninstall --force-uninstall --system-level } catch {}
        Pop-Location
    }
})

$Tasks += [DebloatTask]::new("onedrive", "Remove OneDrive", "Uninstall and remove Microsoft OneDrive.", {
    Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    $od = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    if (-not (Test-Path $od)) { $od = "$env:SystemRoot\System32\OneDriveSetup.exe" }
    Start-Process $od "/uninstall" -NoNewWindow -Wait
    Remove-Item "$env:USERPROFILE\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
})

$Tasks += [DebloatTask]::new("cortana", "Disable Cortana", "Disable Cortana via registry.", {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0
})

$Tasks += [DebloatTask]::new("telemetry", "Disable Telemetry & Ads", "Disable Windows telemetry and advertising tracking.", {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Force
})

$Tasks += [DebloatTask]::new("background", "Disable Background Apps", "Prevent apps from running in the background.", {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Force
})

$Tasks += [DebloatTask]::new("performance", "Apply Performance Tweaks", "Optimize Windows performance settings.", {
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -Force
})

$Tasks += [DebloatTask]::new("apps", "Install Brave + VS Code", "Install Brave browser and Visual Studio Code silently via winget.", {
    winget install --id=Brave.Brave --silent --accept-package-agreements --accept-source-agreements
    winget install --id=Microsoft.VisualStudioCode --silent --accept-package-agreements --accept-source-agreements
})

$colCount = 3
$rowCount = [math]::Ceiling($Tasks.Count / $colCount)

for ($r=0; $r -lt $rowCount; $r++) {
    $TaskGrid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))
}

for ($i=0; $i -lt $Tasks.Count; $i++) {
    $task = $Tasks[$i]

    $cb = New-Object System.Windows.Controls.CheckBox
    $cb.Content = $task.Name
    $cb.ToolTip = $task.Description
    $cb.Margin = [System.Windows.Thickness]::new(10,6,10,6)
    $cb.Foreground = [System.Windows.Media.Brushes]::LightGray

    $task.CheckBox = $cb

    [System.Windows.Controls.Grid]::SetRow($cb, [math]::Floor($i / $colCount))
    [System.Windows.Controls.Grid]::SetColumn($cb, $i % $colCount)

    $TaskGrid.Children.Add($cb) | Out-Null
}

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO","WARN","ERROR")] [string]$Level = "INFO"
    )
    $timestamp = (Get-Date).ToString("HH:mm:ss")
    $prefix = "[{0}]" -f $Level
    $line = "$timestamp $prefix $Message"
    $LogBox.AppendText($line + "`r`n")
    $LogBox.ScrollToEnd()
    $StatusText.Text = "$($Level): $Message"
}

function Invoke-TaskAsync {
    param([DebloatTask]$Task)
    return [System.Threading.Tasks.Task]::Run([Action]{
        try {
            Write-Log "Starting task: $($Task.Name)"
            & $Task.Action
            Write-Log "Completed task: $($Task.Name)"
        } catch {
            Write-Log "Error in task '$($Task.Name)': $_" "ERROR"
        }
    })
}

$BtnRun.Add_Click({
    $BtnRun.IsEnabled = $false
    $selectedTasks = $Tasks | Where-Object { $_.CheckBox.IsChecked }
    if ($selectedTasks.Count -eq 0) {
        Write-Log "No tasks selected. Please check at least one option." "WARN"
        $BtnRun.IsEnabled = $true
        return
    }

    $ProgressBar.Visibility = "Visible"
    $ProgressBar.Value = 0
    $StatusText.Text = "Running selected tasks..."

    $taskCount = $selectedTasks.Count
    $runningTasks = @()

    foreach ($task in $selectedTasks) {
        $runningTasks += Invoke-TaskAsync -Task $task
    }

    while ($runningTasks.Count -gt 0) {
        Start-Sleep -Milliseconds 200
        $runningTasks = $runningTasks | Where-Object { -not $_.IsCompleted }
        $completed = $taskCount - $runningTasks.Count
        $ProgressBar.Value = [math]::Round(($completed / $taskCount) * 100)
    }

    Write-Log "All selected tasks completed."
    $ProgressBar.Visibility = "Collapsed"
    $BtnRun.IsEnabled = $true
})

[void]$Window.ShowDialog()
