# TTY Recovery & Flake Activation Guide

This guide provides step-by-step instructions to replace your broken NixOS configuration (Gnome/Hyprland in `/etc/nixos/`) with your new flake-based configuration (`~/NixOS-Hyprland/`) using only the TTY, clean up old configurations, and free up disk space.

---

## Step 1: Back Up the Old Configuration
To clean up and ensure a fresh start, back up your old `/etc/nixos/` files so they do not cause conflicts:
```bash
sudo mv /etc/nixos /etc/nixos.bak
```

---

## Step 2: Prepare the Flake Configuration
Go to your flake directory in your user home:
```bash
cd ~/NixOS-Hyprland
```
Nix flakes **require all configuration files to be tracked in Git** to be read. Since this is already a Git repository, ensure your latest local changes (including the removal of Chrome, Firefox, and Quickshell) are staged and committed:
```bash
git add .
git commit -m "Clean up: remove quickshell, chrome, and firefox"
```

---

## Step 3: Rebuild and Switch to the Flake
Run the rebuild command. This tells NixOS to build your system from the local flake configuration (`#sastapc`) instead of `/etc/nixos/`:
```bash
sudo nixos-rebuild switch --flake .#sastapc
```
*Note: Since you are on Intel graphics, the GPU drivers and display server setup (SDDM Display Manager + Hyprland) will be built and activated. This will automatically replace the broken Gnome/Hyprland environment.*

---

## Step 4: Reclaim Disk Space & Start Fresh
Because you rebuilt the system, Nix has kept the old configurations in the Nix store so you can roll back if needed. Since you want to remove the broken configs completely and reduce disk space (solving the 15-16 GB bloat):

1. **Delete old user configurations**:
   ```bash
   nix-collect-garbage --delete-old
   ```
2. **Delete old system-wide configurations (requires sudo)**:
   ```bash
   sudo nix-collect-garbage -d
   ```
3. **Hardlink duplicate files to free more space**:
   ```bash
   sudo nix-store --optimise
   ```
*(You can also use your pre-installed helper script `ncg` in the future, which runs garbage collection automatically.)*

---

## Step 5: Reboot into Hyprland
Once the build and cleanup are complete, reboot the system:
```bash
reboot
```
The computer will reboot into **SDDM** (the login screen). Log in as `sastauser`, and you will boot into your fresh Hyprland environment.

---

## Troubleshooting & Key Context

### 1. Estimated Space & Build Size
- **Download size**: ~2 GB to 4 GB of compressed packages.
- **Installed size**: ~8 GB to 10 GB in `/nix/store` after compiling and removing Chrome/Firefox.
- **Minimum free space required**: At least **15 GB** of free space on your partition (Nix needs temporary scratch space to build things like custom `waybar` and `waybar-weather`).

---

### 2. Preventing Crashes during Build (100% CPU / Process Dies)
Nix compiles several packages (like `waybar` and `waybar-weather`) from source. By default, Nix uses all your CPU cores, which spawns multiple compiler threads. This can easily exhaust your RAM (Out-Of-Memory/OOM), causing the Linux kernel to immediately kill the build process.

If your build crashes or the process dies:

#### Option A: Scale build parameters to match your RAM (Highly Recommended)
Nix allows limiting parallel building to protect your memory. You can balance speed and stability based on your RAM size:
- **8 GB RAM**: Run 1 job on 2 cores (very safe):
  ```bash
  sudo nixos-rebuild switch --max-jobs 1 --cores 2 --flake .#sastapc
  ```
- **16 GB RAM**: Run 1 job on 4 cores (faster, standard):
  ```bash
  sudo nixos-rebuild switch --max-jobs 1 --cores 4 --flake .#sastapc
  ```
- **32 GB+ RAM**: Run default or slightly limited:
  ```bash
  sudo nixos-rebuild switch --max-jobs 2 --cores 6 --flake .#sastapc
  ```
*Adjust `--cores <N>` depending on your system. Keeping `--max-jobs 1` ensures heavy compilation tasks (like Waybar and Nixvim) do not run concurrently, preventing memory spikes.*

#### Option B: Enable a temporary swap file (If you have low RAM)
If your TTY does not have active swap space, you can create a temporary 4GB swap file on your disk before rebuilding:
```bash
# 1. Create a 4GB temporary swap file
sudo dd if=/dev/zero of=/swapfile bs=1M count=4096
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 2. Rebuild the configuration
sudo nixos-rebuild switch --max-jobs 1 --flake .#sastapc

# 3. Clean up the swap file after the build completes successfully
sudo swapoff /swapfile
sudo rm /swapfile
```

---

### 3. Display Manager Conflict Resolved
Previously, the configuration failed because both **Ly** and **SDDM** were enabled. We solved this in your `hosts/sastapc/config.nix` by forcing Ly off:
`services.displayManager.ly.enable = lib.mkForce false;`
Your system will now boot safely into SDDM.

---

### 4. Disk Space Culprits
If your space is still tight in the future, run:
```bash
sudo ncdu /nix/store
```
This interactive tool will list every directory in the Nix store sorted by size, letting you see exactly what packages (such as build tools like `go`/`rustc`/`gcc` or utilities like `pandoc`) are taking up space.
