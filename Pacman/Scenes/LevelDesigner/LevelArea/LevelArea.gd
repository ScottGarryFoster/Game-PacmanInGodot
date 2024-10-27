extends Node2D

## Called upon a new tile selection
## func OnSelectedNewTile(tilePosition: Vector2i):
signal SelectedNewTile

## Relative to the origin of the scene, where to begin placing tiles.
@export var StartLocation : Vector2

## The scale to set each tile.
@export var ScaleForEachTile : Vector2

## The number of tiles Width/Height.
@export var GridSize : Vector2i

## Defines each tile type. Used to parse them into ints for searching.
enum Tile 
{
	Nothing,
	Border,
	Barrier,
	Cage
}	

## The scene to spawn tiles for.
var DesignerTileScene = preload("res://Scenes/LevelDesigner/DesignerTile/DesignerTile.tscn")

## The script to use when spawning tiles.
var DesignerTileScript = preload("res://Scenes/LevelDesigner/DesignerTile/DesignerTile.gd")

## The scene to spawn tiles for.
var ClickableTileScene = preload("res://Scenes/LevelDesigner/ClickableTile/ClickableTile.tscn")

## The script to use when spawning tiles.
var ClickableTileScript = preload("res://Scenes/LevelDesigner/ClickableTile/ClickableTile.gd")

## Stores all tiles in the chooser.
var SelectableTileCollection = []

## Tiles which actually change
var ViewedTiles = []

## Stores the selected values as what is painted does match what is seen
var PaintedValues = []

## All the paintable textures. Order matters! The order matches the last value
## within the dictionary given.
var PaintableTextures: Array[Texture2D] = [
	preload("res://Media/Tilesets/PacmanBorder.png"),
	preload("res://Media/Tilesets/PacmanBarrierBigInner.png"),
	preload("res://Media/Tilesets/PacmanBarrierBigOuter.png"),
]

## Clickable Tile Texture
var ClickableTexture = preload("res://Media/Tilesets/ClickableTileset.png")

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
	
	# Cached version of size - this should be consistent
	var tileSize : Vector2 = Vector2(-1, -1)
	var currentLocation = StartLocation
	for y in range(GridSize.y):
		for x in range(GridSize.x):
			var currentTile = DesignerTileScene.instantiate()
			ViewedTiles.append(currentTile)
			PaintedValues.append(Vector2i(1, 0))
			
			if(tileSize.x == -1):
				tileSize = currentTile.GetSize()
			
			# Move to correct position
			currentTile.position = currentLocation;
			currentLocation.x += (tileSize.x * 2) * ScaleForEachTile.x
			currentTile.scale = ScaleForEachTile
			
			# Setup the place the tile has in our world and the tile to paint
			# If we have issues with this, ensure the startup for DesignerTile
			# does not mess with the Shader or call SetTile.
			currentTile.CurrentLocationInOuterWorld = Vector2i(x, y)
			currentTile.SetTile(Vector2i(0, 0))
			currentTile.SetTexture(PaintableTextures[0], Vector2i(4, 4))
			currentTile.z_index = 0
			add_child(currentTile)
			
			# Now the tile people select in the level editor
			var currentSelectableTile = ClickableTileScene.instantiate()
			SelectableTileCollection.append(currentSelectableTile)
			
			# Move to correct position
			currentSelectableTile.scale = ScaleForEachTile
			currentSelectableTile.position = currentLocation;
			
			# Shift correctly
			var MovementInPositiveDirection = tileSize * ScaleForEachTile
			var CorrectMovement = Vector2(-MovementInPositiveDirection.x, MovementInPositiveDirection.y)
			currentSelectableTile.position += CorrectMovement
			
			currentSelectableTile.CurrentLocationInOuterWorld = Vector2i(x, y)
			currentSelectableTile.SetTile(Vector2i(0, 0))
			currentSelectableTile.z_index = 1000
			currentSelectableTile.SetTexture(ClickableTexture, Vector2i(4, 4))
			currentSelectableTile.ReactToMouseOver = true
			add_child(currentSelectableTile)
			
			# Hook up the event upon selected
			if currentSelectableTile.has_signal("TileSelected"):
				currentSelectableTile.connect("TileSelected", Callable(self, "OnTileSelected"))
			
			
			#print(str(currentLocation.x) + ", " + str(currentLocation.y))
		# end for x
		currentLocation.x = StartLocation.x
		currentLocation.y += (tileSize.y * 2) * ScaleForEachTile.y
		
	RunAllRules()
	pass

