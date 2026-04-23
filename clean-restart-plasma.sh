#!/bin/bash
# -------------------------------------------------------------------------
# Name: clean-restart-plasma.sh
# Refreshes the Plasma 6 UI by purging temporary caches
# -------------------------------------------------------------------------

echo "Stopping Plasmashell..."
kquitapp6 plasmashell || killall -9 plasmashell
sleep 2

echo "Purging localized GUI caches..."
rm -rf ~/.cache/plasmashell*
rm -rf ~/.cache/ico*
rm -rf ~/.cache/org.kde.dirmodel-cache
rm -rf ~/.cache/ksycoca*

echo "Restarting Plasmashell..."
kstart plasmashell > /dev/null 2>&1 &
echo "✅ Done. UI refreshed."
