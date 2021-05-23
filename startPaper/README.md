# startPaper
For notmal setups just download startPaper.sh and, preferably, create a start.conf with the following vairbales set.

For use with [PufferPanel](https://github.com/PufferPanel/PufferPanel), you can Copy/Paste the JSON file named startPaper.json and tweak it on PufferPanel's Template page.
## Note
[*] You will need to edit the config instead of the server.properties for the vairables below....
[*] You will also need to edit the config instead of spigot.conf for playerTrackingRange.


## Vairable Descriptions
``
[*] Enables paper to update to the latest build of the version mentioned below.
paperUpdate=true
``
``
[*] This will set the version of paper to download
minecraftVersion=1.16.5
``
[*] Sets the filename to rename paper to.
``
jar=paperclip.jar
``
[*] Set the maximum assigned memory in MB, numericals only.
``
Xmx=1024
``
[*] Set the minimum assigned memory in MB, numericals only, you usually want this to be the same as Xmx.
``
Xms=1024
``
[*] pass any java arguments here
``
arguments=
``
[*] Accept the EULA to start the server ... Actually accept this, not just put true.
``
eula=false
``
[*] Level Seed .. blank for minecraft randomized.
``
levelSeed=
``
[*] World name .. Leave blank for minecraft to set to "world".
``
world=world
``
[*] Set the view distance.
``
distance=10
``
[*] Set the server port, blank to default to 25565.
``
port=25565
``
[*] Set Query port, usually the same as server port.
``
queryPort=25565
``
[*] Enable or disable the whitelist.
``
whitelist=false
``
[*] Set the Max players.
``
maxPlayers=20
``
[*] Toggle Prevent Proxy Connections, I usually set to true .. it doesn't change much.
``
proxy=true
``
[*] Spigot.conf setting for how far you can see players .. for a UHC server you might want this higher than default 28.
``
playerTrackingRange=28
``
