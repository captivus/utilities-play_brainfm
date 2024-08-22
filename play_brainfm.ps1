<#
.SYNOPSIS
Automates playing Brain.fm in Microsoft Edge on a specific virtual desktop.

.DESCRIPTION
This script navigates to a named virtual desktop, focuses on Microsoft Edge,
switches to the Brain.fm tab, and starts playback. It uses the VirtualDesktop
module and Windows API calls for desktop and window management.

.NOTES
Requires the VirtualDesktop module to be installed.
#>

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
            Write-Host "Switched to virtual desktop: $name"
        } catch {
            Write-Host "Error switching to desktop: $_"
        }
    } else {
        Write-Host "Virtual desktop '$name' not found."
        Write-Host "Available desktops: $($desktops | ForEach-Object { $_.Name } | Join-String -Separator ', ')"
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
    Write-Host "Searching for application with name containing '$name'"
    Write-Host "Running processes with non-empty window titles:"
    $processes | ForEach-Object { Write-Host "  - $($_.ProcessName): $($_.MainWindowTitle)" }
    
    $app = $processes | Where-Object { $_.ProcessName -like "*$name*" -or $_.MainWindowTitle -like "*$name*" } | Select-Object -First 1
    if ($app) {
        [User32]::ShowWindow($app.MainWindowHandle, 9) # 9 = SW_RESTORE
        [User32]::SetForegroundWindow($app.MainWindowHandle)
        Write-Host "Set focus on application: $($app.ProcessName) (Window Title: $($app.MainWindowTitle))"
        return $true
    } else {
        Write-Host "Application with name containing '$name' not found."
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
    param(
        [string]$tabTitle
    )
    $edge = Get-Process | Where-Object { $_.ProcessName -eq "msedge" -and $_.MainWindowTitle -ne "" } | Select-Object -First 1
    if ($edge) {
        # Activate the Edge window
        [User32]::ShowWindow($edge.MainWindowHandle, 9) # 9 = SW_RESTORE
        [User32]::SetForegroundWindow($edge.MainWindowHandle)
        Write-Host "Activated Edge window: $($edge.MainWindowTitle)"
        
        # Use correct keyboard shortcut to search tabs
        $wshell = New-Object -ComObject wscript.shell
        $wshell.SendKeys("^+a")  # Ctrl+Shift+A to open tab search
        Start-Sleep -Milliseconds 500  # Wait for search to open
        $wshell.SendKeys($tabTitle)
        Start-Sleep -Milliseconds 500  # Wait for search results
        $wshell.SendKeys("{ENTER}")
        
        Write-Host "Attempted to switch to tab '$tabTitle' in Edge"
        return $true
    } else {
        Write-Host "No Edge window with a non-empty title found."
        return $false
    }
}

# Main execution
try {
    # Switch to the "Media" virtual desktop
    Switch-ToNamedDesktop -name "Media"

    # Set focus on the Edge browser window
    $focusSuccess = Set-ApplicationFocus -name "Media"

    # Only proceed if focus was successful
    if ($focusSuccess) {
        # Switch to the tab with brain.fm
        $switchSuccess = Switch-EdgeTab -tabTitle "brain.fm"
        
        if ($switchSuccess) {
            Write-Host "Navigation completed successfully."
            # Wait for 0.5 seconds
            Start-Sleep -Milliseconds 500
            # Send a space key press to start playing Brain.fm
            [System.Windows.Forms.SendKeys]::SendWait(' ')

        } else {
            Write-Host "Navigation partially completed. Failed to switch to the desired tab."
        }
    } else {
        Write-Host "Navigation failed. Could not focus on Microsoft Edge."
    }
} catch {
    Write-Host "An error occurred: $_"
}