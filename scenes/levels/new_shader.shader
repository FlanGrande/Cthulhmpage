shader_type canvas_item;

void fragment()
{
	COLOR = vec4(0.7, 0.3, 0.1, 1.0);
	
	if(UV.x < 0.1 || UV.x > 0.9 || UV.y < 0.1 || UV.y > 0.9)
	{
		COLOR = vec4(vec3(1.0), 1.0);
	}
}