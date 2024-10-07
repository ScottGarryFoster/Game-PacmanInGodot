extends Node2D

## Called upon a new tile selection
## func OnSelectedNewTile(tilePosition: Vector2i):
signal SelectedNewTile

## Relative to the origin of the scene, where to begin placing tiles.
@export var StartLocation : Vector2

## The scale to set each tile.
@export var ScaleForEachTile : Vector2

## The size of each tile and therefore the amount to place them apart.
@export var PixelSizeForEachTile : Vector2

@export var GridSize : Vector2i

## The scene to spawn tiles for.
var DesignerTileScene = preload("res://Scenes/LevelDesigner/DesignerTile/DesignerTile.tscn")

## The script to use when spawning tiles.
var DesignerTileScript = preload("res://Scenes/LevelDesigner/DesignerTile/DesignerTile.gd")

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
	
	if GridSize.x == 0:
		GridSize.x = 5
	if GridSize.y == 0:
		GridSize.y = 5
			
			
	var currentLocation = StartLocation
	for y in range(GridSize.y):
		for x in range(GridSize.x):
			var currentTile = DesignerTileScene.instantiate()
			SelectableTileCollection.append(currentTile)
			
			# Move to correct position
			currentTile.position = currentLocation;
			currentLocation.x += PixelSizeForEachTile.x
			currentTile.scale = ScaleForEachTile
			
			# Setup the place the tile has in our world and the tile to paint
			# If we have issues with this, ensure the startup for DesignerTile
			# does not mess with the Shader or call SetTile.
			currentTile.CurrentLocationInOuterWorld = Vector2i(x, y)
			currentTile.SetTile(Vector2i(0, 0))
			
			# Hook up the event upon selected
			if currentTile.has_signal("TileSelected"):
				currentTile.connect("TileSelected", Callable(self, "OnTileSelected"))
			
			add_child(currentTile)
			
			#print(str(currentLocation.x) + ", " + str(currentLocation.y))
		# end for x
		currentLocation.x = StartLocation.x
		currentLocation.y += PixelSizeForEachTile.y
	pass

func OnTileSelected(contextToUs: Vector2i, shaderTile: Vector2i):
	SelectedNewTile.emit(contextToUs)
	pass
	
func SetTile(tilePosition: Vector2i, shaderTile: Vector2i) -> bool:
	if tilePosition.x < 0:
		return false
	if tilePosition.x > GridSize.x - 1:
		return false
		
	if tilePosition.y < 0:
		return false
	if tilePosition.y > GridSize.y - 1:
		return false
		
	var indexOfPosition : int = tilePosition.y * GridSize.x + tilePosition.x;
	SelectableTileCollection[indexOfPosition].SetTile(shaderTile)
	return true
