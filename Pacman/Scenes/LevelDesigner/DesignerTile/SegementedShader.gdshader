shader_type canvas_item;

/**
 * The number of tiles Horizontally to split the texture horizontally.
 */
uniform int tilesHorizontal : hint_range(1,128);

/**
 * The number of tiles Horizontally to split the texture vertically.
 */
uniform int tilesVertical : hint_range(1,128);

/**
 * The current tile to display.
 * 0, 0 will mean top left.
 */
uniform vec2 currentTile = vec2(0,0);

void fragment() 
{
	vec2 baseUV = (UV / vec2(float(tilesHorizontal),float(tilesVertical)));
	baseUV += currentTile/vec2(float(tilesHorizontal),float(tilesVertical));
	COLOR = texture(TEXTURE, baseUV);
}