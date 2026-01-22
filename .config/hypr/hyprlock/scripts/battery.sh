#!/usr/bin/env bash

############ Variables ############
enable_battery=false
battery_charging=false
capacity=0
CONFIG_FILE="$HOME/.config/hypr/hyprlock.conf"

####### Detect battery ########
for battery in /sys/class/power_supply/*BAT*; do
  if [[ -f "$battery/uevent" ]]; then
    enable_battery=true
    capacity=$(<"$battery/capacity")
    status=$(<"$battery/status")
    [[ "$status" == "Charging" ]] && battery_charging=true
    break
  fi
done

############ Helpers ############
replace_position_digits() {
  local new_pos="$1"

  # Replace ANY of the known digit-based positions with the correct one
  sed -i \
    -e 's/position = -91, 27.5/position = '"$new_pos"'/g' \
    -e 's/position = -96.6, 27.5/position = '"$new_pos"'/g' \
    -e 's/position = -98, 27.5/position = '"$new_pos"'/g' \
    -e 's/position = -100, 27.5/position = '"$new_pos"'/g' \
    "$CONFIG_FILE"
}

############ Logic ############
if [[ "$enable_battery" != true || ! -f "$CONFIG_FILE" ]]; then
  echo "No battery found"
  exit 0
fi

######## Charging / Not charging ########
if [[ "$battery_charging" == true ]]; then
  echo "$capacity% +"

  sed -i \
    -e 's/position = -158, 31/position = -166, 31/g' \
    -e 's/size = 80, 50/size = 89, 50/g' \
    "$CONFIG_FILE"
else
  echo "$capacity%"

  sed -i \
    -e 's/position = -166, 31/position = -158, 31/g' \
    -e 's/size = 89, 50/size = 80, 50/g' \
    "$CONFIG_FILE"
fi

######## Battery digits positioning ########
digits=${#capacity}

if [[ "$battery_charging" == false ]]; then
    if [[ "$digits" -eq 3 ]]; then
        replace_position_digits "-91, 27.5"
    elif [[ "$digits" -eq 2 ]]; then
        replace_position_digits "-96.6, 27.5"
    else
        replace_position_digits "-100, 27.5"
    fi
else
    if [[ "$digits" -eq 1 ]]; then
        replace_position_digits "-98, 27.5"
    else
        replace_position_digits "-91, 27.5"
    fi

fi