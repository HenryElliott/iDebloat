# 🚀 iDebloat - Windows Debloat & Performance Tool

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)](https://docs.microsoft.com/en-us/powershell/) 
[![Windows](https://img.shields.io/badge/Windows-10%2F11-blue)](https://www.microsoft.com/windows)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Author:** Henry Elliott  
**Version:** 1.0  
**Platform:** Windows 10/11 (PowerShell 5+ with .NET Framework)  
**License:** MIT License: Free to use, modify, and distribute.

---

## 📖 Overview

**iDebloat** is a **full-featured, GUI-driven Windows optimization toolkit** designed to declutter, harden, and boost performance on Windows 10/11 systems.

Built in **PowerShell + WPF**, iDebloat combines **one-click preset profiles**, fine-grained manual controls, and automation features like **scheduling, backups, and restore points**.

### ✨ Highlights
- 🖥 **Modern WPF GUI** - Fully resizable, dark-themed interface.
- 📋 **30+ Optimization Tasks** - Each with description, dependencies, and optional undo.
- ⚡ **One-Click Profiles** - Safe, Performance, Extreme, Gaming, Workstation/DAW, Privacy-Max.
- ⏱ **Scheduler** - Automate debloat runs at idle or daily times.
- 📊 **System Info Dashboard** - OS, build, uptime, app counts.
- ♻ **Undo & Restore Points** - Automatic backup and rollback safety.
- 🔌 **Extensible Architecture**- Add your own tasks easily.

---

## 🛠 Installation & Usage

### Prerequisites
- **Windows 10/11**
- **PowerShell 5.1+**
- Administrator privileges
- .NET Framework assemblies (already installed on Windows)

### Run iDebloat
1. Download `iDebloat.ps1`
2. Right-click **PowerShell** → *Run as Administrator*
3. Navigate to the script directory:
   ```powershell
   cd C:\Path\To\iDebloat
   ```
4. Run the script:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\iDebloat.ps1
   ```

---

## 🧩 Profiles

| Profile       | Description |
|---------------|-------------|
| **Safe**      | Removes common bloatware, disables telemetry & background apps, basic performance tweaks. |
| **Performance** | Aggressive speed tweaks, disables more background services, enables Ultimate Performance plan. |
| **Extreme ⚠** | Includes risky changes like Defender real-time disable, use with caution. |
| **Gaming**    | Prioritizes FPS & latency: Game Mode, GPU Scheduling, disables DVR, reduces background load. |
| **Workstation / DAW** | Optimizes for audio/video work: USB stability tweaks, disables background apps. |
| **Privacy-Max** | Locks down telemetry, location services, tailored ads, widgets. |

---

## 🛠 Task Reference

| ID | Task Name | Description | Risk Level |
|----|-----------|-------------|------------|
| bloatware | Remove Bloatware | Removes common UWP apps | Safe |
| edge | Remove Edge | Forces uninstall of Microsoft Edge | Medium |
| onedrive | Remove OneDrive | Uninstalls and removes OneDrive | Medium |
| cortana | Disable Cortana | Disables via policy | Safe |
| telemetry | Disable Telemetry & Ads | Stops tracking services/tasks | Safe |
| background | Disable Background Apps | Prevents UWP background execution | Safe |
| performance | Performance Tweaks | Visual effects/menu delay optimization | Safe |
| apps | Install Brave + VS Code | Installs silently via winget | Safe |
| sysmain | Disable SysMain | Disables for SSD I/O stability | Safe |
| do_local | Delivery Optimization Local-Only | Stops P2P Windows Update | Safe |
| ultimate | Ultimate Performance Plan | Enables high-performance plan | Safe |
| hibernate | Disable Hibernation | Saves disk space | Safe |
| edge_preload_off | Edge Preload Off | Disables startup boost/background mode | Safe |
| widgets | Disable Widgets | Removes Win11 widgets button | Safe |
| defender_off | Defender Real-Time OFF | Turns off Defender realtime scanning | ⚠ Risky |
| tcp_tune | TCP Tuning | Enables RSS/RSC, disables ECN | Safe |
| game_mode | Game Mode ON | Enables Windows Game Mode | Safe |
| game_dvr_off | Game DVR OFF | Disables capture to save CPU/Disk | Safe |
| hags_on | GPU Scheduling ON | Enables hardware GPU scheduling | Medium |
| usb_ss_off | USB Selective Suspend OFF | Improves USB stability | Safe |
| privacy_location | Disable Location Service | Turns off location platform | Safe |
| privacy_tailored | Disable Tailored Experiences | Stops ads/tips suggestions | Safe |

---

## 📅 Scheduler

Easily set **daily** or **at-logon** automatic runs from the Scheduler tab:  
- Set time & frequency
- Create or remove scheduled task
- Runs silently in background with chosen profile

---

## ♻ Undo & Restore

- **Undo Last Run** - Reverts last executed tasks (where applicable).
- **Automatic Restore Point** - Created before tweaks.
- **Optional Data Backup** - Documents, Desktop, Pictures, Downloads.

---

## ⚙ Developer Guide

### Adding New Tasks
1. Use `Add-Task` function:
   ```powershell
   Add-Task 'id' 'Name' 'Description' { ActionScript } { UndoScript } @('dependency') $false
   ```
2. Provide **Action** and **Undo** scripts.
3. Add any **dependencies** in `$Dependencies` map.
4. Mark risky tasks with `$true`.

---

## 📜 Disclaimer
**Use at your own risk.**  
This tool modifies system settings, services, and registry keys. Always back up data and ensure you have a recovery plan before running tweaks.

---

## 📸 Screenshots
*(coming soon*

---

## 📬 Contact
For feature requests, bug reports, or contributions, open an issue or pull request.

