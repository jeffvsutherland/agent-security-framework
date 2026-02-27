# Information Needed from Jeff's Umbrel Node

## Quick Reference for Jeff

### 1. Basic Network Info
- **Umbrel IP Address:** `[PROVIDE_IP_ADDRESS]`
- **Network Type:** mainnet (confirm this is correct)

### 2. Bitcoin RPC Credentials
On your Umbrel dashboard:
- Go to **Settings** → **Advanced** → **Bitcoin Core RPC**
- Copy the **username** and **password**

**Format needed:**
```
BTCPAY_BITCOIN_RPC_USER=umbrel_rpc_username
BTCPAY_BITCOIN_RPC_PASS=umbrel_rpc_password
```

### 3. Lightning Node Credentials
From your Umbrel terminal/SSH:

```bash
# Get the TLS certificate
cat ~/umbrel/lnd/tls.cert

# Get the admin macaroon (base64 encoded)
base64 ~/umbrel/lnd/data/chain/bitcoin/mainnet/admin.macaroon
```

### 4. Network Connectivity Test
From the server Carlos will use, test connectivity to your Umbrel:

```bash
# Test Bitcoin RPC port
nc -zv [UMBREL_IP] 8332

# Test Lightning port  
nc -zv [UMBREL_IP] 10009
```

### 5. Domain Name Decision
What domain should BTCPay use? Options:
- `payments.frequencyfoundation.com`
- `btc.frequencyfoundation.com`
- `checkout.frequencyfoundation.com`

## Quick Setup Commands for Jeff

If you have SSH access to your Umbrel:

```bash
# Show Bitcoin RPC info
cat ~/umbrel/bitcoin/bitcoin.conf | grep rpc

# Show Lightning node info
~/umbrel/scripts/debug

# Check if ports are accessible
sudo netstat -tlnp | grep -E ':8332|:10009'
```