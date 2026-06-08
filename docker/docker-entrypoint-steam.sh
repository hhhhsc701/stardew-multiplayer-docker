#!/bin/bash
export HOME=/config
shopt -s nullglob
MODS_PATH="${GAME_PATH}/Mods"

if [ -d "$MODS_PATH" ]; then
  chmod -R a+rwX "$MODS_PATH" || echo "Unable to update permissions for mounted Mods directory: $MODS_PATH"
fi

for modPath in "$MODS_PATH"/*/
do
  if [ -f "${modPath}/config.json.template" ]; then
    echo "Configuring ${modPath}config.json"

    # Seed the config.json only if one isn't manually mounted in (or is empty)
    if [ "$(cat "${modPath}config.json" 2> /dev/null)" == "" ]; then
      envsubst < "${modPath}config.json.template" > "${modPath}config.json"
    fi
  fi
done

# Run extra steps for certain mods
/opt/configure-remotecontrol-mod.sh

/opt/tail-smapi-log.sh &

# Ready to start!

export XAUTHORITY=~/.Xauthority
sed -i 's/env TERM=xterm $LAUNCHER "$@"/env SHELL=\/bin\/bash TERM=xterm xterm  -e "\/bin\/bash -c $LAUNCHER \"$@\""/' $GAME_PATH/Stardew\ Valley

bash -c "$GAME_PATH/start.sh"

sleep 233333333333333
