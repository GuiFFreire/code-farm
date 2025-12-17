shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.5) = 1.5;
uniform vec2 center = vec2(0.5, 0.5);
uniform float smoothness : hint_range(0.0, 0.2) = 0.05;

void fragment() {
	vec2 aspect = vec2(SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x, 1.0);
	vec2 adjusted_uv = (UV - center) * aspect;
	float dist = length(adjusted_uv);

	float edge = smoothstep(radius - smoothness, radius, dist);

	COLOR = vec4(0.0, 0.0, 0.0, edge);
}
