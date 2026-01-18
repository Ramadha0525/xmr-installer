#!/data/data/com.termux/files/usr/bin/bash

# ==============================================
# UBUNTU-IN-TERMUX INSTALLER - ENHANCED VERSION
# ==============================================

# Warna untuk output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
ORANGE='\033[1;38;5;214m'
PURPLE='\033[1;38;5;129m'
RESET='\033[0m'

# Simbol untuk tampilan
CHECK_MARK="✓"
CROSS_MARK="✗"
ARROW="➜"
STAR="✦"
DOT="●"
LINE="─"
BOX_TOP="╭"
BOX_MID="├"
BOX_BOT="╰"
BOX_CORNER="╰"

# Animasi loading
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Fungsi untuk header
print_header() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                                                          ║"
    echo "║      ██╗   ██╗██████╗ ██╗   ██╗███╗   ██╗████████╗██╗   ║"
    echo "║      ██║   ██║██╔══██╗██║   ██║████╗  ██║╚══██╔══╝██║   ║"
    echo "║      ██║   ██║██████╔╝██║   ██║██╔██╗ ██║   ██║   ██║   ║"
    echo "║      ██║   ██║██╔══██╗██║   ██║██║╚██╗██║   ██║   ██║   ║"
    echo "║      ╚██████╔╝██║  ██║╚██████╔╝██║ ╚████║   ██║   ██║   ║"
    echo "║       ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝   ║"
    echo "║                                                          ║"
    echo "║                I N - T E R M U X                         ║"
    echo "║                                                          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e "${CYAN}╭${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}╮${RESET}"
    echo -e "${CYAN}│ ${WHITE}Version: ${GREEN}24.10 ${WHITE}| ${WHITE}Architecture: ${GREEN}$(dpkg --print-architecture) ${WHITE}| ${WHITE}Status:${RESET}"
    echo -e "${CYAN}╰${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}╯${RESET}"
    echo ""
}

# Fungsi untuk pesan informasi
print_info() {
    echo -e "${CYAN}${ARROW} ${WHITE}$1${RESET}"
}

# Fungsi untuk pesan sukses
print_success() {
    echo -e "${GREEN}${CHECK_MARK} ${WHITE}$1${RESET}"
}

# Fungsi untuk pesan error
print_error() {
    echo -e "${RED}${CROSS_MARK} ${WHITE}$1${RESET}"
}

# Fungsi untuk pesan peringatan
print_warning() {
    echo -e "${YELLOW}${STAR} ${WHITE}$1${RESET}"
}

# Fungsi untuk pesan proses
print_process() {
    echo -e "${BLUE}${DOT} ${WHITE}$1${RESET}"
}

# Fungsi untuk progress bar
progress_bar() {
    local duration=$1
    local width=50
    local increment=$((100/$width))
    local count=0
    printf "\n${CYAN}["
    
    while [ $count -lt 100 ]; do
        printf "▓"
        count=$((count + increment))
        sleep $(echo "scale=4; $duration/$width" | bc)
    done
    
    printf "]${RESET}"
    echo ""
}

