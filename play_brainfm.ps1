param(
    [switch]$Debug = $false,
    [switch]$Help = $false
)

# Add this function at the beginning of the script
function Show-Help {
    Write-Host @"
Usage: .\play_brainfm.ps1 [-Debug] [-Help]

This script automates playing Brain.fm in Microsoft Edge on a specific virtual desktop.

Parameters:
  -Debug    Run the script in debug mode, providing detailed output.
  -Help     Display this help message.

Examples:
  .\play_brainfm.ps1
  .\play_brainfm.ps1 -Debug
  .\play_brainfm.ps1 -Help

Note: This script requires the VirtualDesktop module to be installed.
"@
    exit
}

# Check if help is requested
if ($Help) {
    Show-Help
}

# Import the VirtualDesktop module
# Must be installed as admin by running "Install-Module VirtualDesktop -Scope CurrentUser"
Import-Module VirtualDesktop

Add-Type -AssemblyName System.Windows.Forms

# Add Windows API function declarations for window management
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class User32 {
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@

# Add this function for debug output
function Write-DebugMessage {
    param([string]$Message)
    if ($Debug) {
        Write-Host "DEBUG: $Message" -ForegroundColor Cyan
    }
}

<#
.SYNOPSIS
Switches to a named virtual desktop.

.PARAMETER name
The name of the virtual desktop to switch to.

.EXAMPLE
Switch-ToNamedDesktop -name "Media"
#>
function Switch-ToNamedDesktop {
    param([string]$name)
    $desktops = Get-DesktopList
    $targetDesktop = $desktops | Where-Object { $_.Name -eq $name }
    if ($targetDesktop) {
        try {
            Switch-Desktop -Desktop $targetDesktop.Number
            Write-DebugMessage "Switched to virtual desktop: $name"
        } catch {
            Write-DebugMessage "Error switching to desktop: $_"
        }
    } else {
        Write-DebugMessage "Virtual desktop '$name' not found."
        Write-DebugMessage "Available desktops: $($desktops | ForEach-Object { $_.Name } | Join-String -Separator ', ')"
    }
}

<#
.SYNOPSIS
Sets focus on an application window.

.PARAMETER name
The name of the application to focus on.

.EXAMPLE
Set-ApplicationFocus -name "Edge"
#>
function Set-ApplicationFocus {
    param([string]$name)
    $processes = Get-Process | Where-Object { $_.MainWindowTitle -ne "" }
    Write-DebugMessage "Searching for application with name containing '$name'"
    Write-DebugMessage "Running processes with non-empty window titles:"
    if ($Debug) {
        $processes | ForEach-Object { Write-DebugMessage "  - $($_.ProcessName): $($_.MainWindowTitle)" }
    }
    
    $app = $processes | Where-Object { $_.ProcessName -like "*$name*" -or $_.MainWindowTitle -like "*$name*" } | Select-Object -First 1
    if ($app) {
        [User32]::ShowWindow($app.MainWindowHandle, 9) # 9 = SW_RESTORE
        [User32]::SetForegroundWindow($app.MainWindowHandle)
        Write-DebugMessage "Set focus on application: $($app.ProcessName) (Window Title: $($app.MainWindowTitle))"
        return $true
    } else {
        Write-DebugMessage "Application with name containing '$name' not found."
        return $false
    }
}

<#
.SYNOPSIS
Switches to a specific tab in Microsoft Edge.

.PARAMETER tabTitle
The title of the tab to switch to.

.EXAMPLE
Switch-EdgeTab -tabTitle "brain.fm"
#>
function Switch-EdgeTab {
    param([string]$tabTitle)
    $edge = Get-Process | Where-Object { $_.ProcessName -eq "msedge" -and $_.MainWindowTitle -ne "" } | Select-Object -First 1
    if ($edge) {
        [User32]::ShowWindow($edge.MainWindowHandle, 9) # 9 = SW_RESTORE
        [User32]::SetForegroundWindow($edge.MainWindowHandle)
        Write-DebugMessage "Activated Edge window: $($edge.MainWindowTitle)"
        
        $wshell = New-Object -ComObject wscript.shell
        $wshell.SendKeys("^+a")
        Start-Sleep -Milliseconds 500
        $wshell.SendKeys($tabTitle)
        Start-Sleep -Milliseconds 500
        $wshell.SendKeys("{ENTER}")
        
        Write-DebugMessage "Attempted to switch to tab '$tabTitle' in Edge"
        return $true
    } else {
        Write-DebugMessage "No Edge window with a non-empty title found."
        return $false
    }
}

# Main execution
try {
    $originalDesktop = Get-CurrentDesktop
    $originalDesktopName = Get-DesktopName

    Write-DebugMessage "Starting from desktop number: $($originalDesktop.Number)"

    Switch-ToNamedDesktop -name "Media"

    $focusSuccess = Set-ApplicationFocus -name "Media"

    if ($focusSuccess) {
        $switchSuccess = Switch-EdgeTab -tabTitle "brain.fm"
        
        if ($switchSuccess) {
            Write-DebugMessage "Navigation completed successfully."
            Start-Sleep -Milliseconds 500
            [System.Windows.Forms.SendKeys]::SendWait(' ')
        } else {
            Write-DebugMessage "Navigation partially completed. Failed to switch to the desired tab."
        }
    } else {
        Write-DebugMessage "Navigation failed. Could not focus on Microsoft Edge."
    }

    Switch-Desktop -Desktop $originalDesktop
    Write-DebugMessage "Returned to original desktop: $($originalDesktopName)"
} catch {
    Write-DebugMessage "An error occurred: $_"
} finally {
    try {
        Switch-Desktop -Desktop $originalDesktop
        Write-DebugMessage "Returned to original desktop: $($originalDesktopName)"
    } catch {
        Write-DebugMessage "Failed to return to original desktop: $_"
    }
}

# Add this at the end to provide a summary when not in debug mode
if (-not $Debug) {
    Write-Host "Brain.fm playback initiated successfully." -ForegroundColor Green
}