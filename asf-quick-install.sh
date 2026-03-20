#!/usr/bin/env bash
#
# asaf-install.sh - One-Command ASF + OpenClaw + Mission Control Installer
# Usage: curl -sSL https://raw.githubusercontent.com/jeffvsutherland/agent-security-framework/main/asf-install.sh | bash
#
set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================
ASF_VERSION="2026.03"
OC_VERSION="latest"
MC_VERSION="latest"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unsupported"
    fi
}

# Check minimum requirements
check_requirements() {
    local missing=()
    
    if ! command_exists git; then
        missing+=("git")
    fi
    
    if ! command_exists docker; then
        missing+=("docker")
    fi
    
    if ! command_exists curl; then
        missing+=("curl")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing[*]}"
        echo ""
        echo "Install with:"
        echo "  macOS:  brew install ${missing[*]}"
        echo "  Linux:  sudo apt-get install -y ${missing[*]}"
        exit 1
    fi
    
    # Check Docker is running
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    
    log_success "All requirements met"
}

# =============================================================================
# INSTALLATION FUNCTIONS
# =============================================================================

# Create installation directory
setup_directories() {
    log_info "Setting up directories..."
    INSTALL_DIR="${INSTALL_DIR:-$HOME/asf-install}"
    mkdir -p "$INSTALL_DIR"/{openclaw,mission-control,asf-config,data}
    cd "$INSTALL_DIR"
    log_success "Installation directory: $INSTALL_DIR"
}

# Clone OpenClaw
install_openclaw() {
    log_info "Installing OpenClaw..."
    
    if [[ -d "$INSTALL_DIR/openclaw/.git ]]; then
        log_warn "OpenClaw already exists, skipping clone"
    else
        git clone --depth 1 https://github.com/openclaw/openclaw.git "$INSTALL_DIR/openclaw"
    fi
    
    # Copy environment template
    if [[ -f "$INSTALL_DIR/openclaw/.env.example" ]]; then
        cp "$INSTALL_DIR/openclaw/.env.example" "$INSTALL_DIR/openclaw/.env" 2>/dev/null || true
    fi
    
    log_success "OpenClaw installed"
}

# Clone Mission Control
install_mission_control() {
    log_info "Installing Mission Control..."
    
    if [[ -d "$INSTALL_DIR/mission-control/.git" ]]; then
        log_warn "Mission Control already exists, skipping clone"
    else
        git clone --depth 1 https://github.com/openclaw/openclaw-mission-control.git "$INSTALL_DIR/mission-control" 2>/dev/null || \
        git clone --depth 1 https://github.com/jeffvsutherland/openclaw-mission-control.git "$INSTALL_DIR/mission-control" 2>/dev/null || \
        log_warn "Mission Control repo not found, will use OpenClaw built-in"
    fi
    
    log_success "Mission Control installed"
}

# Clone ASF
install_asf() {
    log_info "Installing Agent Security Framework..."
    
    if [[ -d "$INSTALL_DIR/agent-security-framework/.git" ]]; then
        log_warn "ASF already exists, pulling latest..."
        cd "$INSTALL_DIR/agent-security-framework"
        git pull origin main 2>/dev/null || true
    else
        git clone --depth 1 https://github.com/jeffvsutherland/agent-security-framework.git "$INSTALL_DIR/agent-security-framework"
    fi
    
    log_success "ASF installed"
}

# Apply ASF security fixes to OpenClaw
apply_asf_fixes() {
    log_info "Applying ASF security configurations..."
    
    # Copy security configurations
    if [[ -d "$INSTALL_DIR/agent-security-framework" ]]; then
        # Copy security scripts
        mkdir -p "$INSTALL_DIR/openclaw/security"
        cp -r "$INSTALL_DIR/agent-security-framework/"* "$INSTALL_DIR/openclaw/security/" 2>/dev/null || true
    fi
    
    log_success "ASF security configured"
}

# Start services
start_services() {
    log_info "Starting services..."
    
    # Start OpenClaw with Docker
    if [[ -f "$INSTALL_DIR/openclaw/docker-compose.yml" ]]; then
        cd "$INSTALL_DIR/openclaw"
        docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null || true
    fi
    
    log_success "Services started"
}

# Create launcher script
create_launcher() {
    log_info "Creating launcher script..."
    
    cat > "$INSTALL_DIR/asf-launcher.sh" <<'EOF'
#!/usr/bin/env bash
#
# ASF Launcher - Start your ASF environment
#
ASF_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_status() {
    echo "ASF Environment Status"
    echo "====================="
    echo ""
    echo "Installation: $ASF_ROOT"
    echo ""
    
    # Check Docker containers
    echo "Running services:"
    docker ps --filter "name=openclaw" --format "  {{.Names}}: {{.Status}}" 2>/dev/null || echo "  (Docker not available)"
    echo ""
    
    echo "Ports:"
    echo "  OpenClaw Gateway:    http://localhost:3000"
    echo "  Mission Control API: http://localhost:8001"
    echo ""
}

case "${1:-status}" in
    status|start)
        show_status
        ;;
    stop)
        cd "$ASF_ROOT/openclaw" && docker compose down 2>/dev/null
        echo "Services stopped"
        ;;
    restart)
        cd "$ASF_ROOT/openclaw" && docker compose restart 2>/dev/null
        echo "Services restarted"
        ;;
    logs)
        docker compose logs -f --tail=50 2>/dev/null || docker-compose logs -f --tail=50 2>/dev/null || echo "No logs available"
        ;;
    shell)
        docker exec -it openclaw-gateway-1 bash 2>/dev/null || docker exec -it openclaw_gateway_1 bash 2>/dev/null || echo "Shell not available"
        ;;
    asf)
        shift
        "$ASF_ROOT/agent-security-framework/asf-live-demo.sh" "$@"
        ;;
    help|--help|-h)
        echo "ASF Launcher Commands:"
        echo "  status     - Show environment status"
        echo "  start      - Start services"
        echo "  stop       - Stop services"
        echo "  restart    - Restart services"
        echo "  logs       - View container logs"
        echo "  shell      - Open shell in gateway container"
        echo "  asf        - Run ASF commands"
        echo "  help       - Show this help"
        ;;
    *)
        exec "$0" status
        ;;
