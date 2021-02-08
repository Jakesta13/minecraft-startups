#!/bin/bash
# Add direct downloads to plugins you wish to download to "plugins.txt" and this script will download them.

### ### Settings ### ###
# Allow auto updates of paper?
paperupdate="${1:-true}"
# Paper Minecraft Version
mcver="${2:-1.16.5}"
# Server jar name
jar="${3:-paperclip.jar}"

# Allow Auto-updates of UhcCore?
UHCupdate="${4:-true}"
# Lock to Specific Version?
# Leave Blank to always get latest.
UHCver="${5}"

# Memory arguments, in MB - Required
Xmx="${6}"
Xms="${7}"
# Startup Arguments - Optional
args="${8}"

# EULA acceptance? - Required
eula="${9:-false}"
# https://www.minecraft.net/en-us/eula

## Server.properties
# Level-seed
levelseed="${10}"

# Level-name
world="${11:-world}"

# View-Distance
distance="${12:-10}"

# Server Port
port="${13:-25565}"

# White-list
whitelist="${14:-false}"

# max-players
maxp="${15:-20}"

# prevent proxy connections?
proxy="${16:-true}"

## spigot.yml setup
# Player entity tracking range
prange="${17:-256}"
### ### ### ###
# Syntax
# ./uhc-start.sh paperupdate(y/n) mcver(1.16.5) jar(paperclip.jar) UHCupdate(y/n) UHCver(v1.18) Xmx(1024) Xms(1024) args(nogui) eula(false) levelseed(1234) world(world) view-distance(10) port(25565) whitelist(false) max-players(20) block-proxy-connections(true) player-tracking-range(256)
# if all arguments are blank give syntax
# Unfortunately at the moment I don't know an easy way to implement setting named variables .. when I learn more then it may be included.
fullarguments="${@}"
if [ ! "${fullarguments}" ]; then
	printf "Syntax: \n./uhc-start.sh paperupdate(y/n) mcver(1.16.5) jar(paperclip.jar) UHCupdate(y/n) UHCver(v1.18) Xmx(1024) Xms(1024) args(nogui) eula(false) levelseed(1234) world(world) view-distance(10) port(25565) whitelist(false) max-players(20) block-proxy-connections(true) player-tracking-range(256)\n"
	exit 1
fi
## ## Functions ## ##
# Removes all double-quotes from any input
fixquotes () {
sed -e 's/"//g'
}
## ## ## ##
#### #### Setup #### ####
# This is to set up the directories and files required for a clean startup.
if [ ! -d "plugins" ] && [ ! -e "eula.txt" ] && [ ! -e "server.properies" ] && [ ! -e "spigot.yml" ]; then
	mkdir "plugins"
	touch "eula.txt"
	echo "eula=${eula}" > "eula.txt"
# Setting up server.properties, if file exists, we will skip this.
	if [ ! -e "server.properties" ]; then
		printf "level-seed=${levelseed}\nlevel-name=${world}\nview-distance=${distance}\nserver-port=${port}\nwhite-list=${whitelist}\nmax-players=${maxp}\nprevent-proxy-connections=${proxy}" | fixquotes > "server.properties"
		printf "    entity-tracking-range:\n      players: ${prange}" | fixquotes > "spigot.yml"
	fi
else
	# if files exist, then just update the configs.
	sed -i -e "s/level-seed=.*$/level-seed=${levelseed}/" -e "s/level-name=.*$/level-name=${world}/" -e "s/view-distance=.*$/view-distance=${distance}/" -e "s/server-port=.*$/server-port=${port}/" -e "s/white-list=.*$/white-list=${whitelist}/" -e "s/max-players=.*$/max-players=${maxp}/" -e "s/prevent-proxy-connections=.*$/prevent-proxy-connections=${proxy}/" -e 's/"//g' "server.properties"
	sed -i -e "s/players: .*$/players: ${prange}/" -e 's/"//g' "spigot.yml"
	sed -i -e "s/eula=.*/eula=${eula}/" -e 's/"//g' "eula.txt"
fi
#### #### #### ####

# Download paper, if allowed to
if [ "${paperupdate}" == "true" ]; then
	# If paperclip.jar does not exist, download normally.
	if [ ! -e "${jar}" ]; then
		wget --quiet "https://papermc.io/api/v1/paper/${mcver}/latest/download" -O "${jar}"
	else
	# Else, Download if file is newer.
		wget -N --quiet "https://papermc.io/api/v1/paper/${mcver}/latest/download" -O "${jar}"
	fi
fi

# Download UHC, if allowed to
if [ "${UHCupdate}" == "true" ]; then
	# If we are not locked to one specific version of the plugin, then lets grab the latest.
	if [ ! "${UHCver}" ]; then
		# Curl from https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c#gistcomment-2552690
		getUHC=$(curl --silent "https://api.github.com/repos/Mezy/UhcCore/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
		echo "UhCore Version: ${getUHC}"
		# If UhcCore plugin does not exist, then download normally.
		if [ ! -e "plugins/UhcCore.jar" ]; then
			wget --quiet "https://github.com/Mezy/UhcCore/releases/download/${getUHC}/UhcCore-${getUHC}.jar" -O "plugins/UhcCore.jar"
		else
		# Else, Download if file is newer
			wget -N --quiet "https://github.com/Mezy/UhcCore/releases/download/${getUHC}/UhcCore-${getUHC}.jar" -O "plugins/UhcCore.jar"
		fi
	else
	# Else, we are locked to a version... now we do the same as above, but use a different variable.
		echo "Locked UhcCore Version: ${UHCver}"
                # If UhcCore plugin does not exist, then download normally.
                if [ ! -e "plugins/UhcCore.jar" ]; then
                        wget --quiet "https://github.com/Mezy/UhcCore/releases/download/${UHCver}/UhcCore-${UHCver}.jar" -O "plugins/UhcCore.jar"
                else
                # Else, Download if file is newer
                        wget -N --quiet "https://github.com/Mezy/UhcCore/releases/download/${UHCver}/UhcCore-${UHCver}.jar" -O "plugins/UhcCore.jar"
                fi
	fi
fi
# Download any link listed in the "plugins.txt" file, if it exists, then delete it.
if [ -f "plugins.txt" ]; then
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
	echo "You did not specify any memory allocations, You need to make sure -Xms and -Xmx are set!"
else
	# Now check if the memory allocation contains letters .. if so then fail.
	checkvar=$(echo "${Xms} ${Xmx}" | grep [^0-9])
	if [ "${checkvar}" ]; then
		# If no arguments, then start the server as-is
		if [ ! "${args}" ]; then
			java -Xmx"${Xmx}"M -Xms"${Xms}"M -jar "${jar}" nogui
		else
			java -Xmx"${Xmx}"M -Xms"${Xms}"M -jar "${jar}" nogui
		fi
	else
		echo "There's a non-numerical character in memory allocation variable!"
	fi
fi
