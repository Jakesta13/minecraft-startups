#!/bin/bash
## Used https://www.shellcheck.net/ to try and learn some better pratices in my code ... hopefully I know what im doing.
# Create a config file named start.conf
# and Add the following variables seperated by new-lines:
# paperUpdate, minecraftVersion, jar, Xmx, Xms, arguments, eula, levelSeed, world, distance, port, queryPort, whitelist, maxPlayers, proxy, playerTrackingRange
### ### Settings ### ###
## Paper and Jar settings ##
# Allow auto updates of paper?
paperUpdate="true"

# Paper Minecraft Version
minecraftVersion="1.16.5"

# Server Jar Filename
jar="paperclip.jar"

# Memory arguments, in MB - Required
Xmx="1024"
Xms="1024"

# Startup Arguments - Optional
arguments="$*"

## EULA ##
# EULA acceptance? - Required
eula="false"
# https://www.minecraft.net/en-us/eula

## Server.properties Setup ##
# Level-seed
levelSeed=""

# Level-name
world="world"

# View-Distance
distance="10"

# Server Port
port="25565"

# Query Port
queryPort="${port}"

# Set up Rcon manually

# White-list
whitelist="false"

# max-players
maxPlayers="20"

# prevent proxy connections?
proxy="true"

## spigot.yml setup ##
# Player entity tracking range
playerTrackingRange="28"

## ## Config load ## ##
# Check if conf exits, if not then use above settings.
if [ -f "start.conf" ]; then
	source "start.conf"
fi

### ### ### ###
## ## Functions ## ##
# Removes all double-quotes from any input
fixquotes () {
sed -e 's/"//g' -e '/<nil>/d'
}
# Set the counter if it doesnt exist
if [ -z "${counter}" ]; then
    counter=0
fi
## ## ## ##
while [ -z "${frun}" ] && [ "${counter}" -lt "4" ]; do
#### #### Setup #### ####
# This is to set up the directories and files required for a clean startup.
if [ ! -d "plugins" ] && [ ! -e "eula.txt" ] && [ ! -e "server.properies" ] && [ ! -e "spigot.yml" ]; then
	mkdir "plugins"
	touch "eula.txt"
	echo "eula=${eula}" > "eula.txt"
# Setting up server.properties, if file exists, we will skip this.
	if [ ! -e "server.properties" ]; then
		printf "level-seed=%s\nlevel-name=%s\nview-distance=%s\nserver-port=%s\nquery.port=%s\nwhite-list=%s\nmax-players=%s\nprevent-proxy-connections=%s" "${levelSeed}" "${world}" "${distance}" "${port}" "${queryPort}" "${whitelist}" "${maxPlayers}" "${proxy}" | fixquotes > "server.properties"
		printf "    entity-tracking-range:\n      players: %s" "${playerTrackingRange}" | fixquotes > "spigot.yml"
	fi
else
	# if files exist, then just update the configs.
	sed -i -e "s/level-seed=.*$/level-seed=${levelSeed}/" -e "s/level-name=.*$/level-name=${world}/" -e "s/view-distance=.*$/view-distance=${distance}/" -e "s/server-port=.*$/server-port=${port}/" -e "s/query.port=.*/query.port=${queryPort}/" -e "s/white-list=.*$/white-list=${whitelist}/" -e "s/max-players=.*$/max-players=${maxPlayers}/" -e "s/prevent-proxy-connections=.*$/prevent-proxy-connections=${proxy}/" -e 's/"//g' "server.properties"
	sed -i -e "s/players: .*$/players: ${playerTrackingRange}/" -e "s/restart-script:.*/restart-script: paperStart.sh/" -e 's/"//g' "spigot.yml"
	sed -i -e "s/eula=.*/eula=${eula}/" -e 's/"//g' "eula.txt"
fi
#### #### #### ####
# Download paper, if allowed to
if [ "${paperUpdate}" == "true" ]; then
	# If paperclip.jar does not exist, download normally.
	if [ ! -e "${jar}" ]; then
		wget --quiet "https://papermc.io/api/v1/paper/${minecraftVersion}/latest/download" -O "${jar}"
	else
	# Else, Download if file is newer.
		wget -N --quiet "https://papermc.io/api/v1/paper/${minecraftVersion}/latest/download" -O "${jar}"
	fi
fi

# Download any link listed in the "plugins.txt" file, if it exists, then delete it.
if [ -f "plugins.txt" ]; then
	wget --quiet -i "plugins.txt" -P "plugins/"
	rm "plugins.txt"
fi
# Let's rest for a moment.
sleep 0.5
# Finally ... Start the server.
# If no Xms or Xmx Arguments ... fail!
# also look at eula.txt
chkeula=$(grep "eula=false" "eula.txt")
if [ -z "${Xmx}" ]; then
        echo "You did not set any memory for Xmx!"
    else
        if [ -z "${Xms}" ]; then
            echo "You did not set any memory for Xms!"
        fi
        if [ -n "${chleula}" ]; then
            echo "You did not accept the EULA!"
        fi
fi

if [ -n "${Xmx}" ] || [ -n "${Xms}" ] || [ -z "${chkeula}" ]; then
	# Now check if the memory allocation contains letters .. if so then fail.
	checkvar=$(echo "${Xms} ${Xmx}" | grep "[^0-9]")
	if [ "${checkvar}" ]; then
		# Missing File Edge-case fix
		if [ ! -e "spigot.yml" ]; then
			touch "spigot.yml"
		fi
		# Check if it is the first run...
		frun=$(find "spigot.yml" -type f -size -2k)
		if [ -n "${frun}" ]; then
			echo "First run, Starting and stopping server to initilize spigot.yml"
			sleep 1
			echo "stop" | java -Xmx"${Xmx}"M -Xms"${Xms}"M -jar "${jar}" nogui
			sleep 1
		# If not first run, then start normally.
		else
			# If no arguments, then start the server as-is
			if [ -z "${arguments}" ]; then
				java -Xmx"${Xmx}"M -Xms"${Xms}"M -jar "${jar}" nogui
			else
				java -Xmx"${Xmx}"M -Xms"${Xms}"M -jar "${jar}" "${arguments}" nogui
			fi
		fi
	else
		echo "There's a non-numerical character in memory allocation variable!"
	fi
fi
# Adding a counter, so we do not get stuck forever.
counter=$((counter + 1))
if [ "${counter}" -eq "3" ]; then
	echo "Well, that didn't work... Check your set-up."
	break
fi
sleep 0.5
done
