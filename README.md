# iDebloat - Windows Bloatware & Performance Tweaks Utility
**Author:** Henry Elliott  
**Version:** 1.0  
**Platform:** Windows 10/11 (PowerShell 5+ with .NET Framework)  
**License:** MIT (feel free to customize!)

---

## Overview
iDebloat is a powerful, clean, and user-friendly PowerShell GUI tool designed to help you declutter Windows by removing bloatware, disabling telemetry, tweaking performance settings, and more, all in a few clicks.

It features:  
- Modern, resizable WPF interface  
- Multi-column task selection with descriptive tooltips  
- Async execution with real-time progress and logs  
- Core debloat tasks: Remove Edge, OneDrive, Cortana, disable telemetry, background apps, and install useful apps silently  
- Fully open to extensions - planned advanced features include system backups, restore points, task dependency management, scheduling, system info, and more.

---

## Getting Started

### Prerequisites  
- Windows 10/11 with PowerShell 5.1+ (default on most modern Windows versions)  
- Run PowerShell as Administrator to allow system changes  
- .NET Framework assemblies used: PresentationFramework, PresentationCore, WindowsBase, System.Xaml (default on Windows)

### Installation  
No installation needed. Just download or copy the `iDebloat.ps1` script file.

### Usage  
1. Open PowerShell as Administrator.  
2. Navigate to the script directory, e.g.:  
   ```powershell
   cd C:\Users\user\Downloads
   ```  
3. Run the script with execution policy bypass:  
   ```powershell
   powershell -ExecutionPolicy ByPass -File .\iDebloat.ps1
   ```  
4. In the GUI:  
   - Select the debloat or tweak tasks you want.  
   - Click **Run Selected**.  
   - Watch the progress bar and live log for status updates.

---

## Planned Advanced Features
The project is actively evolving! Here are some powerful features planned to make iDebloat a complete, professional-grade Windows optimization suite:

- **Restore / Undo System**  
  Create system restore points automatically before applying tweaks.  
  Maintain logs to revert specific changes or reinstall apps if needed.

- **Task Dependency Management**  
  Handle task dependencies and conflicts (e.g., uninstall OneDrive before disabling related services).  
  Warn users or auto-select related tasks for smooth operation.

- **Background Scheduler / Service**  
  Allow scheduling of debloat tasks to run at idle times or periodically.  
  Automate system optimization without user intervention.

- **System Info & Health Check**  
  Display Windows version, build number, installed apps summary, and performance metrics.  
  Automatically detect and highlight bloatware.

- **Backup & Restore User Data**  
  Optional backup of user folders, app settings, or registry keys before changes.  
  Provide a recovery mechanism to prevent data loss.

- **Integration with Windows Security**  
  Safely check and manage Windows Defender, Firewall settings, and telemetry.

- **Extensible Plugin System**  
  Support adding community or custom tasks easily.  
  Modular architecture for maintenance and updates.

---

## Contribution & Development
This project welcomes contributions! If you'd like to help develop new features or improve existing ones:  
- Fork the repo and create a branch  
- Follow PowerShell best practices and WPF UI conventions  
- Open pull requests with clear descriptions  
- Report bugs or feature requests via issues

---

## Disclaimer
Use at your own risk. Modifying system settings can cause unexpected issues. Always back up important data and create system restore points before using debloat tools.