func OnTileSelected(contextToUs: Vector2i, shaderTile: Vector2i):
	SelectedNewTile.emit(contextToUs)
	pass
	
func SetTile(tilePosition: Vector2i, shaderTile: Vector2i) -> bool:
	# Offset the view from the view
	tilePosition.x += 1;
	tilePosition.y += 1;
	
	if tilePosition.x < 0:
		return false
	if tilePosition.x > GridSize.x - 1:
		return false
		
	if tilePosition.y < 0:
		return false
	if tilePosition.y > GridSize.y - 1:
		return false
		
	var indexOfPosition : int = GetIndexFromPosition(tilePosition)
	PaintedValues[indexOfPosition] = shaderTile;
	RunAllRules()
	return true
	
func GetIndexFromPosition(position: Vector2i) -> int:
	return position.y * GridSize.x + position.x;

func RunAllRules():
	for y in range(GridSize.y):
		for x in range(GridSize.x):
			var topLeft = Vector2i(-1, -1)
			var topRight = Vector2i(-1, -1)
			var bottomLeft = Vector2i(-1, -1)
			var bottomRight = Vector2i(-1, -1)
			
			var tilePosition = Vector2i(x, y)
			var indexOfPosition : int = GetIndexFromPosition(tilePosition)
			
			# Top Left
			if tilePosition.x > 0 && tilePosition.y > 0:
				# Tile is not on top left or top edge - set Top Left
				var tlPosition = tilePosition
				var tlIndex : int = GetIndexFromPosition(tlPosition)
				topLeft = PaintedValues[tlIndex]
				
			# Bottom Left
			if tilePosition.x > 0 && tilePosition.y + 1 < GridSize.y:
				# Tile is not on top left or bottom edge - set Bottom Left
				var blPosition = Vector2i(tilePosition.x, tilePosition.y + 1)
				var blIndex : int = GetIndexFromPosition(blPosition)
				bottomLeft = PaintedValues[blIndex]
				
			# Top Right
			if tilePosition.x + 1 < GridSize.x && tilePosition.y > 0:
				# Tile is not on top right or top edge - set Top Right
				var trPosition = Vector2i(tilePosition.x + 1, tilePosition.y)
				var trIndex : int = GetIndexFromPosition(trPosition)
				topRight = PaintedValues[trIndex]
				
			# Bottom Right
			if tilePosition.x + 1 < GridSize.x && tilePosition.y + 1 < GridSize.y:
				# Tile is not on top right or bottom edge - set Bottom Right
				var brPosition = Vector2i(tilePosition.x + 1, tilePosition.y + 1)
				var brIndex : int = GetIndexFromPosition(brPosition)
				bottomRight = PaintedValues[brIndex]
				
			# Now values are gathered run the rule:
			var tlTile = VectorToTile(topLeft)
			var trTile = VectorToTile(topRight)
			var blTile = VectorToTile(bottomLeft)
			var brTile = VectorToTile(bottomRight)
			var result : Vector3i = RunRule(tlTile, trTile, blTile, brTile)
			
			var newTile = Vector2i(result.x, result.y)
			ViewedTiles[indexOfPosition].SetTile(newTile)
			
			var texture : Texture2D = GetTextureFromNumber(result.z)
			ViewedTiles[indexOfPosition].SetTexture(texture, Vector2i(4, 4))
	pass
	
