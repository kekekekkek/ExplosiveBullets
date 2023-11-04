# ExplosiveBullets
Want some fun? - Then this plugin is for you!<br><br>You are probably already tired of the large number of enemies and rather boring maps. With this plugin, you can turn any map into a real meat grinder. You can watch a short [video](https://youtu.be/1-sqQp1-930) about how this plugin works.

# Installation
Installing the plugin consists of several steps:
1. [Download](https://github.com/kekekekkek/ExplosiveBullets/archive/refs/heads/main.zip) this plugin;
2. Open the `..\Sven Co-op\svencoop_addon\scripts\plugins` directory and place the `ExplosiveBullets` folder there;
3. Next, go to the `..\Sven Co-op\svencoop` folder and find there the text file `default_plugins.txt`;
4. Open this file and paste the following text into it:
```
	"plugin"
	{
		"name" "ExplosiveBullets"
		"script" "ExplosiveBullets/ExplosiveBullets"
	}
```
5. After completing the previous steps, you can run the game and check the result.

# Commands
When you start the game and connect to your server, you will have the following plugin commands at your disposal, which you will have to write in the game chat to activate them.
| Command | MinValue | MaxValue | DefValue | Description | Usage | 
| -------| -------- | -------- | -------- | ----------- | ----------- |
| `.ebs`, `/ebs` or `!ebs` | `0` | `1` | `1` | Allows you to enable or disable this feature. | Usage: `.ebs//ebs/!ebs <state>.` Example: `!ebs 1` |
| `.ebm`, `/ebm` or `!ebm` | `25` | `5000` | `25` | Allows you to set the magnitude of the bullet explosion. | Usage: `.ebm//ebm/!ebm <magnitude>.` Example: `!ebm 125` |
| `.ebao`, `/ebao` or `!ebao` | `0` | `1` | `1` | Allows you to enable this feature only for admins or for all players.<br>`0 - For everyone;`<br>`1 - Admins only.` | Usage: `.ebao//ebao/!ebao <adminsonly>.` Example: `!ebao 0` |
| `.ebr`, `/ebr` or `!ebr` | `-` | `-` | `-` | Allows you to reset the settings to the default settings. | `No arguments.` |

**REMEMBER**: This plugin only works for admins. If you want the plugin to work for everyone, you need to enter the command `!ebao 0` in chat.<br>
**REMEMBER**: This plugin is a reworking of another plugin called [BulletTracer](https://github.com/kekekekkek/BulletTracer).<br>
**REMEMBER**: This plugin, like the [BulletTracer](https://github.com/kekekekkek/BulletTracer) plugin, doesn't use the `WeaponSecondaryAttack` and `WeaponTertiaryAttack` hooks, as there will be some peculiarities to consider. You can finalize this yourself if you want.<br>
**REMEMBER**: Also, this plugin works fine with the [BulletTracer](https://github.com/kekekekkek/BulletTracer) plugin.
