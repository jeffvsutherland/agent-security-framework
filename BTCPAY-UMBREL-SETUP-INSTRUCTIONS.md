# BTCPay Server Setup with Umbrel Backend - Complete Instructions

**Project:** Frequency Foundation Payment Infrastructure  
**Developer:** Carlos (Web Team)  
**Backend:** Umbrel Bitcoin Node (Jeff's Lab)  
**Goal:** Replace broken Coinsnap payment system with self-hosted solution

## Overview

BTCPay Server is a self-hosted, open-source cryptocurrency payment processor. We're connecting it to Jeff's Umbrel node to handle Bitcoin and Lightning Network payments for Frequency Foundation customers.

**Benefits:**
- No third-party payment processor fees
- Full custody of Bitcoin payments  
- Lightning Network support for instant payments
- Integrates with existing web infrastructure
- No KYC requirements for customers

## Prerequisites

### System Requirements
- Ubuntu 20.04+ or Debian 11+ server (recommended)
- 4GB RAM minimum (8GB recommended)
- 50GB free disk space
- Docker and Docker Compose installed
- SSL certificate capability (Let's Encrypt)

### Network Requirements  
- Server must be able to reach Umbrel node IP: `[IP_ADDRESS_TO_BE_PROVIDED]`
- Ports needed:
  - 443 (HTTPS) - public access
  - 80 (HTTP) - Let's Encrypt validation
  - Internal connectivity to Umbrel on ports 8332, 10009

### Information Needed from Jeff
- **Umbrel Node IP:** `[WAITING_FOR_IP]`
- **Bitcoin RPC credentials** (username/password)
- **Lightning Node credentials** (macaroon files or connection string)
- **Network details** (mainnet vs testnet)

## Installation Steps

### Step 1: Server Preparation

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y git curl wget

# Install Docker (if not already installed)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout and login to refresh group membership
```

### Step 2: Download BTCPay Server

```bash
# Clone BTCPay Server repository
cd /opt
sudo git clone https://github.com/btcpayserver/btcpayserver-docker
sudo chown -R $USER:$USER btcpayserver-docker
cd btcpayserver-docker

# Set executable permissions
chmod +x btcpay-setup.sh
```

### Step 3: Configuration Setup

Create environment configuration:

```bash
# Create .env file with basic settings
cat > .env << 'EOF'
# Basic BTCPay Configuration
BTCPAY_HOST=[YOUR_DOMAIN]  # e.g., payments.frequencyfoundation.com
NBITCOIN_NETWORK=mainnet
BTCPAY_ENABLE_SSH=false
REVERSEPROXY_HTTP_PORT=80
REVERSEPROXY_HTTPS_PORT=443
NOREVERSEPROXY_HTTP_PORT=23000

# External Bitcoin Node (Umbrel)
BTCPAY_BITCOIN_EXTERNAL=true
BTCPAY_BITCOIN_RPC_HOST=[UMBREL_IP]
BTCPAY_BITCOIN_RPC_PORT=8332
BTCPAY_BITCOIN_RPC_USER=[RPC_USERNAME]
BTCPAY_BITCOIN_RPC_PASS=[RPC_PASSWORD]

# Lightning Network (using Umbrel's LND)
BTCPAY_LIGHTNING_EXTERNAL=true
BTCPAY_LIGHTNING_LND_HOST=[UMBREL_IP]
BTCPAY_LIGHTNING_LND_PORT=10009
BTCPAY_LIGHTNING_LND_TLSCERT_PATH=/path/to/tls.cert
BTCPAY_LIGHTNING_LND_MACAROON_PATH=/path/to/admin.macaroon

# SSL Configuration (Let's Encrypt)
LETSENCRYPT_EMAIL=admin@frequencyfoundation.com
EOF
```

### Step 4: Umbrel Connection Setup

**WAITING FOR JEFF TO PROVIDE:**

1. **Umbrel IP Address and RPC Credentials:**
   ```bash
   # Jeff needs to provide:
   # - Umbrel local IP address
   # - Bitcoin RPC username/password from Umbrel
   # - Lightning Node connection details
   ```

2. **Get Bitcoin RPC credentials from Umbrel:**
   ```bash
   # Jeff: On Umbrel, navigate to:
   # Settings > Advanced > Bitcoin Core RPC
   # Copy username and password
   ```

3. **Get Lightning credentials from Umbrel:**
   ```bash
   # Jeff: From Umbrel terminal, copy these files:
   # /umbrel/lightning/data/tls.cert
   # /umbrel/lightning/data/data/chain/bitcoin/mainnet/admin.macaroon
   ```

### Step 5: Deploy BTCPay Server

```bash
# Run the setup script
./btcpay-setup.sh -i

# Or manual Docker Compose deployment:
export BTCPAY_HOST=[YOUR_DOMAIN]
export NBITCOIN_NETWORK=mainnet

# Start services
docker-compose up -d
```

### Step 6: Initial Configuration

1. **Access BTCPay Server:**
   - Navigate to `https://[YOUR_DOMAIN]`
   - Complete the initial admin setup

2. **Create Frequency Foundation Store:**
   - Store Name: "Frequency Foundation"
   - Default Currency: USD
   - Enable Bitcoin and Lightning

3. **Configure Payment Methods:**
   ```json
   {
     "Bitcoin": {
       "enabled": true,
       "confirmations": 1
     },
     "Lightning": {
       "enabled": true,
       "network": "mainnet"
     }
   }
   ```

### Step 7: Testing & Verification

```bash
# Test Bitcoin RPC connection
curl -u [RPC_USER]:[RPC_PASS] \
     -H "Content-Type: application/json" \
     -d '{"jsonrpc":"1.0","id":"test","method":"getblockchaininfo","params":[]}' \
     http://[UMBREL_IP]:8332

# Test Lightning connection
# Verify in BTCPay admin panel that Lightning node shows as connected
```

## Integration Steps

### Website Integration

1. **Invoice API Integration:**
   ```javascript
   // Example invoice creation
   const invoice = await fetch('/api/v1/stores/[STORE_ID]/invoices', {
     method: 'POST',
     headers: {
       'Authorization': 'token [API_KEY]',
       'Content-Type': 'application/json'
     },
     body: JSON.stringify({
       amount: 100,
       currency: 'USD',
       checkout: {
         redirectURL: 'https://frequencyfoundation.com/payment-success'
       }
     })
   });
   ```

2. **Webhook Configuration:**
   - Set webhook URL: `https://frequencyfoundation.com/webhooks/btcpay`
   - Events: `InvoiceSettled`, `InvoiceExpired`

## Security Checklist

- [ ] SSL certificate properly configured
- [ ] Firewall rules limit access to necessary ports only
- [ ] BTCPay admin panel uses strong password/2FA
- [ ] Bitcoin/Lightning credentials stored securely
- [ ] Regular backups of BTCPay database
- [ ] Webhook endpoints use authentication tokens

## Troubleshooting

### Common Issues:

1. **Connection to Umbrel fails:**
   - Verify IP address and port accessibility
   - Check firewall rules on both servers
   - Confirm RPC credentials are correct

2. **Lightning payments not working:**
   - Verify Lightning node is synced on Umbrel
   - Check macaroon and TLS certificate paths
   - Ensure Lightning node has inbound liquidity

3. **SSL certificate issues:**
   - Verify domain DNS points to server
   - Check Let's Encrypt rate limits
   - Ensure ports 80/443 are accessible

## Next Steps for Carlos

1. **Prepare the server** (Steps 1-2)
2. **Wait for Umbrel credentials** from Jeff
3. **Configure environment** with provided details
4. **Deploy and test** the installation
5. **Integrate with Frequency Foundation website**
6. **Set up monitoring and backups**

## Information Needed from Jeff

**Please provide:**
1. Umbrel node IP address
2. Bitcoin RPC username and password
3. Lightning node connection details (TLS cert and macaroon)
4. Preferred domain name for BTCPay server
5. Network confirmation (mainnet vs testnet)

Once Jeff provides these details, I'll update this document with the specific configuration values.

---

**Contact:** Agent Saturday for technical questions  
**Timeline:** Deploy within 48 hours of receiving Umbrel credentials  
**Priority:** High (replaces broken Coinsnap payment system)