# Fungsi utama install
install_ubuntu() {
    print_header
    
    directory="ubuntu-fs"
    UBUNTU_VERSION='24.10'
    time1="$(date +"%H:%M:%S")"
    
    # Cek jika direktori sudah ada
    if [ -d "$directory" ]; then
        print_warning "Ubuntu directory already exists!"
        print_info "Skipping download and extraction..."
        echo ""
        first=1
    else
        first=0
    fi
    
    # Cek dependensi
    print_process "Checking system requirements..."
    echo -e "${CYAN}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${RESET}"
    
    # Cek proot
    if [ -z "$(command -v proot)" ]; then
        print_error "PROOT is not installed!"
        print_info "Please install proot with: pkg install proot"
        exit 1
    else
        print_success "PROOT is installed"
    fi
    
    # Cek wget
    if [ -z "$(command -v wget)" ]; then
        print_error "WGET is not installed!"
        print_info "Please install wget with: pkg install wget"
        exit 1
    else
        print_success "WGET is installed"
    fi
    
    # Cek arsitektur
    ARCHITECTURE=$(dpkg --print-architecture)
    case "$ARCHITECTURE" in
        aarch64) ARCH="arm64" ;;
        arm) ARCH="armhf" ;;
        amd64|x86_64) ARCH="amd64" ;;
        *)
            print_error "Unsupported architecture: $ARCHITECTURE"
            exit 1
            ;;
    esac
    print_success "Architecture detected: $ARCH"
    
    echo ""
    
    # Jika belum ada, download dan ekstrak
    if [ "$first" != 1 ]; then
        print_process "Starting Ubuntu installation..."
        echo ""
        
        # Download rootfs
        if [ ! -f "ubuntu.tar.gz" ]; then
            print_process "Downloading Ubuntu ${UBUNTU_VERSION} rootfs for ${ARCH}..."
            print_info "This may take a few minutes depending on your connection"
            echo ""
            
            # Download dengan progress bar
            wget --show-progress -q --progress=bar:force \
                 "https://cdimage.ubuntu.com/ubuntu-base/releases/${UBUNTU_VERSION}/release/ubuntu-base-${UBUNTU_VERSION}-base-${ARCH}.tar.gz" \
                 -O ubuntu.tar.gz &
            wget_pid=$!
            
            # Tampilkan spinner selama download
            spinner $wget_pid
            wait $wget_pid
            
            echo ""
            print_success "Download completed successfully!"
            echo ""
        else
            print_warning "Ubuntu rootfs already downloaded"
        fi
        
        # Ekstraksi
        print_process "Extracting Ubuntu rootfs..."
        mkdir -p $directory
        cur=$(pwd)
        cd $directory
        
        # Simulasikan progress bar untuk ekstraksi
        print_info "Extracting files, please wait..."
        (proot --link2symlink tar -zxf $cur/ubuntu.tar.gz --exclude='dev' 2>/dev/null) &
        extract_pid=$!
        spinner $extract_pid
        wait $extract_pid
        
        print_success "Extraction completed!"
        echo ""
        
        # Konfigurasi
        print_process "Configuring Ubuntu environment..."
        
        # Fix resolv.conf
        print_info "Configuring DNS..."
        printf "nameserver 8.8.8.8\nnameserver 8.8.4.4\n" > etc/resolv.conf
        print_success "DNS configured"
        
        # Write stubs
        print_info "Setting up system stubs..."
        stubs=('usr/bin/groups')
        for f in ${stubs[@]}; do
            echo -e "#!/bin/sh\nexit" > "$f"
            chmod +x "$f"
        done
        print_success "System stubs created"
        
        cd $cur
        echo ""
    fi
    
    # Buat direktori binds
    print_process "Creating bind directories..."
    mkdir -p ubuntu-binds
    print_success "Bind directories created"
    echo ""
    
    # Buat start script
    print_process "Creating startup script..."
    bin="start-ubuntu.sh"
    
    cat > $bin <<- EOM
#!/bin/bash

# ==========================================
# UBUNTU IN TERMUX - START SCRIPT
# ==========================================

echo -e "\033[1;36m"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                   Starting Ubuntu...                     ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "\033[0m"

cd \$(dirname \$0)
unset LD_PRELOAD

command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $directory"

# Bind directories
command+=" -b /dev"
command+=" -b /proc"
command+=" -b /sys"
command+=" -b ubuntu-fs/tmp:/dev/shm"
command+=" -b /data/data/com.termux"
command+=" -b /:/host-rootfs"
command+=" -b /sdcard"
command+=" -b /storage"
command+=" -b /mnt"
command+=" -w /root"

# Environment variables
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"

com="\$@"

echo -e "\033[1;33m[\033[1;36m*\033[1;33m] Preparing Ubuntu environment...\033[0m"
sleep 1

