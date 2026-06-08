#!/bin/bash
export HOME=/config
shopt -s nullglob
MODS_PATH="/data/Stardew/game/Mods"

if [ -d "$MODS_PATH" ]; then
  chmod -R a+rwX "$MODS_PATH" || echo "Unable to update permissions for mounted Mods directory: $MODS_PATH"
fi

for modPath in "$MODS_PATH"/*/
do
  mod=$(basename "$modPath")

  # Normalize mod name ot uppercase and only characters, eg. "Always On Server" => ENABLE_ALWAYSONSERVER_MOD
  var="ENABLE_$(echo "${mod^^}" | tr -cd '[A-Z]')_MOD"

  # Mods are bind-mounted from the host. Do not remove disabled mods here,
  # otherwise the host directory would be modified.
  if [ "${!var}" != "true" ]; then
    echo "Leaving mounted mod ${modPath} unchanged (${var}=${!var}); remove it from the local Mods directory to disable it"
    continue
  fi

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
sed -i 's/env TERM=xterm $LAUNCHER "$@"/env SHELL=\/bin\/bash TERM=xterm xterm  -e "\/bin\/bash -c $LAUNCHER \"$@\""/' /data/Stardew/game/Stardew\ Valley

bash -c "/data/Stardew/start.sh"

sleep 233333333333333
