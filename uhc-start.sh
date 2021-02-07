#!/bin/bash
# Add direct downloads to plugins you wish to download to "plugins.txt" and this script will download them.
### ### Settings ### ###
# Allow auto updates of paper?
paperupdate=y
# Paper Minecraft Version
mcver=1.16.5
# Server jar name
jar=paperclip.jar

# Allow Auto-updates of UhcCore?
UHCupdate=y
# Lock to Specific Version?
# Leave Blank to always get latest.
UHCver=

# Memory arguments, in MB - Required
Xmx=
Xms=
# Startup Arguments - Optional
args=

# EULA acceptance? - Required
eula=false
# https://www.minecraft.net/en-us/eula

## Server.properties
# Level-seed
levelseed=

# Level-name
world=

# View-Distance
distance=

# Server Port
port=

# White-list
whitelist=

# max-players
maxp=

# prevent proxy connections?
proxy=

## spigot.yml setup
# Player entity tracking range
prange=
### ### ### ###

#### #### Setup #### ####
# This is to set up the directories and files required for a clean startup.
if [ ! -d "plugins" ] || [ ! -f "eula.txt" ] || [ ! -f "server.properies" ] [ ! -f "spigot.yml"; then
	mkdir "plugins"
	touch "eula.txt"
	echo "eula=${eula}" > "eula.txt"
# Setting up server.properties, if file exists, we will skip this.
	if [ ! -e "server.properties" ]; then
		printf "level-seed=${levelseed}\nlevel-name=${world}\nview-distance=${distance}\nserver-port=${port}\nwhite-list=${whitelist}\nmax-players=${maxp}\nprevent-proxy-connections=${proxy}" > "server.properties"
		printf "    entity-tracking-range:\n      players: ${prange}" > "spigot.yml"
	fi
	else
	# if files exist, then just update the configs.
	sed -i -e "s/level-seed=.*$/level-seed=${levelseed}/" -e "s/level-name=.*$/level-name=${world}" -e "s/view-distance=.*$/view-distance=${distance}" -e "s/server-port=.*$/server-port=${port}/" -e "s/white-list=.*$/white-list=${whitelist}/" -e "s/max-players=.*$/max-players=${maxp}" -e "s/prevent-proxy-connections=.*$/prevent-proxy-connections=${proxy}" "server.properties"
	sed -i -e "s/players: .*$/players: ${prange}" "spigot.yml"
	sed -i -e "s/eula=.*/eula=${eula}" "eula.txt"
fi
#### #### #### ####

# Download paper, if allowed to
if [ "${paperupdate}" == "y" ]; then
	# If paperclip.jar does not exist, download normally.
	if [ ! -e "${jar}" ]; then
		wget --quiet "https://papermc.io/api/v1/paper/${mcver}/latest/download" -O "${jar}"
	else
	# Else, Download if file is newer.
		wget -N --quiet "https://papermc.io/api/v1/paper/${mcver}/latest/download" -O "${jar}"
	fi
fi

# Download UHC, if allowed to
if [ "${UHCupdate}" == "y" ]; then
	# If we are not locked to one specific version of the plugin, then lets grab the latest.
	if [ ! "${UHCver}" ]; then
		# Curl from https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c#gistcomment-2552690
		getUHC=$(curl --silent "https://api.github.com/repos/$1/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
		echo "UhCore Version: ${getUHC}"
		# If UhcCore plugin does not exist, then download normally.
		if [ ! -e "plugins/UhcCure.jar" ]; then
			wget --quiet "https://github.com/Mezy/UhcCore/releases/download/${getUHC}/UhcCore-${getUHC}.jar" - O "plugins/UhcCore.jar"
		else
		# Else, Download if file is newer
			wget -N --quiet "https://github.com/Mezy/UhcCore/releases/download/${getUHC}/UhcCore-${getUHC}.jar" - O "plugins/UhcCore.jar"
		fi
	else
	# Else, we are locked to a version... now we do the same as above, but use a different variable.
		echo "Locked UhcCore Version: ${UHCver}"
                # If UhcCore plugin does not exist, then download normally.
                if [ ! -e "plugins/UhcCure.jar" ]; then
                        wget --quiet "https://github.com/Mezy/UhcCore/releases/download/${UHCver}/UhcCore-${UHCver}.jar" - O "plugins/UhcCore.jar"
                else
                # Else, Download if file is newer
                        wget -N --quiet "https://github.com/Mezy/UhcCore/releases/download/${UHCver}/UhcCore-${UHCver}.jar" - O "plugins/UhcCore.jar"
                fi
	fi
fi
# Download any link listed in the "plugins.txt" file, if it exists, then delete it.
if [ -f "plugins.txt" }; then
	cat "plugins.txt" |
	while read -r line; do
		wget --quiet "${line}" -P "plugins/"
	done
fi
# Let's rest for a moment.
sleep 0.5
# Finally ... Start the server.
# If no Xms or Xmx Arguments ... fail!
if [ ! "${Xmx}" ] || [ ! "${Xms}" ]; then
	echo "You did not specify a memory allocations, You need to make sure -Xms and -Xmx are set!"
else
	# Now check if the memory allocation contains letters .. if so then fail.
	checkvar=$(echo "${Xms} ${Xmx}" | grep [^0-9])
	if [ ! "${checkvar}" ]; then
		# If no arguments, then start the server as-is
		if [ ! "${args}" ]; then
			java -jar -Xmx"${Xmx}"M -Xms"${Xms}"M "${jar}" nogui
		else
			java -jar -Xmx"${Xmx}"M -Xms"${Xms}"M "${jar}" "${args}" nogui
		fi
	else
		echo "There's a non-numerical character in memory allocation variable!"
	fi
fi