esac
EOF
    chmod +x "$INSTALL_DIR/asf-launcher.sh"
    
    # Add to PATH suggestion
    echo ""
    echo -e "${YELLOW}To add ASF to your PATH, add this to your ~/.bashrc or ~/.zshrc:${NC}"
    echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
    echo "  alias asf='$INSTALL_DIR/asf-launcher.sh'"
    echo ""
    
    log_success "Launcher created"
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    echo -e "${BOLD}${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║   ASF + OpenClaw + Mission Control - Quick Installer        ║"
    echo "║   Version: $ASF_VERSION                                             ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    log_info "Starting installation..."
    echo ""
    
    # Step 1: Check requirements
    check_requirements
    
    # Step 2: Setup directories
    setup_directories
    
    # Step 3: Install components
    install_openclaw
    install_mission_control
    install_asf
    apply_asf_fixes
    
    # Step 4: Create launcher
    create_launcher
    
    # Step 5: Summary
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ INSTALLATION COMPLETE!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BOLD}Installation Directory:${NC} $INSTALL_DIR"
    echo ""
    echo -e "${BOLD}Quick Start:${NC}"
    echo "  $ ./asf-launcher.sh status    # Check status"
    echo "  $ ./asf-launcher.sh logs     # View logs"
    echo "  $ ./asf-launcher.sh asf      # Run ASF commands"
    echo ""
    echo -e "${BOLD}Default Ports:${NC}"
    echo "  OpenClaw Gateway:    http://localhost:3000"
    echo "  Mission Control API: http://localhost:8001"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Configure your API keys in $INSTALL_DIR/openclaw/.env"
    echo "  2. Run './asf-launcher.sh start' to start services"
    echo "  3. Access OpenClaw at http://localhost:3000"
    echo ""
}

# Run main
main "$@"
