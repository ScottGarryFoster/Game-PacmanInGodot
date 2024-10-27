extends Area2D
var MouseClickReactionScript = preload("res://Scenes/UserInteraction/API/MouseClickReaction.gd")

## Occurs upon tile selection.
## func OnTileSelected(contextToUs: Vector2i, shaderTile: Vector2i):
signal TileSelected

## Given to us by whatever spawns up to give context when informing the outter world we were selected.
@export var CurrentLocationInOuterWorld : Vector2i

## True means upon the mouse rolling over change the tile
@export var ReactToMouseOver : bool

## If reacting to the Mouse. Use this tile for no mouse.
@export var TileWithNoMouse : Vector2i

## If reacting to the Mouse. Use this tile for the mouse.
@export var TileWithMouseOver : Vector2i

## When to send the Clickable signal.
@export var SignalOn : MouseClickReaction.Reaction

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
	
func DisableMouseInput():
	input_pickable = false
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

## Occurs when an input action happens on this scene. In this case Mouse Input.
func OnTextureRectGuiInput(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if SignalOn == MouseClickReaction.Reaction.MouseClick || SignalOn == MouseClickReaction.Reaction.MouseClickAndDown:
			TileSelected.emit(CurrentLocationInOuterWorld, ShaderOutputTile)
			
	pass # Replace with function body.

## Gets the size of the object.
func GetSize() -> Vector2:
	return $CollisionShape2D.transform.origin


func OnTextureRectMouseEntered() -> void:
	if ReactToMouseOver:
		SetTile(TileWithMouseOver)
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if SignalOn == MouseClickReaction.Reaction.MouseDown || SignalOn == MouseClickReaction.Reaction.MouseClickAndDown:
			TileSelected.emit(CurrentLocationInOuterWorld, ShaderOutputTile)
	pass # Replace with function body.


func OnTextureRectMouseExited() -> void:
	if ReactToMouseOver:
		SetTile(TileWithNoMouse)
	pass # Replace with function body.
	
func SetTileSelectedSignalTime(reaction: MouseClickReaction.Reaction):
	SignalOn = reaction
