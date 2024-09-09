#!/bin/bash

# List of DNS servers to test
dns_list=(
  "1.1.1.1"    # Cloudflare
  "8.8.8.8"    # Google
  "9.9.9.9"    # Quad9
  "208.67.222.222"  # OpenDNS
  "8.26.56.26" # Comodo DNS
  "1.0.0.1"    # Cloudflare Backup
  "8.8.4.4"    # Google Backup
  "208.67.220.220"  # OpenDNS Backup
  "77.88.8.8"  # Yandex DNS
  "77.88.8.1"  # Yandex DNS Backup
  "4.2.2.1"    # Level3
  "4.2.2.2"    # Level3
  "4.2.2.3"    # Level3
  "4.2.2.4"    # Level3
  "156.154.70.1" # Neustar DNS
  "156.154.71.1" # Neustar DNS Backup
  "74.82.42.42"  # Hurricane Electric
  "185.228.168.9"  # CleanBrowsing Family Filter
  "185.228.169.9"  # CleanBrowsing Adult Filter
  "198.101.242.72" # Alternate DNS
  "78.47.64.161" # DNS.WATCH
  "84.200.69.80"  # DNS.WATCH
  "199.85.126.10" # Norton ConnectSafe
  "199.85.127.10" # Norton ConnectSafe Backup
  "37.235.1.174"  # FreeDNS
  "37.235.1.177"  # FreeDNS Backup
  "45.77.165.194" # DNS.SB
  "66.70.228.164" # Free France DNS
  "176.103.130.130" # AdGuard DNS
  "176.103.130.132" # AdGuard DNS Backup
  "94.140.14.14"   # AdGuard DNS for Family Protection
  "94.140.14.15"   # AdGuard DNS for Family Protection Backup
  "9.9.9.11"       # Quad9 ECS
  "94.140.15.15"   # AdGuard Safe
  "94.140.15.16"   # AdGuard Safe Backup
  "217.31.204.130" # CESNET DNS
  "64.6.64.6"      # Verisign
  "64.6.65.6"      # Verisign Backup
  "185.222.222.222" # Resilient DNS
  "185.222.222.223" # Resilient DNS Backup
  "205.251.198.30"  # AWS Route 53
  "8.20.247.20"     # Comodo Secure DNS
  "185.121.177.177" # SafeSurfer
  "185.121.177.53"  # SafeSurfer Backup
  "203.80.96.10"    # SecureDNS Asia
  "202.46.34.74"    # SecureDNS Oceania
  "202.134.39.20"   # SecureDNS Middle East
  "10.202.10.10"    # Radar
  "10.202.10.11"   # Radar
  "185.51.200.2"   # Shecan
  "178.22.122.100"  # Shecan
)

# Function to test DNS server response time
test_dns() {
    local dns=$1
    # Use dig to test DNS response time and check for errors
    response=$(timeout 2s dig @$dns google.com +stats | grep "Query time:" | awk '{print $4}')

    if [ -z "$response" ]; then
        # If no response, set response to a large number to handle timeouts
        response=9999
    fi


    echo "$dns $response"
}

# Array to store DNS response times
results=()

echo "Testing DNS servers..."

# Test each DNS and store the result
for dns in "${dns_list[@]}"; do
    result=$(test_dns "$dns")
    pingr=$(echo "$result" | sed 's/ /\n/g' | sed '2! d')
    if [ "$pingr" -lt "100" ];then
      echo -e "\033[32m$result\033[0m" | sed 's/ / -> /g'
    else
      echo -e "\033[31m$result\033[0m" | sed 's/ / -> /g'
    fi
    results+=("$result")
done

# Sort DNS results by the response time (numerically)
sorted_results=$(printf "%s\n" "${results[@]}" | sort -nk2)

# Get the fastest DNS server
fastest_dns=$(echo "$sorted_results" | sed '1! d' | sed 's/ /\n/g' | sed '1! d')
fastest_time=$(echo "$sorted_results" | sed '1! d' | sed 's/ /\n/g' | sed '2! d')

second_dns=$(echo "$sorted_results" | sed '2! d' | sed 's/ /\n/g' | sed '1! d')
second_time=$(echo "$sorted_results" | sed '2! d' | sed 's/ /\n/g' | sed '2! d')

echo "Fastest DNS is $(echo -e "\033[32m$fastest_dns\033[0m") with a response time of $(echo -e "\033[32m$fastest_time ms\033[0m")"

echo "Second DNS is $(echo -e "\033[32m$second_dns\033[0m") with a response time of $(echo -e "\033[32m$second_time ms\033[0m")"
echo "Press Enter To Set $(echo -e "\033[32m$fastest_dns\033[0m") and $(echo -e "\033[32m$second_dns\033[0m") dns on your mac..."
read a
# Set the fastest DNS on macOS
#network_service=$(networksetup -listallnetworkservices | head -n 2 | tail -n 1)
network_service="Wi-Fi"
sudo networksetup -setdnsservers "$network_service" "$fastest_dns" "$second_dns"
clear
echo "DNS updated to $fastest_dns $second_dns"
