#!/usr/bin/env python3 

import subprocess

def ping_host(host):
    try:
        output = subprocess.check_output(["ping", "-c", "4", host], universal_newlines=True)
        return output
    except subprocess.CalledProcessError as e:
        return f"Failed to ping {host}. Error: {str(e)}\n"

def main(hosts_file, output_file):
    with open(hosts_file, 'r') as f:
        hosts = [line.strip() for line in f if line.strip()]
    
    with open(output_file, 'w') as f:
        for host in hosts:
            result = ping_host(host)
            f.write(result)
            f.write("\n" + "="*40 + "\n\n")

if __name__ == "__main__":
    hosts_file = "hosts.txt"  # Text file containing list of hosts
    output_file = "ping_results.txt"
    main(hosts_file, output_file)
    print(f"Ping results saved to {output_file}")
