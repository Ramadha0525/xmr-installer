#!/bin/bash

# ============================================
# XMRig Installer Script - Enhanced Edition
# Author: Zhii-Sham
# Instagram: zhii.sham
# ============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Banner
print_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                                                          ║"
    echo "║  ██╗  ██╗███╗   ███╗██████╗ ██╗ ██████╗                  ║"
    echo "║  ╚██╗██╔╝████╗ ████║██╔══██╗██║██╔════╝                  ║"
    echo "║   ╚███╔╝ ██╔████╔██║██████╔╝██║██║                       ║"
    echo "║   ██╔██╗ ██║╚██╔╝██║██╔══██╗██║██║                       ║"
    echo "║  ██╔╝ ██╗██║ ╚═╝ ██║██║  ██║██║╚██████╗                  ║"
    echo "║  ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝ ╚═════╝                  ║"
    echo "║                                                          ║"
    echo "║           🚀 XMRig Auto Installer v2.0 🚀               ║"
    echo "║           Author: Zhii-Sham | zhii.sham                 ║"
    echo "║                                                          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Print functions
print_msg() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_err() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[i]${NC} $1"
}

# Progress bar
progress_bar() {
    local duration=${1:-2}
    local bar=""
    for ((i=0; i<50; i++)); do
        bar+="█"
        echo -ne "${CYAN}[$bar${NC}${CYAN}]${NC}\r"
        sleep $(echo "scale=3; $duration/50" | bc)
    done
    echo ""
}

# Check system
check_system() {
    print_info "Checking system..."
    
    if [[ -d "/data/data/com.termux" ]]; then
        print_warn "Termux detected!"
        echo ""
        echo "Select option:"
        echo "1. Install Ubuntu on Termux"
        echo "2. Install directly on Termux"
        echo "3. Exit"
        echo ""
        read -p "Choice [1-3]: " choice
        
        case $choice in
            1)
                install_termux_ubuntu
                ;;
            2)
                print_warn "Direct installation on Termux may have issues"
                read -p "Continue? (y/n): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    return 0
                else
                    exit 0
                fi
                ;;
            3)
                exit 0
                ;;
            *)
                print_err "Invalid choice!"
                exit 1
                ;;
        esac
    else
        print_msg "Linux system detected"
        return 0
    fi
}

# Install Ubuntu on Termux
install_termux_ubuntu() {
    print_info "Installing Ubuntu on Termux..."
    
    pkg update -y && pkg upgrade -y
    pkg install wget proot-distro -y
    proot-distro install ubuntu
    
    print_msg "Ubuntu installed!"
    echo ""
    echo "To continue:"
    echo "1. Run: proot-distro login ubuntu"
    echo "2. Download script again inside Ubuntu"
    echo "3. Run: ./install-xmrig.sh"
    echo ""
    exit 0
}

# Install dependencies
install_deps() {
    print_info "Installing dependencies..."
    
    sudo apt-get update -y
    progress_bar 2
    
    local deps=("git" "build-essential" "cmake" "libuv1-dev" "libssl-dev" "libhwloc-dev")
    
    for dep in "${deps[@]}"; do
        echo -ne "Installing $dep... "
        sudo apt-get install -y $dep > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}✗${NC}"
        fi
    done
    
    print_msg "Dependencies installed"
}

# Build XMRig
build_xmrig() {
    print_info "Building XMRig..."
    
    # Clone
    if [ ! -d "xmrig" ]; then
        git clone https://github.com/xmrig/xmrig.git
        progress_bar 3
    else
        print_warn "XMRig directory exists, updating..."
        cd xmrig
        git pull
        cd ..
    fi
    
    # Build
    mkdir -p xmrig/build
    cd xmrig/build
    
    print_info "Configuring..."
    cmake .. -DCMAKE_BUILD_TYPE=Release
    progress_bar 2
    
    print_info "Compiling..."
    make -j$(nproc)
    progress_bar 5
    
    if [ -f "xmrig" ]; then
        print_msg "XMRig built successfully!"
        cd ../..
    else
        print_err "Build failed!"
        exit 1
    fi
}

