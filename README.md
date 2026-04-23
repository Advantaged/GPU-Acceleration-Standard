# GPU-Acceleration-Standard (VA-API)

Standardized procedure for enabling and verifying hardware-accelerated video decoding/encoding. 
*Note: This guide uses CachyOS (Arch-based) as the primary example, but the logic applies to Debian, Fedora, and others with adjusted package names.*

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

## 3. Capability Analysis & SFF Advantages
Successful verification via `vainfo` ensures the GPU handles the heavy lifting instead of the CPU.

| Feature | Advantage for SFF (Intel/AMD iGPU) | Codecs Supported |
| :--- | :--- | :--- |
| **Decoding** | Smooth 4K playback (Netflix/YouTube/VLC) with < 5% CPU load. | H.264, H.265 (HEVC), VP9, AV1 |
| **Thermal Control** | Lower CPU temps = Silent fans on Small Form Factor PCs. | N/A |
| **Encoding** | Zero-lag screen recording and live streaming in OBS Studio. | H.264, H.265 (VCE/VCN/QuickSync) |

---

## 4. Application Layer: Browser & OBS Configuration
The OS-level driver must be explicitly enabled in your applications.

### Firefox / Cachy-Browser
Navigate to `about:config` and verify the following Boolean flags:
* `media.ffmpeg.vaapi.enabled` → **true**
* `media.rdd-ffmpeg.enabled` → **true**
* `media.navigator.mediadatadecoder_vpx_enabled` → **true**

### OBS Studio (CachyOS Optimized)
For the best experience without manual module hunting, use the optimized CachyOS build:
```bash
sudo pacman -S obs-studio-browser
```
*Go to Settings -> Output -> Recording/Streaming and select the **Hardware (VA-API)** encoder.*

---

## 5. System Architecture & Kernel Strategy
In modern Linux (Torvalds' current strategy), drivers are often modular. This allows using optimized kernels like `linux-cachyos-server` while swapping the graphics modules (Mesa) independently.

* **Bootloader:** `limine` (Faster init via `lz4` compression).
* **Filesystem:** `zfs` (Maximum data integrity).
* **Desktop:** `KDE Plasma` (Optimized for hardware interaction).

---

> **ISO 9001 Note:** Always use `libva-utils` to audit the system after any major kernel or driver update to ensure the "VLD" entrypoints remain active.

---

* **Merit to:** [Gemini AI](https://gemini.google.com/)

✅ **Done & Enjoy** ❗️
