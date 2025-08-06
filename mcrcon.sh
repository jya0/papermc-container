#!/bin/bash
# RCON wrapper using netcat and manual protocol implementation
# Usage: ./mcrcon.sh "command"

if [ $# -eq 0 ]; then
    echo "Usage: $0 \"command\""
    echo "Example: $0 \"list\""
    echo "Example: $0 \"op username\""
    exit 1
fi

COMMAND="$1"
CONTAINER="papermc-deploy-deploy-mc-1.21.8-1"
RCON_HOST="localhost"
RCON_PORT="25575"
RCON_PASSWORD="1"

# Create RCON client using netcat and printf
docker exec -i $CONTAINER sh -c "
# Function to create RCON packet
create_packet() {
    local length=\$1
    local request_id=\$2
    local packet_type=\$3
    local payload=\$4
    
    # Create binary packet (simplified)
    printf \"\$(printf '\\\\x%02x\\\\x%02x\\\\x%02x\\\\x%02x' \$((length & 0xFF)) \$(((length >> 8) & 0xFF)) \$(((length >> 16) & 0xFF)) \$(((length >> 24) & 0xFF)))\"
    printf \"\$(printf '\\\\x%02x\\\\x%02x\\\\x%02x\\\\x%02x' \$((request_id & 0xFF)) \$(((request_id >> 8) & 0xFF)) \$(((request_id >> 16) & 0xFF)) \$(((request_id >> 24) & 0xFF)))\"
    printf \"\$(printf '\\\\x%02x\\\\x%02x\\\\x%02x\\\\x%02x' \$((packet_type & 0xFF)) \$(((packet_type >> 8) & 0xFF)) \$(((packet_type >> 16) & 0xFF)) \$(((packet_type >> 24) & 0xFF)))\"
    printf \"\$payload\"
    printf '\\\\x00\\\\x00'
}

# Try to connect and send command
if command -v nc >/dev/null 2>&1; then
    echo 'Attempting RCON connection...'
    
    # Create temporary files for RCON communication
    tmp_auth=\$(mktemp)
    tmp_cmd=\$(mktemp)
    
    # Create auth packet (type 3)
    auth_length=\$((10 + \${#RCON_PASSWORD}))
    create_packet \$auth_length 1 3 \"$RCON_PASSWORD\" > \$tmp_auth
    
    # Create command packet (type 2)  
    cmd_length=\$((10 + \${#COMMAND}))
    create_packet \$cmd_length 2 2 \"$COMMAND\" > \$tmp_cmd
    
    # Send packets via netcat
    (
        cat \$tmp_auth
        sleep 0.1
        cat \$tmp_cmd
        sleep 0.1
    ) | nc $RCON_HOST $RCON_PORT 2>/dev/null | xxd -p | tr -d '\\n' | sed 's/../\\\\x&/g' | xargs -0 printf | strings
    
    # Cleanup
    rm -f \$tmp_auth \$tmp_cmd
    
else
    echo 'Netcat not available. Installing...'
    apk add --no-cache netcat-openbsd 2>/dev/null || apt-get update && apt-get install -y netcat 2>/dev/null || echo 'Failed to install netcat'
fi
"
