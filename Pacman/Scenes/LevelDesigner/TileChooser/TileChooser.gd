extends Node2D

## Called upon a new tile selection
## func OnSelectedNewTile(tilePosition: Vector2i):
signal SelectedNewTile

## Relative to the origin of the scene, where to begin placing tiles.
@export var StartLocation : Vector2

## The scale to set each tile.
@export var ScaleForEachTile : Vector2

## Texture to select tiles from
@export var ChooserTexture : Texture2D

## Number of columns and rows within the texture
@export var ChoserTextureColumnsAndRows : Vector2i

## The scene to spawn tiles for.
var ClickableTileScene = preload("res://Scenes/LevelDesigner/ClickableTile/ClickableTile.tscn")

## The script to use when spawning tiles.
var ClickableTileScript = preload("res://Scenes/LevelDesigner/ClickableTile/ClickableTile.gd")

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
		var currentTile = ClickableTileScene.instantiate()
		SelectableTileCollection.append(currentTile)
		
		# Move to correct position
		currentTile.position = currentLocation;
		currentLocation.x += (currentTile.GetSize().x * 2) * ScaleForEachTile.x
		currentTile.scale = ScaleForEachTile
		
		# Setup the place the tile has in our world and the tile to paint
		# If we have issues with this, ensure the startup for DesignerTile
		# does not mess with the Shader or call SetTile.
		currentTile.CurrentLocationInOuterWorld = Vector2i(i, 0)
		currentTile.SetTile(Vector2i(i, 0))
		currentTile.SetTexture(ChooserTexture, ChoserTextureColumnsAndRows)
		
		# Hook up the event upon selected
		if currentTile.has_signal("TileSelected"):
			currentTile.connect("TileSelected", Callable(self, "OnTileSelected"))
		
		add_child(currentTile)
		
		print(str(currentLocation.x) + ", " + str(currentLocation.y))
	pass

## Responds to tiles selected.
func OnTileSelected(contextToUs: Vector2i, shaderTile: Vector2i):
	SelectedNewTile.emit(shaderTile)
	pass
