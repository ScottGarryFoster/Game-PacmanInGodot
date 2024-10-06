extends Node2D

## The scene to spawn tiles for.
var DesignerTileScene = preload("res://Scenes/LevelDesigner/DesignerTile/DesignerTile.tscn")

## The script to use when spawning tiles.
var DesignerTileScript = preload("res://Scenes/LevelDesigner/DesignerTile/DesignerTile.gd")

## Relative to the origin of the scene, where to begin placing tiles.
@export var StartLocation : Vector2

## The scale to set each tile.
@export var ScaleForEachTile : Vector2

## The size of each tile and therefore the amount to place them apart.
@export var PixelSizeForEachTile : Vector2

## Stores all tiles in the chooser.
var SelectableTileCollection = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SpawnSelectableTiles()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Spawns tiles for the chooser.
func SpawnSelectableTiles():
	
	var currentLocation = StartLocation
	for i in range(3):
		var currentTile = DesignerTileScene.instantiate()
		SelectableTileCollection.append(currentTile)
		
		# Move to correct position
		currentTile.position = currentLocation;
		currentLocation.x += PixelSizeForEachTile.x
		currentTile.scale = ScaleForEachTile
		
		# Setup the place the tile has in our world and the tile to paint
		# If we have issues with this, ensure the startup for DesignerTile
		# does not mess with the Shader or call SetTile.
		currentTile.CurrentLocationInOuterWorld = Vector2i(i, 0)
		currentTile.SetTile(Vector2i(i, 1))
		
		# Hook up the event upon selected
		if currentTile.has_signal("TileSelected"):
			currentTile.connect("TileSelected", Callable(self, "OnTileSelected"))
		
		add_child(currentTile)
		
		print(str(currentLocation.x) + ", " + str(currentLocation.y))
	pass

## Responds to tiles selected.
func OnTileSelected(contextToUs: Vector2i, shaderTile: Vector2i):
	print("ShaderTile: " + str(shaderTile.x) + ", " + str(shaderTile.y))
	print("ContextToUs: " + str(contextToUs.x) + ", " + str(contextToUs.y))
	pass
