#!/usr/bin/env bash
#
# asf-quick-install.sh - One-Command ASF + OpenClaw + Mission Control Installer
# Usage: curl -sSL https://raw.githubusercontent.com/jeffvsutherland/agent-security-framework/main/asf-quick-install.sh | bash
#
set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================
ASF_VERSION="2026.03"

# Default ports (can be overridden)
OC_GATEWAY_PORT="${OC_GATEWAY_PORT:-18789}"
OC_FRONTEND_PORT="${OC_FRONTEND_PORT:-18790}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
        log_error "Docker is not running. Please start Docker Desktop (macOS) or dockerd (Linux) and try again."
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
    mkdir -p "$INSTALL_DIR"/{openclaw,mission-control,asf-config,data,config}
    cd "$INSTALL_DIR"
    log_success "Installation directory: $INSTALL_DIR"
}

# Clone OpenClaw
install_openclaw() {
    log_info "Installing OpenClaw..."
    
    if [[ -d "$INSTALL_DIR/openclaw/.git" ]]; then
        log_warn "OpenClaw already exists, skipping clone"
    else
        git clone --depth 1 https://github.com/openclaw/openclaw.git "$INSTALL_DIR/openclaw"
    fi
    
    # Copy environment template
    if [[ -f "$INSTALL_DIR/openclaw/.env.example" ]]; then
        cp "$INSTALL_DIR/openclaw/.env.example" "$INSTALL_DIR/openclaw/.env" 2>/dev/null
    fi
    
    log_success "OpenClaw installed"
}

# Generate openclaw.json configuration
generate_openclaw_config() {
    log_info "Generating OpenClaw configuration..."
    
    # Check if already exists
    if [[ -f "$INSTALL_DIR/config/openclaw.json" ]]; then
        log_warn "openclaw.json already exists, skipping"
        return 0
    fi
    
    # Create config directory
    mkdir -p "$INSTALL_DIR/config"
    
    # Generate openclaw.json with default gateway config
    cat > "$INSTALL_DIR/config/openclaw.json" <<EOF
{
  "gateway": {
    "bind": "0.0.0.0",
    "port": ${OC_GATEWAY_PORT},
    "remoteUrl": "",
    "corsOrigins": ["*"]
  },
  "controlUi": {
    "enabled": true,
    "allowedOrigins": ["*"]
  },
  "plugins": {
    "entries": []
  },
  "accounts": {}
}
EOF
    log_success "openclaw.json generated"
}

# Setup auth-profiles.json with API key guidance
setup_auth_profiles() {
    log_info "Setting up authentication profiles..."
    
    local config_dir="$INSTALL_DIR/openclaw/config"
    mkdir -p "$config_dir"
    
    # Check if already exists
    if [[ -f "$config_dir/auth-profiles.json" ]]; then
        log_warn "auth-profiles.json already exists, skipping"
        return 0
    fi
    
    # Create a template auth-profiles.json
    cat > "$config_dir/auth-profiles.json" <<'EOF'
{
  "profiles": []
}
EOF
    log_success "auth-profiles.json template created"
    
    # Create API key setup instructions
    cat > "$INSTALL_DIR/OPENCLAW-SETUP.md" <<'EOF'
# OpenClaw Setup Instructions

## 1. Add Your API Key

Edit the auth-profiles.json file to add your API provider:

```bash
nano ~/asf-install/openclaw/config/auth-profiles.json
```

Example for OpenAI:
```json
{
  "profiles": [
    {
      "id": "default",
      "provider": "openai",
      "apiKey": "sk-xxxxx",
      "models": ["gpt-4", "gpt-4o"]
    }
  ]
}
```

Example for Anthropic:
```json
{
  "profiles": [
    {
      "id": "default", 
      "provider": "anthropic",
      "apiKey": "sk-ant-xxxxx",
      "models": ["claude-sonnet-4-20250514"]
    }
  ]
}
```

## 2. Start Services

```bash
cd ~/asf-install/openclaw
./docker-setup.sh
```

## 3. Access OpenClaw

- Gateway: http://localhost:18789
- Control UI: http://localhost:18790

## 4. Device Pairing (for remote access)

When you first access the Control UI, you'll need to pair your device:
1. Click "Pair Device" in the UI
2. Follow the on-screen instructions to generate a pairing code
3. Enter the code to enable remote access

## Troubleshooting

- Check logs: `docker compose logs -f`
- Restart: `docker compose restart`
- Full reset: `docker compose down -v && ./docker-setup.sh`
EOF
    log_success "Setup instructions created"
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
        if ! git pull origin main 2>/dev/null; then
            log_warn "Could not pull latest ASF, using existing version"
        fi
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
        if ! cp -r "$INSTALL_DIR/agent-security-framework/"* "$INSTALL_DIR/openclaw/security/" 2>/dev/null; then
            log_warn "Could not copy ASF security configs"
        fi
    fi
    
    log_success "ASF security configured"
}

