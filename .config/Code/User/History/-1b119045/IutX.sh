#!/usr/bin/env bash

# Check release
if [ ! -f /etc/arch-release ] ; then
    exit 0
fi

# source variables
get_aurhlpr
export -f pkg_installed

# Trigger upgrade
if [ "$1" == "up" ] ; then
    trap 'pkill -RTMIN+20 waybar' EXIT
    command="
    fastfetch
    $0 upgrade
    paru -Syu
    read -n 1 -p 'Press any key to continue...'
    "
    kitty --title systemupdate sh -c "${command}"
fi

# Check for AUR updates
aur=$(  paru -Qu | wc -l)
ofc=$( (while pgrep -x checkupdates > /dev/null ; do sleep 1; done) ; checkupdates | wc -l)


# Calculate total available updates
upd=$(( ofc + aur))

[ "${1}" == upgrade ] && printf "[Official] %-10s\n[AUR]      %-10s\n[Flatpak]  %-10s\n" "$ofc" "$aur" "$fpk" && exit

# Show tooltip
if [ $upd -eq 0 ] ; then
    upd="" #Remove Icon completely
    # upd="󰮯"   #If zero Display Icon only
    echo "{\"text\":\"$upd\", \"tooltip\":\" Packages are up to date\"}"
else
    echo "{\"text\":\"󰮯 $upd\", \"tooltip\":\"󱓽 Official $ofc\n󱓾 AUR $aur$fpk_disp\"}"
fi
