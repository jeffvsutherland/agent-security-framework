"""
Credential Theft Blocking Module
Blocks attempts to access environment variables containing secrets
"""
import os
import sys

# Blocked environment variable patterns
BLOCKED_PATTERNS = [
    'KEY', 'SECRET', 'TOKEN', 'PASSWORD', 'CREDENTIAL',
    'API_KEY', 'AUTH', 'PRIVATE', 'ACCESS_TOKEN',
    'GITHUB_TOKEN', 'OPENAI_API_KEY', 'ANTHROPIC_API_KEY'
]

class SecureEnviron:
    """Proxy that blocks access to sensitive env vars"""
    def __getitem__(self, key):
        key_upper = key.upper()
        for pattern in BLOCKED_PATTERNS:
            if pattern in key_upper:
                raise PermissionError(f"Blocked: Attempt to access credential {key}")
        return os.environ[key]
    
    def get(self, key, default=None):
        try:
            return self[key]
        except (KeyError, PermissionError):
            return default

# Patch os.environ
os.environ = SecureEnviron()

# Block common credential theft vectors
BLOCKED_PATHS = [
    '/root/.aws',
    '/root/.ssh',
    '/root/.config',
    '/home/*/.aws',
    '/home/*/.ssh', 
    '/home/*/.config',
    '/etc/passwd',
    '/etc/shadow',
    '/etc/security/opasswd'
]

def block_file_access(path):
    """Block access to sensitive files"""
    import builtins
    original_open = builtins.open
    
    def restricted_open(path, *args, **kwargs):
        for blocked in BLOCKED_PATHS:
            if path.startswith(blocked.replace('*', '')):
                raise PermissionError(f"Blocked: Access to {path} is not allowed")
        return original_open(path, *args, **kwargs)
    
    builtins.open = restricted_open

# Apply restrictions
try:
    block_file_access(None)
except:
    pass

print("[ASF Security] Credential theft protection enabled")