if [ -z "\$1" ]; then
    echo -e "\033[1;32m[\033[1;36m✓\033[1;32m] Ubuntu is ready! Type 'exit' to return to Termux\033[0m"
    echo ""
    exec \$command
else
    \$command -c "\$com"
fi
EOM
    
    # Fix shebang dan permissions
    termux-fix-shebang $bin 2>/dev/null
    chmod +x $bin
    
    print_success "Startup script created: ./$bin"
    echo ""
    
    # Cleanup
    print_process "Cleaning up temporary files..."
    if [ -f "ubuntu.tar.gz" ]; then
        rm -f ubuntu.tar.gz
        print_success "Temporary files cleaned"
    fi
    echo ""
    
    # Tampilkan informasi akhir
    print_header
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║           INSTALLATION COMPLETED SUCCESSFULLY!          ║${RESET}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    print_success "Ubuntu ${UBUNTU_VERSION} has been installed!"
    echo ""
    print_info "Available commands:"
    echo -e "  ${CYAN}./start-ubuntu.sh${WHITE}        - Start Ubuntu"
    echo -e "  ${CYAN}./start-ubuntu.sh <command>${WHITE} - Run command in Ubuntu"
    echo ""
    print_info "Quick start:"
    echo -e "  ${GREEN}1. ${WHITE}Run ${CYAN}./start-ubuntu.sh${WHITE}"
    echo -e "  ${GREEN}2. ${WHITE}Update packages: ${CYAN}apt update && apt upgrade${WHITE}"
    echo -e "  ${GREEN}3. ${WHITE}Install packages: ${CYAN}apt install <package-name>${WHITE}"
    echo ""
    print_warning "Note: Use 'exit' to return to Termux"
    echo ""
    echo -e "${PURPLE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${RESET}"
    echo ""
}

# Fungsi untuk tampilan awal
show_welcome() {
    print_header
    echo -e "${GREEN}Welcome to Ubuntu-in-Termux Installer!${RESET}"
    echo ""
    print_info "This script will install Ubuntu ${UBUNTU_VERSION} in Termux"
    echo ""
    print_warning "Requirements:"
    echo -e "  ${WHITE}• ${CYAN}Internet connection${RESET}"
    echo -e "  ${WHITE}• ${CYAN}At least 500MB free storage${RESET}"
    echo -e "  ${WHITE}• ${CYAN}Proot and Wget installed${RESET}"
    echo ""
    print_info "Installation includes:"
    echo -e "  ${WHITE}• ${GREEN}Ubuntu base system${RESET}"
    echo -e "  ${WHITE}• ${GREEN}Basic configuration${RESET}"
    echo -e "  ${WHITE}• ${GREEN}Network setup${RESET}"
    echo -e "  ${WHITE}• ${GREEN}Startup script${RESET}"
    echo ""
    echo -e "${YELLOW}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${LINE}${RESET}"
    echo ""
}

# Main script logic
main() {
    if [ "$1" = "-y" ] || [ "$1" = "--yes" ]; then
        install_ubuntu
    elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        print_header
        echo -e "${CYAN}Usage:${RESET}"
        echo -e "  ${WHITE}./ubuntu.sh${RESET}           - Interactive installation"
        echo -e "  ${WHITE}./ubuntu.sh -y${RESET}        - Automatic installation"
        echo -e "  ${WHITE}./ubuntu.sh --help${RESET}    - Show this help"
        echo ""
        exit 0
    elif [ "$1" = "" ]; then
        show_welcome
        
        echo -ne "${YELLOW}Do you want to continue with installation? [Y/n]: ${RESET}"
        read -n 1 -r response
        echo ""
        
        if [[ $response =~ ^[Yy]$ ]] || [[ -z $response ]]; then
            echo ""
            install_ubuntu
        else
            echo ""
            print_error "Installation cancelled by user"
            echo ""
            exit 0
        fi
    else
        print_error "Invalid option: $1"
        print_info "Use --help for usage information"
        exit 1
    fi
}

# Jalankan main function
main "$@"
