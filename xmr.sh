#!/bin/bash
WALLET="krxXG66PZ4.worker"
POOL="xmr.kryptex.network:7029"

echo "Starting XMRig with fast mode..."

./xmrig --randomx-mode=fast --threads=8 --cpu-max-threads-hint=100 -o $POOL -u $WALLET -p x
