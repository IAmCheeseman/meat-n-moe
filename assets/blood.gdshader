shader_type canvas_item;

uniform float amount;
uniform sampler2D noise;

void fragment() {
	float a_1 = texture(noise, UV).r;
	float a_2 = texture(TEXTURE, UV).a;
	COLOR.a = mix(0.0, a_1, a_2 * (amount * 2.0));
}
