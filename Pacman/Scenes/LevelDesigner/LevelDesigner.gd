extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


## No longer required as sub scenes will be used, kept in this submit as it maybe used in next.
func SetDesignerTile(tile: Node, location: Vector2i):
	var DesignerTileScript = preload("res://Scenes/LevelDesigner/DesignerTile/DesignerTile.gd")
	if tile.get_script() == DesignerTileScript: 
		tile.SetTile(location)
	pass
