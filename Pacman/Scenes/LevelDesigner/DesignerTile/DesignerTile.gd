extends Area2D

## Occurs upon tile selection.
## func OnTileSelected(contextToUs: Vector2i, shaderTile: Vector2i):
signal TileSelected

## Given to us by whatever spawns up to give context when informing the outter world we were selected.
@export var CurrentLocationInOuterWorld : Vector2i

## The current tile displayed
var ShaderOutputTile : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Sets a tile to given position.
func SetTile(position: Vector2i):
	ShaderOutputTile = position
	$TextureRect.material.set_shader_parameter("currentTile", Vector2(ShaderOutputTile.x, ShaderOutputTile.y))
	pass

## Updates the texture on the tile.
func SetTexture(newTexture: Texture2D, textureTiles: Vector2i = Vector2i(-1, -1)):
	if newTexture == null:
		push_error("Texture was null when setting within DesignerTile")
		return
		
	$TextureRect.texture = newTexture
	
	if(textureTiles.x > 0):
		$TextureRect.material.set_shader_parameter("tilesHorizontal", textureTiles.x)
	
	if(textureTiles.y > 0):
		$TextureRect.material.set_shader_parameter("tilesVertical", textureTiles.y)
	pass

## Gets the size of the object.
func GetSize() -> Vector2:
	return $CollisionShape2D.transform.origin
