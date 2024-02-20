#!/bin/sh

config_file() {
  cat > /hs5t.yml << EOF
tunnel:
  name: 'tun0'
  mtu: 9000
  ipv4: '172.17.0.3'
socks5:
  port: 10808
  address: '172.17.0.2'
  udp: 'udp'
EOF
}

config_route() {
ip addr add 198.18.0.1/15 dev tun0
ip link set dev tun0 up
ip route del default
ip route add default via 198.18.0.1 dev tun0 metric 1
ip route add default via 172.17.0.1 dev eth0 metric 10
}

run() {
  config_file
  hev-socks5-tunnel /hs5t.yml &
  PID=$!
  config_route
  wait ${PID}
}

run || exit 1
