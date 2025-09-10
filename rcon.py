#!/usr/bin/env python3
import socket
import struct
import sys

def rcon_command(host, port, password, command):
    # Create socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((host, port))
    
    # Send auth packet
    auth_packet = struct.pack('<iii', 10, 0, 3) + password.encode('utf-8') + b'\x00\x00'
    sock.send(auth_packet)
    
    # Receive auth response
    response = sock.recv(1024)
    
    # Send command packet
    cmd_packet = struct.pack('<iii', len(command) + 10, 1, 2) + command.encode('utf-8') + b'\x00\x00'
    sock.send(cmd_packet)
    
    # Receive command response
    response = sock.recv(4096)
    
    # Parse response
    if len(response) >= 12:
        response_data = response[12:-2].decode('utf-8')
        print(response_data)
    
    sock.close()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 rcon.py 'command'")
        print("Example: python3 rcon.py 'list'")
        sys.exit(1)
    
    command = sys.argv[1]
    rcon_command('localhost', 25575, '1', command)