func RunRule(
	tl: Tile, tr: Tile,
	bl: Tile, br: Tile
	) -> Vector3i:
	
	# Top Left, Top Right, Bottom Left, Bottom Right
	var points_dict = {
		# For reference these tiles have Border as the positive in the texture
		Vector4i(Tile.Nothing,Tile.Nothing,Tile.Nothing,Tile.Nothing): Vector3i(0, 3, 0),
		Vector4i(Tile.Border,Tile.Nothing,Tile.Nothing,Tile.Nothing): Vector3i(3, 3, 0),
		Vector4i(Tile.Border,Tile.Border,Tile.Nothing,Tile.Nothing): Vector3i(1, 2, 0),
		Vector4i(Tile.Border,Tile.Border,Tile.Border,Tile.Nothing): Vector3i(3, 1, 0),
		Vector4i(Tile.Border,Tile.Border,Tile.Border,Tile.Border): Vector3i(2, 1, 0),
		Vector4i(Tile.Nothing,Tile.Border,Tile.Nothing,Tile.Nothing): Vector3i(0, 2, 0),
		Vector4i(Tile.Nothing,Tile.Nothing,Tile.Border,Tile.Nothing): Vector3i(0, 0, 0),
		Vector4i(Tile.Nothing,Tile.Nothing,Tile.Nothing,Tile.Border): Vector3i(1, 3, 0),
		Vector4i(Tile.Border,Tile.Nothing,Tile.Nothing,Tile.Border): Vector3i(0, 1, 0),
		Vector4i(Tile.Border,Tile.Nothing,Tile.Border,Tile.Nothing): Vector3i(3, 2, 0),
		Vector4i(Tile.Border,Tile.Nothing,Tile.Border,Tile.Border): Vector3i(2, 0, 0),
		Vector4i(Tile.Nothing,Tile.Nothing,Tile.Border,Tile.Border): Vector3i(3, 0, 0),
		Vector4i(Tile.Nothing,Tile.Border,Tile.Border,Tile.Border): Vector3i(1, 1, 0),
		Vector4i(Tile.Nothing,Tile.Border,Tile.Border,Tile.Nothing): Vector3i(2, 3, 0),
		Vector4i(Tile.Nothing,Tile.Border,Tile.Nothing,Tile.Border): Vector3i(1, 0, 0),
		Vector4i(Tile.Border,Tile.Border,Tile.Nothing,Tile.Border): Vector3i(2, 2, 0),
		
		# Top Left, Top Right, Bottom Left, Bottom Right
		Vector4i(Tile.Barrier,Tile.Barrier,Tile.Barrier,Tile.Barrier): Vector3i(0, 3, 1),
		Vector4i(Tile.Border,Tile.Barrier,Tile.Barrier,Tile.Barrier): Vector3i(3, 3, 1),
		Vector4i(Tile.Border,Tile.Border,Tile.Barrier,Tile.Barrier): Vector3i(1, 2, 1),
		Vector4i(Tile.Border,Tile.Border,Tile.Border,Tile.Barrier): Vector3i(3, 1, 1),
		#Vector4i(Tile.Border,Tile.Border,Tile.Border,Tile.Border): Vector3i(2, 1, 0),
		Vector4i(Tile.Barrier,Tile.Border,Tile.Barrier,Tile.Barrier): Vector3i(0, 2, 1),
		Vector4i(Tile.Barrier,Tile.Barrier,Tile.Border,Tile.Barrier): Vector3i(0, 0, 1),
		Vector4i(Tile.Barrier,Tile.Barrier,Tile.Barrier,Tile.Border): Vector3i(1, 3, 1),
		Vector4i(Tile.Border,Tile.Barrier,Tile.Barrier,Tile.Border): Vector3i(0, 1, 1),
		Vector4i(Tile.Border,Tile.Barrier,Tile.Border,Tile.Barrier): Vector3i(3, 2, 1),
		Vector4i(Tile.Border,Tile.Barrier,Tile.Border,Tile.Border): Vector3i(2, 0, 1),
		Vector4i(Tile.Barrier,Tile.Barrier,Tile.Border,Tile.Border): Vector3i(3, 0, 1),
		Vector4i(Tile.Barrier,Tile.Border,Tile.Border,Tile.Border): Vector3i(1, 1, 1),
		Vector4i(Tile.Barrier,Tile.Border,Tile.Border,Tile.Barrier): Vector3i(2, 3, 1),
		Vector4i(Tile.Barrier,Tile.Border,Tile.Barrier,Tile.Border): Vector3i(1, 0, 1),
		Vector4i(Tile.Border,Tile.Border,Tile.Barrier,Tile.Border): Vector3i(2, 2, 1),
		
		# Top Left, Top Right, Bottom Left, Bottom Right
		Vector4i(Tile.Border,Tile.Nothing,Tile.Barrier,Tile.Nothing): Vector3i(3, 3, 2),
		Vector4i(Tile.Barrier,Tile.Nothing,Tile.Border,Tile.Nothing): Vector3i(0, 0, 2),
		Vector4i(Tile.Barrier,Tile.Nothing,Tile.Barrier,Tile.Nothing): Vector3i(3, 2, 2),
		
		Vector4i(Tile.Nothing,Tile.Border,Tile.Nothing,Tile.Barrier): Vector3i(0, 2, 2),
		Vector4i(Tile.Nothing,Tile.Barrier,Tile.Nothing,Tile.Border): Vector3i(1, 3, 2),
		Vector4i(Tile.Nothing,Tile.Barrier,Tile.Nothing,Tile.Barrier): Vector3i(1, 0, 2),
		
		Vector4i(Tile.Nothing,Tile.Nothing,Tile.Border,Tile.Barrier): Vector3i(0, 3, 2),
		Vector4i(Tile.Nothing,Tile.Nothing,Tile.Barrier,Tile.Border): Vector3i(0, 1, 2),
		Vector4i(Tile.Nothing,Tile.Nothing,Tile.Barrier,Tile.Barrier): Vector3i(3, 0, 2),
		
		Vector4i(Tile.Barrier,Tile.Border,Tile.Nothing,Tile.Nothing): Vector3i(1, 1, 2),
		Vector4i(Tile.Border,Tile.Barrier,Tile.Nothing,Tile.Nothing): Vector3i(2, 2, 2),
		Vector4i(Tile.Barrier,Tile.Barrier,Tile.Nothing,Tile.Nothing): Vector3i(1, 2, 2),
		
		Vector4i(Tile.Barrier,Tile.Nothing,Tile.Nothing,Tile.Nothing): Vector3i(3, 1, 2),
		Vector4i(Tile.Nothing,Tile.Barrier,Tile.Nothing,Tile.Nothing): Vector3i(2, 0, 2),
		Vector4i(Tile.Nothing,Tile.Nothing,Tile.Barrier,Tile.Nothing): Vector3i(2, 3, 2),
		Vector4i(Tile.Nothing,Tile.Nothing,Tile.Nothing,Tile.Barrier): Vector3i(2, 1, 2),
		}
	
	if points_dict.has(Vector4i(tl, tr, bl, br)):
		return points_dict.get(Vector4i(tl, tr, bl, br))
		
	return Vector3i(0, 3, 0)
	
func VectorToTile(textureLocation: Vector2i):
	if textureLocation.x == 0 && textureLocation.y == 0:
		return Tile.Nothing
	if textureLocation.x == 1 && textureLocation.y == 0:
		return Tile.Border
	if textureLocation.x == 2 && textureLocation.y == 0:
		return Tile.Barrier
	return Tile.Nothing
	
func GetTextureFromNumber(textureNumber: int):
	if textureNumber < 0:
		return PaintableTextures[0]
	if textureNumber > PaintableTextures.size() - 1:
		return PaintableTextures[0]
	
	return PaintableTextures[textureNumber]
