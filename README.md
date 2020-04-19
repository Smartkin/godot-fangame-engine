# Godot engine for fangames
An engine for fangames made in Godot 3.2.1

# Changelog
> v0.9

- First release

> v1.0

- Add configurations
- Add simple pause menu

> v1.01

- Fix current song not getting set when no song is being played

> v1.02

- Move button prompts to general settings
- Add DEBUG_MODE constant
- Add restarting when playing individual scenes
- Fix pause menu staying when restarting the game
- Revert camera zoom back to normal
- Add more descriptive comments

> v1.03

- Load music recursively from the music folder

> v1.04

- Rewrite all scripts to comply with [GDScript style](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_styleguide.html) as recommended by Godot engine

# Features
* Adjusted kid's physics, fall speed is lowered, coyote frames added, jump input buffering added (If desidered all can be adjusted to feel closer to original fangame physics)
* Standard gimmicks (Vines, 3 water types, one-way platforms(not coded in a potato way), gravity flipping and slopes)
* Save/load with encryption or without in case you need that for debugging
* Customizable configuration. Such as fullscreen, music, borderless window, key binds for keyboard and controller, music volumes for multiple channels such as master, music and sound effects
* Simple pause menu showing Death/Time

# Contribution
You feel like something is lacking in the engine? Then feel free to contribute such a change or submit an issue to this repository.
To contribute yourself create a fork of this repository, clone the fork to yourself, push the needed changes and then create a pull request.

If you are making an issue, please make a good description as to what exactly you want to be added and why

# Code style
When you contribute something by yourself please keep the code style used throughout the engine. Style used is the style recommended by Godot engine in its [documentation](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_styleguide.html) and also use [static typing](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/static_typing.html) only

# Contact
* Discord: Smartkin#7777
