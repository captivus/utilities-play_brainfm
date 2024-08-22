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

# Running from Elgato Stream Deck
To run this script from the Elgato Stream Deck, you can follow these steps:

1. **Open Elgato Stream Deck Software:**
   - Launch the Elgato Stream Deck software on your computer.

2. **Create a New Button:**
   - Find an empty button slot on your Stream Deck and click on it.

3. **Assign the System Command:**
   - In the right pane, under the "System" category, drag the "Open" action to the empty button slot.

4. **Configure the Action:**
    - Find the PowerShell executable. It is typically in `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`
    - Add the path to the script to the "App / File" field, as follows:  
    ```powershell
    "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy Bypass -File "<PATH TO SCRIPT>\play_brainfm.ps1"
    ```
    - Optionally, add the `brainfm_logo.jpg` image to the button to make it more visually appealing.

5. **Test the Button:**
   - Press the button on your Stream Deck to ensure it executes the PowerShell script as expected.

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