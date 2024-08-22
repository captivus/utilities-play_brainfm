# Play Brain.fm in Microsoft Edge - Media Window on Media Virtual Desktop

## Overview
This PowerShell script automates the process of navigating Windows 11 virtual desktops and applications, specifically focusing on switching to a named virtual desktop and a specific tab in Microsoft Edge.

## Key Components

### 1. Virtual Desktop Navigation
- Uses the `VirtualDesktop` PowerShell module
- Implements `Switch-ToNamedDesktop` function to change to a specified virtual desktop

### 2. Application Focus
- Utilizes Windows API calls (`user32.dll`) for window manipulation
- `Set-ApplicationFocus` function searches for and focuses on a specified application

### 3. Edge Tab Switching
- `Switch-EdgeTab` function activates Edge and uses keyboard shortcuts to switch tabs
- Employs `Ctrl+Shift+A` for Edge's tab search functionality

## Script Evolution
1. Initial implementation using `VirtualDesktop` module
2. Added error handling and diagnostic information
3. Replaced `Microsoft.VisualBasic.Interaction` with direct Windows API calls
4. Updated tab switching method to use Edge's built-in search (Ctrl+Shift+A)

## Usage
1. Ensure the `VirtualDesktop` module is installed
2. Save the script as `Navigate-Windows11.ps1`
3. Run in PowerShell: `.\Navigate-Windows11.ps1`

## Key Functions

```powershell
Switch-ToNamedDesktop -name "DesktopName"
Set-ApplicationFocus -name "ApplicationName"
Switch-EdgeTab -tabTitle "TabTitle"
```

## Dependencies
- PowerShell
- VirtualDesktop module
- Windows 11 OS

## Limitations
- Relies on keyboard shortcuts, which may be affected by Edge updates
- Timing of operations may need adjustment based on system performance

## Future Improvements
- Implement error recovery mechanisms
- Add support for other browsers
- Enhance tab searching logic for better accuracy

## Troubleshooting
- Ensure correct virtual desktop names
- Verify Edge is running with the desired tabs open
- Check console output for detailed operation logs