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

## Stores the selected values as what is painted does match what is seen
var PaintedValues = []

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
			PaintedValues.append(Vector2i(0, 0))
			
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
		
	RunAllRules()
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
			var top = Vector2i(-1, -1)
			var topRight = Vector2i(-1, -1)
			
			var left = Vector2i(-1, -1)
			var tile = Vector2i(-1, -1)
			var right = Vector2i(-1, -1)
			
			var bottomLeft = Vector2i(-1, -1)
			var bottom = Vector2i(-1, -1)
			var bottomRight = Vector2i(-1, -1)
			
			var tilePosition = Vector2i(x , y)
			var indexOfPosition : int = GetIndexFromPosition(tilePosition)
			tile = PaintedValues[indexOfPosition]
			
			# --- Left ---
			
			if x > 0 && y > 0:
				# Tile is not on top left or top edge - set Top Left
				var tlPosition = Vector2i(x - 1, y - 1)
				var tlIndex : int = GetIndexFromPosition(tlPosition)
				topLeft = PaintedValues[tlIndex]
					
			if x > 0:
				# Tile is not on top left edge - set Left
				var lPosition = Vector2i(x - 1, y)
				var lIndex : int = GetIndexFromPosition(lPosition)
				left = PaintedValues[lIndex]
				
			if x > 0 && y + 1 < GridSize.y:
				# Tile is not on top left or bottom edge - set Bottom Left
				var blPosition = Vector2i(x - 1, y + 1)
				var blIndex : int = GetIndexFromPosition(blPosition)
				bottomLeft = PaintedValues[blIndex]
				
			# --- Middle ---
				
			if y > 0:
				# Tile is not on top edge - set top
				var tPosition = Vector2i(x, y - 1)
				var tIndex : int = GetIndexFromPosition(tPosition)
				top = PaintedValues[tIndex]
				
			if y + 1 < GridSize.y:
				# Tile is not on bottom edge - set bottom
				var bPosition = Vector2i(x, y + 1)
				var bIndex : int = GetIndexFromPosition(bPosition)
				bottom = PaintedValues[bIndex]
				
			
			# --- Right ---
			
			if x + 1 < GridSize.x && y > 0:
				# Tile is not on top right or top edge - set Top Right
				var trPosition = Vector2i(x + 1, y - 1)
				var trIndex : int = GetIndexFromPosition(trPosition)
				topRight = PaintedValues[trIndex]
					
			if x + 1 < GridSize.x:
				# Tile is not on top right edge - set Right
				var rPosition = Vector2i(x + 1, y)
				var rIndex : int = GetIndexFromPosition(rPosition)
				right = PaintedValues[rIndex]
				
			if x + 1 < GridSize.x && y + 1 < GridSize.y:
				# Tile is not on top right or bottom edge - set Bottom Right
				var brPosition = Vector2i(x + 1, y + 1)
				var brIndex : int = GetIndexFromPosition(brPosition)
				bottomRight = PaintedValues[brIndex]
				
			# Now values are gathered run the rule:
			var result : Vector2i = RunRule(topLeft, top, topRight, left, tile, right, bottomLeft, bottom, bottomRight)
			SelectableTileCollection[indexOfPosition].SetTile(result)
	pass
				
	
func RunRule(
	tl: Vector2i, t: Vector2i, tr: Vector2i,
	l: Vector2i, tile: Vector2i, r: Vector2i,
	bl: Vector2i, b: Vector2i, br: Vector2i
	) -> Vector2i:
		
	if tile.x == 0 && tile.y == 0:	
		if l.x == -1 && l.y == -1:
			if t.x == -1 && t.y == -1:
				return Vector2i(0, 1)
			if b.x == -1 && b.y == -1:
				return Vector2i(0, 3)
			return Vector2i(0, 2)
			
		if r.x == -1 && r.y == -1:
			if t.x == -1 && t.y == -1:
				return Vector2i(2, 1)
			if b.x == -1 && b.y == -1:
				return Vector2i(2, 3)
			return Vector2i(2, 2)
			
		if b.x == -1 && b.y == -1:
			return Vector2i(1, 3)
			
		if t.x == -1 && t.y == -1:
			return Vector2i(1, 1)
			
		return Vector2i(1, 2)
	
	if tile.x == 1 && tile.y == 0:
		if t.x == -1 && t.y == -1:
			if l.x == -1 && l.y == -1:
				# In top left corner
				if r.x == 0 && r.y == 0 && b.x == 0 && b.y == 0:
					return Vector2i(5, 3)
				if b.x == 0 && b.y == 0:
					return Vector2i(3, 3)
				
			if r.x == -1 && r.y == -1:
				# In top right corner
				if b.x == 0 && b.y == 0 && l.x == 0 && l.y == 0:
					return Vector2i(6, 3)
				if b.x == 0 && b.y == 0:
					return Vector2i(4, 3)
			
			if l.x == 0 && l.y == 0 && r.x == 0 && r.y == 0:
				return Vector2i(3, 2)
			# Same to Right. Blank to Left
			if r.x == 1 && r.y == 0 && l.x == 0 && l.y == 0:
				return Vector2i(4, 2)
			# Same LR
			if r.x == 1 && r.y == 0 && l.x == 1 && l.y == 0:
				return Vector2i(5, 2)
			# Same to Left. Blank to Right
			if l.x == 1 && l.y == 0 && r.x == 0 && r.y == 0:
				return Vector2i(6, 2)
		
		# Default to black if we cannot figure it out
		return RunRule(tl, t, tr, l, Vector2i(0 , 0), r, bl, b, br)		
	
	# Literal default to black
	return Vector2i(0, 0)
