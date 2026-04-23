# GPU-Acceleration-Standard (VA-API)

Standardized procedure for enabling and verifying hardware-accelerated video decoding/encoding on **CachyOS**.

---

## 1. Prerequisites
Before modifying the system stack, install the verification utility. This is the **Primary Step** to prevent redundant driver installation.

```bash
# Required for all hardware types (CachyOS/Arch)
sudo pacman -S --needed --noconfirm libva-utils
```

---

## 2. Hardware-Specific Implementation (iGPU & Discrete)
Whether you use an integrated GPU (SFF machines) or a discrete card (Vega 64), follow the logic below.

### 🔴 AMD (Radeon Discrete & Ryzen iGPU)
AMD drivers are typically integrated into the Mesa stack. **Verification must precede installation.**

1. **Check existing status:**
   ```bash
   vainfo
   ```
2. **Logic:** If `vainfo` displays codec profiles (e.g., `VAEntrypointVLD`), **no further action is required.**
3. **Manual Install (Only if vainfo fails):**
   ```bash
   # Stable Branch (Recommended)
   sudo pacman -S --needed cachyos/libva-mesa-driver cachyos/mesa-vdpau
   ```

### 🔵 Intel (Integrated UHD/Iris & Discrete Arc)
Standard for Dell Optiplex SFFs. Highly recommended to reduce CPU heat during streaming.

1. **Install Driver:**
   ```bash
   sudo pacman -S --needed --noconfirm intel-media-driver
   ```
2. **Verify:**
   ```bash
   vainfo
   ```

### 🟢 NVIDIA (GeForce GTX/RTX)
1. **Install Driver & Wrapper:**
   ```bash
   sudo pacman -S --needed --noconfirm nvidia-utils nvidia-vaapi-driver
   ```

---

## 3. Hardware Integrity (ISO 9001 Compliance)
Hardware acceleration increases the power draw of the GPU. To ensure system stability, follow these physical infrastructure rules:

* **Bootloader Sync:** Always verify your bootloader (Grub/Limine/rEFInd/Systemd-Boot) is updated if the kernel was touched during the driver installation.
* **Cold Boot Requirement:** After making significant changes to the Hardware Acceleration stack, a **Cold Boot** (full shutdown and restart) is required to ensure the Kernel Mode Setting (KMS) and BIOS/UEFI handshakes are clean.
* **The Dual-Cable Rule (High-End GPUs):** For cards like the AMD Vega 64, do **not** use a single "pig-tail" (bridged) cable for two power connectors. Use two independent cables directly from the PSU to prevent voltage sags.

---

## 4. Capability Analysis & Advantages
Successful verification via `vainfo` ensures the GPU handles the heavy lifting instead of the CPU.

| Feature | Advantage for SFF (Intel/AMD iGPU) | Codecs Supported |
| :--- | :--- | :--- |
| **Decoding** | Smooth 4K playback (Netflix/YouTube/VLC) with < 5% CPU load. | H.264, H.265 (HEVC), VP9, AV1 |
| **Thermal Control** | Lower CPU temps = Silent fans on Small Form Factor PCs. | N/A |
| **Encoding** | Zero-lag screen recording and live streaming in OBS Studio. | H.264, H.265 (VCE/VCN/QuickSync) |

---

## 5. Application Layer: Browser & OBS Configuration
The OS-level driver must be explicitly enabled in your applications.

### Firefox / Cachy-Browser
Navigate to `about:config` and verify the following Boolean flags:
* `media.ffmpeg.vaapi.enabled` → **true**
* `media.rdd-ffmpeg.enabled` → **true**
* `media.navigator.mediadatadecoder_vpx_enabled` → **true**

### OBS Studio (CachyOS Optimized)
```bash
sudo pacman -S obs-studio-browser
```
*Go to Settings -> Output -> Recording/Streaming and select the **Hardware (VA-API)** encoder.*

---

## 6. Troubleshooting: UI Geometry & Refresh

If you experience UI glitches (e.g., overlapping icons in the Application Menu or layout shifts) after enabling HWA, follow this two-step escalation:

### Step A: Scaling Display, Fonts & Browser Zoom (Recommended)
High DPI settings (like 200% or 225%) on 28" displays often cause mathematical rounding errors in Wayland, leading to "KickOff" menu overlaps.

1. **Reduce Display Scaling:** Go to `System Settings` -> `Input & Output` -> `Display & Monitor`. Set `Scale` to **175%** (The CachyOS Sweet Spot).
2. **Compensate with Fonts:** Go to `System Settings` -> `Appearance & Style` -> `Text & Fonts`. Increase your font size (e.g., from `10pt` to **`12pt`**). This maintains high visibility and readability across the OS.
3. **Adjust Browser Zoom:** In Firefox, Brave, or Cachy-Browser, set the default zoom to your preference (e.g., 120% or higher) to compensate for the lower system scaling.

*This "Fractional Down-scaling" strategy prevents geometry overlaps while keeping the interface quick, vivid, sharp, and readable.*

### Step B: GUI Cache Refresh (Ultima Ratio)
If scaling adjustments do not resolve the glitch, use the maintenance script to purge the Plasma 6 cache and force a redraw.

**Procedure:**
1. **Download/Create:** Use the [`clean-restart-plasma.sh`](clean-restart-plasma.sh) script.
2. **Apply permissions:** `chmod +x clean-restart-plasma.sh`
3. **Execute:** `./clean-restart-plasma.sh`
*Note: Ensure you leave one empty line at the end of the script file to satisfy POSIX standards.*

---

## 7. System Architecture & Kernel Strategy
In modern Linux, drivers are modular. This allows using optimized kernels like `linux-cachyos-server` while swapping the graphics modules (Mesa) independently in the user space.

* **Bootloader:** `limine` (Highly recommended: The CachyOS installer enables rapid `lz4` compression specifically through Limine).
* **Filesystem:** `zfs` (CachyOS is the only desktop OS offering ZFS natively OOTB via the Calamares installer, providing enterprise-grade data integrity and snapshots).
* **Desktop:** `KDE Plasma` (Native vector graphics and superior Wayland support).

---

* **Merit to:** [Gemini AI](https://gemini.google.com/)
* **License:** CC0 1.0 Universal

✅ **Done & Enjoy** ❗️
