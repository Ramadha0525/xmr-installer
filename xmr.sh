#!/bin/bash
# XMRig Mining Script

WALLET="krxXG66PZ4"
POOL="pool.supportxmr.com:5555"
WORKER="workergit"
THREADS="auto"

echo "========================================"
echo "Starting XMRig Miner"
echo "========================================"
echo "Pool: $POOL"
echo "Wallet: $WALLET"
echo "Worker: $WORKER"
echo "Threads: $THREADS"
echo "========================================"

cd xmrig/build

./xmrig \
    --randomx-mode=fast \
    --threads=$THREADS \
    --cpu-max-threads-hint=100 \
    -o $POOL \
    -u $WALLET \
    -p $WORKER \
    --donate-level=1
