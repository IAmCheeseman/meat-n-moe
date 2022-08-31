shader_type canvas_item;

uniform float amp = 0.5;

void fragment() {
	float x = sin(PI * UV.x);
	float y = sin(PI * UV.y);
	
	float a = (1.0 - (x * y)) * amp;
	COLOR = vec4(1.0, 0, 0, a);
}
