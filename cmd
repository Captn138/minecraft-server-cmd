#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/cmd"
CMD_MINECRAFT_SERVER=MinecraftServer #!!! DO NOT MODIFY THIS COMMENT

help() {
	echo "Help screen for Minecraft server remote cmd"
	echo "To create an example script that would work with cmd, type cmd -s or --setup"
	echo -e "\nOptions:"
        echo -e "\t-b | --backup\t\t\t: Starts a forced backup."
	echo -e "\t-c | --connect\t\t\t: Connects to the Minecraft server console."
	echo -e "\t-d | --detach\t\t\t: Detaches the screen if something went wrong. Safe command, does not kill the process."
        echo -e "\t-h | --help\t\t\t: Shows this help screen"
        echo -e "\t-r | --restart (-f | --force)\t: Stops the server in 30 seconds. Use the --force option to force the stopping right away. Usually, you would want it to always restart. Use a while(1) in your launching script or Restart=always in your systemd service."
        echo -e "\t-s | --setup\t\t\t: Creates an example script example.sh that can be tweaked then used as a starting script compatible with cmd. You must allow execution on the newly created script, and it is better to rename it."
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

setup() {
	read -p "Do you want to install java? [y/n] (default n) " var1
	if [ ! -z $var1 ]; then
		var1=$(echo "$var1" | tr '[:upper:]' '[:lower:]')
		if [ $var1 = "y" ]; then
			if [ $EUID -ne 0 ]; then
				echo "This part of the script must be executed as root!"
				exit -1
			else
				apt install default-jre -y
			fi
		fi
	fi
	read -p "Do you want to install screen? [y/n] (default n) " var1
	if [ ! -z $var1 ]; then
		var1=$(echo "$var1" | tr '[:upper:]' '[:lower:]')
		if [ $var1 = "y" ]; then
			if [ $EUID -ne 0 ]; then
				echo "This part of the script must be executed as root!"
				exit -1
			else
				apt install screen -y
			fi
		fi
	fi
	echo "#!/bin/bash" > example.sh
	read -p "What is the name of the server? " servername
	if [ -z $servername ]; then
		servername=minecraftserver
	fi
	sed -i "/\!\!\!/c CMD_MINECRAFT_SERVER\=$servername #\!\!\! DO NOT MODIFY THIS COMMENT" $SCRIPTPATH
	echo "CMD_MINECRAFT_SERVER=$servername #You can customize this name" >> example.sh
	read -p "What is the absolute path of the directory the server will be in? " $serverdirectory
	if [ -z $serverdirectory ]; then
		serverdirectory=/opt/minecraftserver
	fi
	echo "CMD_MINECRAFT_SERVER_PATH=$serverdirectory #Path of the server. Must be set correctly" >> example.sh
	read -p "If you are using a custom java version, enter its path. Else leave blank." customjavaversion
	if [ -z $customjavaversion ]; then
		customjavaversion=/usr/bin/java
	fi
	echo "CUSTOM_JAVA_VERSION=$customjavaversion #If you use a custom java version, set its path here. Else leave it as it is." >> example.sh
	read -p "What is the name of the Minecraft server jar executable? (example: minecraft_server.jar) " serverexecutable
	if [ -z $serverexecutable ]; then
		serverexecutable=java
	fi
	echo "CMD_MINECRAFT_SERVER_EXECUTABLE=$serverexecutable #Name of the jar executable. Must be set correctly." >> example.sh
	read -p "What is the maximum amount of RAM the server should use? (Syntax: 1G or 150M) " servermaxram
	if [ -z $servermaxram ]; then
		servermaxram=4G
	fi
	echo "MAX_RAM=$servermaxram #Maximum RAM the server can use. Set it with your hardware specs." >> example.sh
	read -p "What is the minimum amount of RAM the server should use? (Syntax: 1G or 150M) " serverminram
	if [ -z $serverminram ]; then
		serverminram=1G
	fi
	echo "MIN_RAM=$serverminram #Minimum RAM usage." >> example.sh
	read -p "If you are using a custom screen version, enter its path. Else leave blank." customscreenversion
	if [ -z $customscreenversion ]; then
		customscreenversion=/usr/bin/screen
	fi
	echo "SCREEN_PATH=$customscreenversion #Change this if your screen packet is not in /usr/bin/screen." >> example.sh
	echo -e "\ncd $CMD_MINECRAFT_SERVER_PATH" >> example.sh
	echo "$Screen_PATH -dmS $CMD_MINECRAFT_SERVER $CUSTOM_JAVA_VERSION -server -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -Xmx$MAX_RAM -Xms$MIN_RAM -jar $CMD_MINECRAFT_SERVER_PATH/$CMD_MINECRAFT_SERVER_EXECUTABLE nogui" >> example.sh
	read -p "Do you want to launch the server now? [y/n] (default n) " var1
	if [ ! -z $var1 ]; then
		var1=$(echo "$var1" | tr '[:upper:]' '[:lower:]')
		if [ $var1 = "y" ]; then
			./example.sh
		fi
	fi
}

if [ -n "$1" ]; then
	case "$1" in
		-b|--backup   ) backup;;
		-c|--connect  ) connect;;
		-d|--detach   ) detach;;
		-h|--help     ) help;;
		-r|--restart  ) restart $2;;
		-s|--setup    ) setup;;
		-x|--execute  ) execute ${@:2};;
		-w) echo $SCRIPTPATH;;
		*             ) unrecognized;;
	esac
else
	connect
fi
