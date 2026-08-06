#!/bin/bash
echo "Starting XMRig miner..."
echo "To view output: screen -r xmrig"
echo "To detach: Ctrl+A then D"
echo ""
screen -dmS xmrig ./xmr.sh
echo "Miner started in screen session 'xmrig'"
