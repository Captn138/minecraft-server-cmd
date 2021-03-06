# minecraft-server-cmd
A Minecraft server console utility
```
Help screen for Minecraft server remote cmd
To create an example script that would work with cmd, type cmd -s or --script

Options:
	-b | --backup			: Starts a forced backup.
	-c | --connect			: Connects to the Minecraft server console.
	-d | --detach			: Detaches the screen if something went wrong. Safe command, does not kill the process.
	-h | --help			: Shows this help screen
	-r | --restart (-f | --force)	: Stops the server in 30 seconds. Use the --force option to force the stopping right away. Usually, you would want it to always restart. Use a while(1) in your launching script or Restart=always in your systemd service.
	-s | --script			: Creates an example script example.sh that can be tweaked then used as a starting script compatible with cmd. You must allow execution on the newly created script, and it is better to rename it.
	-x | --execute [command]	: Executes the desired command in the Minecraft server console
  ```
