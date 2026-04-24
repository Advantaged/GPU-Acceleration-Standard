# GPU-Acceleration-Standard (VA-API)

Standardized procedure for enabling and verifying hardware-accelerated video decoding/encoding on **CachyOS**.

---

## 1. System Audit & Discovery
**Goal:** Verify existing capabilities before modifying the system stack.

### 1.1 Install Verification Utility
```bash
# Required for all hardware types (CachyOS/Arch)
sudo pacman -S --needed --noconfirm libva-utils
```

### 1.2 Check Current Driver Status
Execute:
```bash
vainfo
```
* **Status OK:** If you see a list of profiles (e.g., `VAEntrypointVLD`), your drivers are active. Skip to **Point 4.**
* **Status Error:** If you get an error (e.g., `driver not found`), proceed to **Point 1.3.**

### 1.3 Hardware Identification
If **Point 1.2** failed, identify your GPU vendor to select the correct driver:
```bash
lspci -nnk | grep -A 3 -i vga
```
*Identify if you have **AMD**, **Intel**, or **NVIDIA**.*

---

## 2. Hardware-Specific Implementation
Based on the results from **Point 1.3**, follow the logic below.

### 🔴 AMD (Radeon Discrete & Ryzen iGPU)
AMD drivers are typically integrated into the Mesa stack. 
1. **Manual Install (Only if vainfo fails):**
   ```bash
   sudo pacman -S --needed cachyos/libva-mesa-driver cachyos/mesa-vdpau
   ```
2. **Verification:** Repeat **Point 1.2.**

### 🔵 Intel (Integrated UHD/Iris & Discrete Arc)
1. **Install Driver:**
   ```bash
   sudo pacman -S --needed --noconfirm intel-media-driver
   ```
2. **Verification:** Repeat **Point 1.2.**

### 🟢 NVIDIA (GeForce GTX/RTX)
1. **Install Driver & Wrapper:**
   ```bash
   sudo pacman -S --needed --noconfirm nvidia-utils nvidia-vaapi-driver
   ```
2. **Verification:** Repeat **Point 1.2.**

---

## 3. Hardware Integrity (ISO 9001 Compliance)
Hardware acceleration increases the power draw of the GPU. To ensure system stability, follow these physical infrastructure rules:

* **3.1 Bootloader Sync:** Always verify your bootloader (Grub/Limine/rEFInd/Systemd-Boot) is updated if the kernel was touched during the driver installation.
* **3.2 Cold Boot Requirement:** After making significant changes to the Hardware Acceleration stack, a **Cold Boot** (full shutdown and restart) is required to ensure the Kernel Mode Setting (KMS) and BIOS/UEFI handshakes are clean.
* **3.3 The Dual-Cable Rule (High-End GPUs):** For cards like the AMD Vega 64, do **not** use a single "pig-tail" (bridged) cable for two power connectors. Use two independent cables directly from the PSU to prevent voltage sags.

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

### 5.1 Firefox / Cachy-Browser
Navigate to `about:config` and verify the following Boolean flags:
* `media.ffmpeg.vaapi.enabled` → **true**
* `media.rdd-ffmpeg.enabled` → **true**
* `media.navigator.mediadatadecoder_vpx_enabled` → **true**

### 5.2 OBS Studio (CachyOS Optimized)
```bash
sudo pacman -S obs-studio-browser
```
*Go to: **File -> Settings -> Output**. Set **Output Mode** to **Advanced**. Under the **Recording** or **Streaming** tab, select the **Hardware (VA-API)** encoder.*

---

## 6. Troubleshooting: UI Geometry & Refresh

If you experience UI glitches (e.g., overlapping icons in the Application Menu or layout shifts) after enabling HWA, follow this two-step escalation:

### Step 6.A: Scaling Display, Fonts & Browser Zoom (Recommended)
High DPI settings on 28" displays often cause mathematical rounding errors in Wayland.
1. **Reduce Display Scaling:** Go to `System Settings` -> `Input & Output` -> `Display & Monitor`. Set `Scale` to **175%** (The CachyOS Sweet Spot).
2. **Compensate with Fonts:** Go to `System Settings` -> `Appearance & Style` -> `Text & Fonts`. Increase your font size (e.g., from `10pt` to **`12pt`**).
3. **Adjust Browser Zoom:** Set your default zoom in the browser to your preference (e.g., 120% or higher).

### Step 6.B: GUI Cache Refresh (Ultima Ratio)
If scaling adjustments do not resolve the glitch, use the maintenance script to purge the Plasma 6 cache.

**Procedure:**
1. **Download/Create:** Use the [`clean-restart-plasma.sh`](clean-restart-plasma.sh) script.
2. **Apply permissions:** `chmod +x clean-restart-plasma.sh`
3. **Execute:** `./clean-restart-plasma.sh`
*Note: Ensure you leave one empty line at the end of the script file to satisfy POSIX standards.*

---

## 7. System Architecture & Kernel Strategy
In modern Linux, drivers are modular. This allows using optimized kernels like `linux-cachyos-server` while swapping the graphics modules independently in the user space.

* **Bootloader:** `limine` (Highly recommended: The CachyOS installer enables rapid `lz4` compression specifically through Limine).
* **Filesystem:** `zfs` (CachyOS is the only desktop OS offering ZFS natively OOTB via the Calamares installer, providing enterprise-grade data integrity and snapshots).
* **Desktop:** `KDE Plasma` (Native vector graphics and superior Wayland support).

---

* **Merit to:** [Gemini AI](https://gemini.google.com/)
* **License:** CC0 1.0 Universal

✅ **Done & Enjoy** ❗️
