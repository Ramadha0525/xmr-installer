#!/bin/bash
echo "Updating configuration..."
if [ -f "config.txt" ]; then
    source config.txt
    echo "Current config:"
    echo "Wallet: $WALLET"
    echo "Pool: $POOL"
    echo "Worker: $WORKER"
    echo ""
    read -p "Update? (y/n): " choice
    if [[ $choice == "y" ]]; then
        ./install-xmrig.sh --config-only
    fi
else
    echo "Config file not found!"
fi
