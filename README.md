# Pacman in Godot 4.3
My goal is to recreate Pacman in Godot and learn Godot in the process. In this project I used GDScript and the engine (avoiding C# and C++ as to learn something new).

# Why
I would like to create larger projects in Godot engine however most of the issues that come from a engine or language do not occur with a small game. Issues occur with larger projects such as, asset management, script management, performance, features, how to layout certain scripts to obtain certain features and so on. Pacman is an obtainable goal as a game which should allow for a finish line and a retrospective on my next project. Even **if this project is never finished it should inform the next project**.

# Method
Pacman is a big game and to get it right it does require some planning, below is my plan:

1. Create a level editor using a basic tileset
2. Use this level edtior to craft the tileset for the game
3. Create a level and aim for Pacman navigating the Maze (without moving off screen)
4. Create a system to move between screens
5. Add Ghosts with basic AI (navigates towards player)
6. Add pickups and have the level restart upon picking up all
7. Add A* Pathfinding to Ghosts
   + Add ghosts moving between screens and have the costing value mean they will actually use the shortcut
   + Also during this time differences in ghost colour behaviour will be tuned
8. Pickup to eat ghosts (and run away behaviour)
9. Scoreboard
10. Polish:
    + More valuable pickups spawn once per level
    + Lives
    + Music and Sound effects
    + Title Screen

# 1. Create a level Editor
For this I created a `DesignerTile` scene and repurposed a shader to render a single tile:
```
shader_type canvas_item;

uniform int tilesHorizontal : hint_range(1,128);
uniform int tilesVertical : hint_range(1,128);
uniform vec2 currentTile = vec2(0,0);

void fragment() 
{
	vec2 baseUV = (UV / vec2(float(tilesHorizontal),float(tilesVertical)));
	baseUV += currentTile/vec2(float(tilesHorizontal),float(tilesVertical));
	COLOR = texture(TEXTURE, baseUV);
}
```
The result allows any designer to key in the split horizontally and vertically and then get out the exact tile they require. This is not the main way to interface with `DesignerTile` there is a method '`SetTile`' which will handle this for you on an instance basis. Each `DesignerTile` can be given a position in the larger scene it will hold on to. Upon a left click it will give it's current tile and the position in the larger scene to the signal.
![A texture rendered as part of the larger texture](https://github.com/ScottGarryFoster/Game-PacmanInGodot/blob/main/Development/001-LD-SingleTile.png?raw=true)
Taking this a step further, the `TileChooser` scene spawns 3 `DesignerTiles` and listens to the signal, "I have been clicked, you told me I was here and I look like this". For `TileChooser` it give this information to the `LevelDesigner` which updates it's current '`SelectedTile`' and this is what you paint in the main area.

After around 2 hours of setup and learning how best to put all this together, the below image shows my result.
![A mouse clicks on tiles, another tile changes to match](https://github.com/ScottGarryFoster/Game-PacmanInGodot/blob/main/Development/001-LD-TileSelection.gif?raw=true)
Next I needed a grid to paint upon with the '`SelectedTile'`