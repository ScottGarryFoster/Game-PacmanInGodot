extends Node

## The tile upon the tileset to draw with.
## If set to -1, -1, then no tile has been selected yet.
var SelectedTile : Vector2i

# Script for Designer Tiles. Preloaded to ensure script methods can be called.
var DesignerTileScript = preload("res://Scenes/LevelDesigner/DesignerTile/DesignerTile.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if $TileChooser.has_signal("SelectedNewTile"):
		$TileChooser.connect("SelectedNewTile", Callable(self, "OnSelectedNewTile"))
	else:
		print("TileChooser did not have a SelectedNewTile signal. There is no call back.")
		
	if $LevelArea.has_signal("SelectedNewTile"):
		$LevelArea.connect("SelectedNewTile", Callable(self, "OnSelectedLevelArea"))
	else:
		print("LevelArea did not have a SelectedNewTile signal. There is no call back.")
	
	# Setup Selected Tile
	$SelectedTile.visible = false
	SelectedTile = Vector2i(-1, -1)
	$SelectedTile.SetTexture($TileChooser.ChooserTexture, $TileChooser.ChoserTextureColumnsAndRows)
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	return

## Updates the Selected Tile to the one from the Tile Chooser
func OnSelectedNewTile(tilePosition: Vector2i):
	$SelectedTile.SetTile(tilePosition)
	$SelectedTile.visible = true
	SelectedTile = tilePosition
	return

## Called when Level Area has been selected
func OnSelectedLevelArea(tilePosition: Vector2i):
	if SelectedTile.x == -1:
		return
	if SelectedTile.y == -1:
		return
		
	$LevelArea.SetTile(tilePosition, SelectedTile)
	return

## No longer required as sub scenes will be used, kept in this submit as it maybe used in next.
func SetDesignerTile(tile: Node, location: Vector2i):
	if tile.get_script() == DesignerTileScript: 
		tile.SetTile(location)
	else:
		push_error("SetDesignerTile: UI tile to use as the 'SelectedTile' is not a designer tile.")
	return
