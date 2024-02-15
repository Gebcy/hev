#!/bin/sh

TUN="${TUN:-tun0}"
MTU="${MTU:-8500}"
IPV4="${IPV4:-198.18.0.1}"
SOCKS5_ADDR="${SOCKS5_ADDR:-192.168.8.2}"
SOCKS5_PORT="${SOCKS5_PORT:-10808}"
SOCKS5_UDP_MODE="${SOCKS5_UDP_MODE:-udp}"

TABLE="${TABLE:-20}"
MARK="${MARK:-438}"

config_file() {
  cat > /hs5t.yml << EOF
tunnel:
  name: '${TUN}'
  mtu: ${MTU}
  ipv4: '${IPV4}'
  ipv6: '${IPV6}'
socks5:
  port: ${SOCKS5_PORT}
  address: '${SOCKS5_ADDR}'
  udp: '${SOCKS5_UDP_MODE}'
  mark: ${MARK}
EOF

  if [ -n "${SOCKS5_USERNAME}" ]; then
      echo "  username: '${SOCKS5_USERNAME}'" >> /hs5t.yml
  fi

  if [ -n "${SOCKS5_PASSWORD}" ]; then
      echo "  password: '${SOCKS5_PASSWORD}'" >> /hs5t.yml
  fi
}

config_route() {
  ip route add default dev ${TUN} table ${TABLE}

  for addr in $(echo ${IPV4_INCLUDED_ROUTES} | tr ',' '\n'); do
    ip rule add to ${addr} table ${TABLE}
  done

  for addr in $(echo ${IPV4_EXCLUDED_ROUTES} | tr ',' '\n'); do
    ip rule add to ${addr} table main
  done

  ip rule add fwmark 0x${MARK} table main pref 1
}

run() {
  config_file
  hev-socks5-tunnel /hs5t.yml &
  PID=$!
  config_route
  wait ${PID}
}

run || exit 1
