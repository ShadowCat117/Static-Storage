#define PI 3.14159265359
#define TAU (PI * 2)
#define LUMINANCE vec3(0.2126, 0.7152, 0.0722)

const vec2[] corners = vec2[4](vec2(0, 0), vec2(0, 1), vec2(1, 1), vec2(1, 0));

vec4 getVertexColor(sampler2D Sampler, int vertexID, vec2 coords) {
	ivec2 texSize = textureSize(Sampler, 0);
	vec2 offset = vec2(0.0);

	float pixelX = (1.0 / texSize.x) / 2.0;
	float pixelY = (1.0 / texSize.y) / 2.0;

	vertexID = vertexID % 4;
	switch(vertexID) {
		case 1:
			offset = vec2(-pixelX, pixelY);
			break;
		case 2:
			offset = vec2(pixelX, pixelY);
			break;
		case 3:
			offset = vec2(pixelX, -pixelY);
			break;
		case 0:
			offset = vec2(-pixelX, -pixelY);
			break;
		default:
			offset = vec2(0.0);
			break;
	}

	return texture(Sampler, coords - offset);
}

bool alpha(float textureAlpha, float targetAlpha) {
	float targetLess = targetAlpha - 0.01;
	float targetMore = targetAlpha + 0.01;
	return (textureAlpha > targetLess && textureAlpha < targetMore);
}

ivec4 getVertex(sampler2D Sampler0, int x, int y) {
	return ivec4(round(texelFetch(Sampler0, ivec2(x, y), 0) * 255));
}

int getGuiScale(mat4 ProjMat, vec2 ScreenSize) {
	return int(round(ScreenSize.x * ProjMat[0][0] / 2));
}

bool isGui(mat4 ProjMat) {
	return abs(ProjMat[2][3]) > 10e-6;
}

int toInt(ivec3 v) {
	return v.x << 16 | v.y << 8 | v.z;
}

bool isTooltip(mat4 ProjMat, vec3 Position) {
	return ProjMat[2][3] == 0 && Position.z > 300 && Position.z < 500;
}

uint colorId(vec3 col) {
	uint r = uint(round(col.r * 255.0));
	uint g = uint(round(col.g * 255.0));
	uint b = uint(round(col.b * 255.0));
	return ((uint(r) << 24) | (uint(g) << 16) | (uint(b) << 8) | 255u);
}

vec3 rgb(int r, int g, int b) {
	return vec3(r / 255.0, g / 255.0, b / 255.0);
}

vec3 hsvToRgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

int hash(int x) {
	x += (x << 10);
	x ^= (x >> 6);
	x += (x << 3);
	x ^= (x >> 11);
	x += (x << 15);
	return x;
}

vec3 rotateAxis(vec3 vector, vec3 axis, float angle) {
    return mix(dot(vector, axis) * axis, vector, cos(angle)) + cross(axis, vector) * sin(angle);
}


float random(float seed) {
	return fract(57128.836 * sin(dot(vec2(seed), vec2(12.77251, 72.37871))));
}

float noise(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 uv, float t1, float t2) {
	return fract(sin(uv.x * t1 + uv.y * t2) * 56789);
}

float smoothNoise(vec2 position) {
	vec2 i = floor(position);
	vec2 f = fract(position);

	float a = noise(i);
	float b = noise(i + vec2(1.0, 0.0));
	float c = noise(i + vec2(0.0, 1.0));
	float d = noise(i + vec2(1.0, 1.0));

	vec2 u = f * f * (3.0 - 2.0 * f);

	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 position) {
	float value = 0.0;
	float amplitude = 0.5;
	float frequency = 1.0;

	for(int i = 0; i < 5; i++) {
		value += amplitude * smoothNoise(position * frequency);
		frequency *= 2.0;
		amplitude *= 0.5;
	}
	return value;
}

float fbm(vec3 position) {
	return fbm(position.xy) + fbm(position.yz) + fbm(position.zx);
}

float crystalNoise(vec3 position, float time) {
    int iterations = 8;

    float start  = 2.20;
    float expand = 1.20;

    float edgeThickness = 0.25;
    
    vec3 axis1 = vec3(0.8506, 0.5257, 0.0000);
    vec3 axis2 = vec3(0.0000, 0.5257, 0.8506);
    float angle1 = PI /  7.0;
    float angle2 = PI / 27.0;
    float expand1 = 1.00;
    float expand2 = 1.25;

    float centralise = 0.5;
    float dampen     = 1.8;

    float noise = 0.0;
    float scale = start;

    vec3 travel1 = position;
    vec3 travel2 = abs(fract(position) - 0.5) * 0.15;

    for (int iteration = 0; iteration < iterations; iteration += 1) {

        travel1  = rotateAxis(travel1, axis1, angle1);
		travel1 *= expand1;

        vec3 point = cos(travel1 * scale + travel2 + time);

        noise += sin(TAU * dot(point, vec3(0.3))) * 0.5 + 0.5;

        scale *= expand;

        travel2 += cos(smoothstep(0.0, edgeThickness, point));
        travel2  = rotateAxis(travel2, axis2, angle2);
		travel2 *= expand2;
    }

    noise = noise / float(iterations);
    noise = noise * 2.0 - 1.0;
    noise = pow(abs(noise), centralise) * sign(noise);
    noise = noise * 0.5 + 0.5;
    noise = pow(noise, dampen);

    return noise;
}