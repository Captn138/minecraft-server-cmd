#!/bin/bash

CMD_MINECRAFT_SERVER=FeedTheBeast

help() {
	echo "Help screen for Minecraft server remote cmd"
	echo "To create an example script that would work with cmd, type cmd -s or --script"
	echo -e "\nOptions:"
        echo -e "\t-b | --backup\t\t\t: Starts a forced backup."
	echo -e "\t-c | --connect\t\t\t: Connects to the Minecraft server console."
	echo -e "\t-d | --detach\t\t\t: Detaches the screen if something went wrong. Safe command, does not kill the process."
        echo -e "\t-h | --help\t\t\t: Shows this help screen"
        echo -e "\t-r | --restart (-f | --force)\t: Stops the server in 30 seconds. Use the --force option to force the stopping right away. Usually, you would want it to always restart. Use a while(1) in your launching script or Restart=always in your systemd service."
        echo -e "\t-s | --script\t\t\t: Creates an example script example.sh that can be tweaked then used as a starting script compatible with cmd. You must allow execution on the newly created script, and it is better to rename it."
        echo -e "\t-x | --execute [command]\t: Executes the desired command in the Minecraft server console"
}

unrecognized() {
	echo "Option not recognised. Try cmd --help instead"
}

connect() {
	screen -r $CMD_MINECRAFT_SERVER
}

detach() {
	screen -d $CMD_MINECRAFT_SERVER
}

execute() {
	command=${@:1}
	screen -r $CMD_MINECRAFT_SERVER -p0 -X stuff "$command^M"
}

restart() {
	if [ -n "$1" ]; then
		case "$1" in
		-f|--force	) execute "kick @a Server restarted"; execute "stop";;
		*		) unrecognized;;
		esac
	else
		execute "say Server will restart in 30s."; sleep 20; execute "say 10"; sleep 5; execute "say 5"; sleep 1; execute "say 4"; sleep 1; execute "say 3"; sleep 1; execute "say 2"; sleep 1; execute "say 1"; execute "kick @a Server restarted"; execute "stop"
	fi
}

backup() {
	execute "backup start"
}

script() {
	echo "#!/bin/bash" > example.sh
	echo "CMD_MINECRAFT_SERVER=minecraft #Customize this name" >> example.sh
	echo "CMD_MINECRAFT_SERVER_PATH=/opt #Path of the server. Must be set correctly" >> example.sh
	echo "CUSTOM_JAVA_VERSION=java #If you use a custom java version, set its path here. Else leave it as it is." >> example.sh
	echo "CMD_MINECRAFT_SERVER_EXECUTABLE=minecraft_server.jar #Name of the jar executable. Must be set correctly." >> example.sh
	echo "MAX_RAM=8G #Maximum RAM the server can use. Set it with your hardware specs." >> example.sh
	echo "MIN_RAM=512M #Minimum RAM usage." >> example.sh
	echo "SCREEN_PATH=/usr/bin/screen #Change this if your screen packet is not in /usr/bin/screen." >> example.sh
	echo -e "\ncd $CMD_MINECRAFT_SERVER_PATH" >> example.sh
	echo "$Screen_PATH -dmS $CMD_MINECRAFT_SERVER $CUSTOM_JAVA_VERSION -server -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -Xmx$MAX_RAM -Xms$MIN_RAM -jar $CMD_MINECRAFT_SERVER_PATH/$CMD_MINECRAFT_SERVER_EXECUTABLE nogui" >> example.sh
}

if [ -n "$1" ]; then
	case "$1" in
		-b|--backup     ) backup;;
		-c|--connect	) connect;;
		-d|--detach	) detach;;
		-h|--help	) help;;
		-r|--restart	) restart $2;;
		-s|--script     ) script;;
		-x|--execute	) execute ${@:2};;
		*		) unrecognized;;
	esac
else
	connect
fi
