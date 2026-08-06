#!/bin/bash
echo "=== Mining Status ==="
if screen -list | grep -q "xmrig"; then
    echo "Status: RUNNING"
    echo "Session: xmrig"
    echo "To view: screen -r xmrig"
else
    echo "Status: STOPPED"
fi
echo "===================="
