# **Nspire-Triangle**
I started to learn about Lua scripting for the TI-Nspire suite of calculators.
There is a lot of cosmetic work to be done for this project however it currently
functions quite well. If it isn't broke, don't fix it.

![screenshot](SSS&#32;screenshot.png)

## Compile
Compile the Lua file to a tns file, then download it to a supported device. I
suggest using [Luna](https://github.com/ndless-nspire/Luna) to compile, its easy
and you should be able to figure it out.

## Usage
* Open the document `"triag"` *(or whatever you name it)* on your calculator
* Enter exactly 3 values for the triangle you would like to solve
  * You may press `[tab]` or `[shift]+[tab]` to cycle input boxes respectively
* Press `[Menu]` > `[1 Solve]` > `[1 Calculate]`

The triangles solution should be displayed on the lower half of the screen. If
there are 2 solutions they will be shown in the same location but will read
`"value 1 or value 2"`

## To Do
- [ ] Figure out if I can remove the sub level of the menu
- [ ] If I can't rename it to something like "Menu"
- [ ] Convert the string to not overwrite the answers array
- [ ] Add option to save output to variables then into another document
- [ ] Add option to save inputs
- [ ] Add on.save event handler to save inputs and answer outputs
