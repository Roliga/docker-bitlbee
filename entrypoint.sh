#!/bin/sh

# Kill the current process group on relevant signals, unbinding the TERM signal to prevent recursion
trap "trap - TERM && kill 0" INT EXIT TERM

if [ "$(id -u bitlbee)" -ne "$UID" ] || [ "$(id -g bitlbee)" -ne "$GID" ]; then
	deluser bitlbee
	addgroup -g "$GID" -S bitlbee
	adduser -u "$UID" -D -S -h /var/lib/bitlbee -s /bin/sh -G bitlbee bitlbee

	chown bitlbee:bitlbee /var/lib/bitlbee
fi

# Start services in the background, and kill this process group if one of them exits
{ su -c '/usr/sbin/bitlbee -F -n' bitlbee; kill 0; } &

# Wait for all processes to exit, allowing traps to be handled
wait
