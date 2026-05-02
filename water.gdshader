shader_type spatial;
render_mode unshaded, cull_disabled;

float random(vec2 uv) {  // stolen
    return fract(sin(dot(uv.xy, vec2(12.9898,78.233))) * 43758.5453123);
}
void vertex() {
	VERTEX.y = sin(TIME * 3. + random(vec2(VERTEX.x * 0.002, VERTEX.z * 0.003)) * PI * 2.) * 0.4 - 0.5; //saklfjhaslds
}

void fragment() {
    ALBEDO = COLOR.rgb;
	ALPHA = COLOR.a;
}