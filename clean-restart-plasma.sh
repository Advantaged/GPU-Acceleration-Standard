#!/bin/bash
# -------------------------------------------------------------------------
# Name: clean-restart-plasma.sh
# Purpose: Detect Plasma version, purge cache, and restart shell safely.
# Compliance: ISO-9001 Standard
# -------------------------------------------------------------------------

# 1. Version Detection
P_VERSION=$(plasmashell --version | awk '{print $2}' | cut -d. -f1)

if [[ "$P_VERSION" -ge 6 ]]; then
    QUIT_CMD="kquitapp6"
elif [[ "$P_VERSION" -eq 5 ]]; then
    QUIT_CMD="kquitapp5"
else
    QUIT_CMD="killall"
fi

echo "Detected Plasma $P_VERSION. Using $QUIT_CMD..."

# 2. Execution
$QUIT_CMD plasmashell || killall -9 plasmashell
sleep 2

# Purge Caches
rm -rf ~/.cache/plasmashell*
rm -rf ~/.cache/ico*
rm -rf ~/.cache/org.kde.dirmodel-cache
rm -rf ~/.cache/ksycoca*

# Restart
kstart plasmashell > /dev/null 2>&1 &

echo "✅ UI refreshed for Plasma $P_VERSION."
