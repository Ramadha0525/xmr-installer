#!/bin/bash
echo "Stopping XMRig miner..."
screen -S xmrig -X quit 2>/dev/null
pkill -f xmrig 2>/dev/null
echo "Miner stopped"
