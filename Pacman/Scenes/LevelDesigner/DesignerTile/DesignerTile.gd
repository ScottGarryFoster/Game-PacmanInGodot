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

## Occurs when an input action happens on this scene. In this case Mouse Input.
func OnTextureRectGuiInput(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		TileSelected.emit(CurrentLocationInOuterWorld, ShaderOutputTile)
	pass