# Create config
create_config() {
    print_info "Creating configuration..."
    
    echo ""
    echo "=== Pool Selection ==="
    echo "1. SupportXMR (pool.supportxmr.com:5555)"
    echo "2. MineXMR (minexmr.com:4444)"
    echo "3. Nanopool (xmr-eu1.nanopool.org:14444)"
    echo "4. Kryptex (xmr.kryptex.network:7029)"
    echo "5. Custom"
    echo ""
    read -p "Select pool [1-5]: " pool_choice
    
    case $pool_choice in
        1) POOL="pool.supportxmr.com:5555" ;;
        2) POOL="minexmr.com:4444" ;;
        3) POOL="xmr-eu1.nanopool.org:14444" ;;
        4) POOL="xmr.kryptex.network:7029" ;;
        5)
            read -p "Enter pool (host:port): " POOL
            ;;
        *)
            POOL="pool.supportxmr.com:5555"
            ;;
    esac
    
    echo ""
    read -p "Enter wallet address: " WALLET
    read -p "Enter worker name [worker]: " WORKER
    WORKER=${WORKER:-"worker"}
    
    CORES=$(nproc)
    echo ""
    echo "=== Thread Configuration ==="
    echo "Detected CPU cores: $CORES"
    echo "1. Use all cores ($CORES threads)"
    echo "2. Use half cores ($((CORES/2)) threads)"
    echo "3. Custom"
    echo "4. Auto (let XMRig decide)"
    echo ""
    read -p "Select [1-4]: " thread_choice
    
    case $thread_choice in
        1) THREADS=$CORES ;;
        2) THREADS=$((CORES/2)) ;;
        3)
            read -p "Enter threads [1-$CORES]: " THREADS
            if [[ $THREADS -lt 1 || $THREADS -gt $CORES ]]; then
                THREADS=$CORES
            fi
            ;;
        *) THREADS="auto" ;;
    esac
    
    # Create xmr.sh
    cat > xmr.sh << EOF
#!/bin/bash
# XMRig Mining Script

WALLET="$WALLET"
POOL="$POOL"
WORKER="$WORKER"
THREADS="$THREADS"

echo "========================================"
echo "Starting XMRig Miner"
echo "========================================"
echo "Pool: \$POOL"
echo "Wallet: \$WALLET"
echo "Worker: \$WORKER"
echo "Threads: \$THREADS"
echo "========================================"

cd xmrig/build

./xmrig \\
    --randomx-mode=fast \\
    --threads=\$THREADS \\
    --cpu-max-threads-hint=100 \\
    -o \$POOL \\
    -u \$WALLET \\
    -p \$WORKER \\
    --donate-level=1
EOF
    
    chmod +x xmr.sh
    
    # Create config.txt
    cat > config.txt << EOF
# XMRig Configuration
WALLET="$WALLET"
POOL="$POOL"
WORKER="$WORKER"
THREADS="$THREADS"
EOF
    
    # Create helper scripts
    create_helper_scripts
    
    print_msg "Configuration created!"
}

# Create helper scripts
create_helper_scripts() {
    # start.sh
    cat > start.sh << 'EOF'
#!/bin/bash
echo "Starting XMRig miner..."
echo "To view output: screen -r xmrig"
echo "To detach: Ctrl+A then D"
echo ""
screen -dmS xmrig ./xmr.sh
echo "Miner started in screen session 'xmrig'"
EOF
    
    # stop.sh
    cat > stop.sh << 'EOF'
#!/bin/bash
echo "Stopping XMRig miner..."
screen -S xmrig -X quit 2>/dev/null
pkill -f xmrig 2>/dev/null
echo "Miner stopped"
EOF
    
    # status.sh
    cat > status.sh << 'EOF'
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
EOF
    
    # update_config.sh
    cat > update_config.sh << 'EOF'
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
EOF
    
    chmod +x start.sh stop.sh status.sh update_config.sh
}

# Show instructions
show_instructions() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║               INSTALLATION COMPLETE!                    ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Available commands:${NC}"
    echo "  ./start.sh     - Start mining"
    echo "  ./stop.sh      - Stop mining"
    echo "  ./status.sh    - Check status"
    echo "  ./xmr.sh       - Run miner directly"
    echo "  ./update_config.sh - Update configuration"
    echo ""
    echo -e "${YELLOW}How to start mining:${NC}"
    echo "  1. Edit config.txt if needed"
    echo "  2. Run: ./start.sh"
    echo "  3. View output: screen -r xmrig"
    echo ""
    echo -e "${CYAN}Author: Zhii-Sham${NC}"
    echo -e "${CYAN}Instagram: zhii.sham${NC}"
    echo ""
}

# Main function
main() {
    print_banner
    
    # Check if config-only mode
    if [[ "$1" == "--config-only" ]]; then
        create_config
        exit 0
    fi
    
    # Check system
    if ! check_system; then
        exit 1
    fi
    
    # Install
    install_deps
    build_xmrig
    create_config
    show_instructions
}

# Run main
main "$@"