# Start services using docker-setup.sh
start_services() {
    log_info "Starting OpenClaw services..."
    
    if [[ ! -d "$INSTALL_DIR/openclaw" ]]; then
        log_error "OpenClaw not installed. Run full installation first."
        return 1
    fi
    
    cd "$INSTALL_DIR/openclaw"
    
    # Check if docker-setup.sh exists
    if [[ -f "./docker-setup.sh" ]]; then
        log_info "Running docker-setup.sh (this may take a few minutes)..."
        chmod +x ./docker-setup.sh
        ./docker-setup.sh
    else
        log_warn "docker-setup.sh not found, trying docker compose..."
        # Fallback to docker compose
        docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null || {
            log_error "Failed to start services. Try manually:"
            echo "  cd $INSTALL_DIR/openclaw"
            echo "  docker compose up -d"
            return 1
        }
    fi
    
    log_success "Services started"
}

# Create launcher script
create_launcher() {
    log_info "Creating launcher script..."
    
    cat > "$INSTALL_DIR/asf-launcher.sh" <<EOF
#!/usr/bin/env bash
#
# ASF Launcher - Start your ASF environment
#
ASF_ROOT="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
OC_DIR="\$ASF_ROOT/openclaw"

show_status() {
    echo "ASF Environment Status"
    echo "====================="
    echo ""
    echo "Installation: \$ASF_ROOT"
    echo ""
    
    # Check Docker containers
    echo "Running services:"
    docker ps --filter "name=openclaw" --format "  {{\.Names}}: {{\.Status}}" 2>/dev/null || echo "  (Docker not available)"
    echo ""
    
    echo "Ports:"
    echo "  OpenClaw Gateway:    http://localhost:${OC_GATEWAY_PORT}"
    echo "  Control UI:         http://localhost:${OC_FRONTEND_PORT}"
    echo ""
}

case "\${1:-status}" in
    status)
        show_status
        ;;
    start)
        cd "\$OC_DIR"
        if [[ -f "./docker-setup.sh" ]]; then
            ./docker-setup.sh
        else
            docker compose up -d
        fi
        echo "Services started"
        show_status
        ;;
    stop)
        cd "\$OC_DIR" && docker compose down 2>/dev/null
        echo "Services stopped"
        ;;
    restart)
        cd "\$OC_DIR" && docker compose restart 2>/dev/null
        echo "Services restarted"
        ;;
    logs)
        cd "\$OC_DIR" && docker compose logs -f --tail=50 2>/dev/null || echo "No logs available"
        ;;
    shell)
        docker exec -it openclaw-gateway-1 bash 2>/dev/null || docker exec -it openclaw_gateway_1 bash 2>/dev/null || echo "Shell not available"
        ;;
    asf)
        shift
        "\$ASF_ROOT/agent-security-framework/asf-live-demo.sh" "\$@"
        ;;
    help|--help|-h)
        echo "ASF Launcher Commands:"
        echo "  status     - Show environment status"
        echo "  start      - Start services (run docker-setup.sh)"
        echo "  stop       - Stop services"
        echo "  restart    - Restart services"
        echo "  logs       - View container logs"
        echo "  shell      - Open shell in gateway container"
        echo "  asf        - Run ASF commands"
        echo "  help       - Show this help"
        ;;
    *)
        exec "\$0" status
        ;;
esac
EOF
    chmod +x "$INSTALL_DIR/asf-launcher.sh"
    
    log_success "Launcher created"
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    echo -e "\${BOLD}\${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║   ASF + OpenClaw + Mission Control - Quick Installer        ║"
    echo "║   Version: $ASF_VERSION                                        ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "\${NC}"
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
    
    # Step 4: Generate configurations
    generate_openclaw_config
    setup_auth_profiles
    
    # Step 5: Create launcher
    create_launcher
    
    # Step 6: Start services
    start_services
    
    # Step 7: Summary
    echo ""
    echo -e "\${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
    echo -e "\${GREEN}✅ INSTALLATION COMPLETE!\${NC}"
    echo -e "\${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
    echo ""
    echo -e "\${BOLD}Installation Directory:\${NC} $INSTALL_DIR"
    echo ""
    echo -e "\${BOLD}Quick Start:\${NC}"
    echo "  $ ./asf-launcher.sh status    # Check status"
    echo "  $ ./asf-launcher.sh logs     # View logs"
    echo "  $ ./asf-launcher.sh asf      # Run ASF commands"
    echo ""
    echo -e "\${BOLD}Default Ports:\${NC}"
    echo "  OpenClaw Gateway:    http://localhost:${OC_GATEWAY_PORT}"
    echo "  Control UI:         http://localhost:${OC_FRONTEND_PORT}"
    echo ""
    echo -e "\${YELLOW}IMPORTANT NEXT STEPS:\${NC}"
    echo "  1. Add your API key to: $INSTALL_DIR/openclaw/config/auth-profiles.json"
    echo "     See: $INSTALL_DIR/OPENCLAW-SETUP.md for examples"
    echo "  2. For remote access: Use the Control UI to pair your device"
    echo "  3. Check logs if issues: $ ./asf-launcher.sh logs"
    echo ""
}

# Run main
main "$@"
