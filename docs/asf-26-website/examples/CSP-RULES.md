# Content Security Policy for ASF Website

## Basic CSP Header

```
Content-Security-Policy: 
    default-src 'self';
    script-src 'self';
    style-src 'self' 'unsafe-inline';
    img-src 'self' data: https:;
    frame-ancestors 'none';
```

## Nginx Configuration

```nginx
add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; frame-ancestors 'none';" always;
```

## Testing CSP

```bash
curl -I https://scrumai.org | grep -i content-security
```
