# ASF-36: nginx configuration for asf.yourdomain.com
# Add to /etc/nginx/sites-available/asf.conf

server {
    listen 443 ssl http2;
    server_name asf.yourdomain.com;

    # SSL Configuration (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/asf.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/asf.yourdomain.com/privkey.pem;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;

    # Modern TLS configuration
    ssl_protocols TLSv1.3 TLSv1.2;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # HSTS
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; connect-src 'self' https://api.moltbook.com; frame-ancestors 'none';" always;

    # Rate Limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=login:10m rate=3r/m;
    limit_req_zone $binary_remote_addr zone=general:10m rate=5r/s;

    # Bot Protection
    geo $blocked_ua {
        default 0;
        ~*curl 1;
        ~*wget 1;
        ~*scrapy 1;
        ~*bot 1;
    }

    # Access Log
    access_log /var/log/nginx/asf-access.log;
    error_log /var/log/nginx/asf-error.log;

    # Main Application
    location / {
        limit_req zone=general burst=10 nodelay;
        
        # Proxy to backend
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # API Endpoints
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        
        # CORS for authorized origins
        add_header 'Access-Control-Allow-Origin' 'https://app.yourdomain.com' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type' always;
    }

    # Admin Area
    location /admin/ {
        limit_req zone=login burst=5 nodelay;
        
        # Basic auth
        auth_basic "ASF Admin";
        auth_basic_user_file /etc/nginx/.htpasswd;
        
        proxy_pass http://localhost:3000;
    }

    # Health Check (no rate limit)
    location /health {
        access_log off;
        proxy_pass http://localhost:3000/health;
    }

    # Block suspicious requests
    location ~* \.(php|pl|cgi|py|sh|asp)$ {
        deny all;
    }

    location ~ /\. {
        deny all;
    }
}

# HTTP to HTTPS redirect
server {
    listen 80;
    server_name asf.yourdomain.com;
    return 301 https://$server_name$request_uri;
}
