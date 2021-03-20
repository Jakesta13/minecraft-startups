#!/bin/bash
## Settings ##
# See VanillaVotifer.conf
if [ ! -e "VanillaVotifer.conf" ]; then
	wget --quiet ""
fi
source VanillaVotifer.conf
## ##
## Functions ##
# No Touchie #
function download {
wget -N --quiet "${updateUrl}" -O "${fileName}"
}
# Update / Download stage
if [ "${update}" == "true" ]; then
	# Curl from https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c#gistcomment-2552690
	getUpdate=$(curl --silent "https://api.github.com/repos/xMamo/VanillaVotifier/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
	updateUrl="https://github.com/xMamo/VanillaVotifier/releases/download/${getUpdate}/VanillaVotifier.jar"
	fileName="VanillaVotifier.jar"
	download
else
	if [ ! -z "${setVer}" ]; then
		echo "Downloading V${setVer}"
		setVer=$(echo "${setVer}" | sed -e 's/V//g' -e 's/v//g')
		updateUrl="https://github.com/xMamo/VanillaVotifier/releases/download/${setVer}/VanillaVotifier.jar"
		fileName="VanillaVotifier.jar"
	else
		echo "You need to set a version if you are not going to auto-update!"
	fi
fi


# Run stage
nice -n -10 java --Xms${Xms} --Xmx${Xmx} -jar VanillaVotifier.jar
