shader_type sky;
const float daylength = 1200.;

float skydist(vec2 a, vec2 b) {
	float lat1 = (a.y - 0.5) * PI;
	float lat2 = (b.y - 0.5) * PI;
	float lon1 = (a.x - 0.5) * TAU;
	float lon2 = (b.x - 0.5) * TAU;
	float hvs = pow(sin((lat2 - lat1) / 2.), 2.) + cos(lat1) * cos(lat2) * pow(sin((lon2 - lon1) / 2.), 2.);
	return atan(sqrt(hvs), sqrt(1. - hvs)) * 2.;
}

void sky() {
    if (!AT_CUBEMAP_PASS) {
		float angle = max(0., 1. - SKY_COORDS.y * 2.);
		float hour = mod(TIME / daylength, 1.);
		float brightness = (cos(hour * TAU) + 1.) / 2.;
		vec2 sun = vec2(hour, -cos(hour * TAU) * 0.25 + 0.5);
		float sundist = skydist(SKY_COORDS, sun);
		float blossoming = pow(sin(hour * TAU), 8.);
		float yfromsun = abs(SKY_COORDS.y - 0.5) * 8.;
		float xfromsun = (1. - abs(mod(SKY_COORDS.x - sun.x + 1., 1.) - 0.5)) * 1.5;
		vec3 blosscolor = vec3(1., 0.5, 0.75);
		vec3 color = vec3(0, (1. - angle) * brightness * 0.75, angle * 0.5 + brightness * (1. - angle * 0.5));
		color += (vec3(1.) - color) * (1. / (pow(sundist * 20., 4.) + 1.));
		COLOR.rgb = color;
    }
}
