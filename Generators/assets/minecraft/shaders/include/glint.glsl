#version 150
#if defined(RENDERTYPE_ENTITY_TRANSLUCENT_CULL) || defined(RENDERTYPE_ITEM_ENTITY_TRANSLUCENT_CULL) || defined(RENDERTYPE_ARMOR_CUTOUT_NO_CULL) || defined(ENTITY) || defined(ITEM)

#ifdef VERTEX_SHADER

void initGlints() {
    if(transform.color.gb != vec2(1, 0))
        return;

    if(transform.color.r < 1) {
        int y = int(round(transform.color.r * 255.0));

        // transform.vertexColor = mod(y, 2) == 1 ? vec4(1) : transform.vertexColor;
        // transform.lightMapColor = mod(y, 2) == 1 ? vec4(1) : transform.lightMapColor;
        transform.color = vec4(1);
        #if defined(IS_ITEM)
        transform.dyeColor = vec4(1);
        #endif

        transform.glint = y;
    }
}

#endif

#ifdef FRAGMENT_SHADER

#define TIME (transform.gameTime * 300)
#define SCALE 64

#define DIMENSIONS transform.textureSize
#define UV (transform.textureUV / transform.textureSize)
#define TEXTURE texture(Sampler0, UV)

#if defined(IS_ITEM)
#define EFFECT_UV (transform.textureUV.xy - 1 * transform.textureSize.xy) / transform.textureSize.y * SCALE
#elif defined(IS_ENTITY)
#define EFFECT_UV (transform.textureUV.xy - 1 * transform.textureSize.xy) / transform.textureSize.y
#endif

void applyLighting() {
    transform.color *= transform.lightMapColor;
}

void applyShading() {
    transform.color *= transform.vertexColor * transform.colorModulator;
}

void clearFog() {
    transform.fogColor = vec4(0);
}

vec2 rotate(vec2 coord, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    mat2 m = mat2(c, -s, s, c);
    return m * coord;
}

vec3 fetchAtlas(vec2 coords) {
    return texture(Sampler0, (mod(transform.textureUV, 16) + coords) / transform.textureSize).rgb;
}

vec3 atlas(vec2 coords, float length, float scale, float angle, float speed, float offset) {
    return texture(Sampler0, (mod(rotate(transform.textureUV, angle) * scale + vec2(offset, TIME * speed), length) + coords) / transform.textureSize).rgb;
}

vec3 blend(vec4 a, vec4 b, float amt) {
    return mix(a, b, amt).rgb;
}

float smoothen(float distA, float distB, float amt) {
    float blend = clamp(0.5 + 0.5 * (distB - distA) / amt, 0.0, 0.5);
    return mix(distB, distA, blend) - amt * blend * (1.0 - blend);
}

float flipbook(float frameCount, float speed) {
    return mod(floor(TIME * speed), frameCount) * 16;
}

float palette(float colorCount, float colorFactor) {
    return round(colorFactor * transform.color.r * colorCount);
}

vec4 grayscale(vec4 color) {
    float brightness = dot(color.rgb, LUMINANCE);
    color.rgb = vec3(brightness);

    return color;
}

vec3 aberration(vec2 uv, float factor) {
    vec4 color = TEXTURE;

    color.x = texture(Sampler0, vec2(uv.x + sin(TIME * 500) * factor, uv.y)).x;
    color.y = texture(Sampler0, vec2(uv.x + cos(TIME * 500) * factor, uv.y)).y;
    color.z = texture(Sampler0, uv).z;

    return blend(TEXTURE, color, color.a);
}

vec3 tint(vec3 texture, vec3 tint, float contrast) {
    float brightness = pow(dot(texture, LUMINANCE), 0.7);
    vec3 color = tint * brightness;
    color = mix(color, vec3(1.0), smoothstep(0.7, 1, brightness) * contrast);

    return mix(texture, color, 1);
}

void glintGrayscale() {
    transform.color = grayscale(TEXTURE);
}

void glintShinyAtlas() {
#if defined(IS_ITEM)
    transform.color.rgb = texture(Sampler0, vec2(palette(16, 0.8), 32) / transform.textureSize).rgb;
#elif defined(IS_ENTITY)
    transform.color.rgb = tint(TEXTURE.rgb, vec3(0.95, 0.8, 0.15), 0.6);
#endif
}

void glintShinyTint() {
    glintGrayscale();
    transform.color.rgb = tint(transform.color.rgb, vec3(0.95, 0.8, 0.15), 0.6);
}

void glintShiny(vec3 color, float intensity, float brightness) {
    #if defined(IS_ENTITY)
    vec2 uv = UV * 4;
    #elif defined(IS_ITEM)
    vec2 uv = EFFECT_UV;
    #endif

    float time = TIME / 2;
    float angle = time + uv.y;

    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    vec2 warp = (uv - 0.5) * rot * 0.2;

    float t = length(uv + vec2(sin(time), sin(time))) - time;
    warp += vec2(cos(t - uv.x) + sin(t + uv.y), sin(t - uv.y) + cos(t + uv.x));

    float mask = length(vec2(sin(warp.x + t) / 2.0, cos(warp.y + t) / 2.0));
    mask = smoothstep(0.6, 0.2, mask) * intensity;

    transform.color.rgb = TEXTURE.rgb + color * mask * brightness;

    #if defined(IS_ITEM)
    applyShading();
    #endif
}

void glintRainbow() {
    glintGrayscale();
    if(transform.gui) {
        transform.color.rgb = transform.color.rgb * hsvToRgb(vec3(0.005 * (transform.position.x + transform.position.y) - TIME, 0.7, 1.0));
    } else {
        transform.color.rgb = transform.color.rgb * hsvToRgb(vec3(0.05 * (transform.position.x + transform.position.y) - TIME, 0.7, 1.0));

    }
}

void glintClear() {
    transform.lightMapColor.a = 0.5;
}

void glintGlitch() {
    #if defined(IS_ITEM)
    float intensity = 0.00015;
    float colorOffset = 0.0001;
    #elif defined(IS_ENTITY)
    float intensity = 0.015;
    float colorOffset = 0.995;
    #endif

    float size = random(TIME);
    float speed = 10;
    float rate = 0.5;

    float time = float(random(floor(TIME * speed)) < rate);
    float offset = (random(floor(UV.y * size) + TIME) - 0.5) * intensity * time;
    vec2 fixed_uv = offset + UV;

    vec4 color = texture(Sampler0, fixed_uv);

    color.r = mix(color.r, texture(Sampler0, fixed_uv + vec2(colorOffset, 0.0)).r, time);
    color.b = mix(color.b, texture(Sampler0, fixed_uv - vec2(colorOffset, 0.0)).b, time);

    transform.color.rgb = blend(TEXTURE, color, color.a);

    #if defined(IS_ITEM)
    applyShading();
    #endif
}

void glintRipple() {
    vec2 uv = EFFECT_UV * 2;

    mat3 m = mat3(-2, -1, 2, 3, -2, 1, 1, 2, 2);
    vec3 a = vec3(uv, TIME * 0.5) * m;
    vec3 b = a * m * 0.4;
    vec3 c = b * m * 0.3;

    transform.color.rgb = TEXTURE.rgb + vec4(pow(min(min(length(0.5 - fract(a)), length(0.5 - fract(b))), length(0.5 - fract(c))), 7) * 30).rgb;
}

void glintVibrate() {
    #if defined(IS_ITEM)
    transform.color.rgb = aberration(UV, 0.000025);
    #elif defined(IS_ENTITY)
    transform.color.rgb = aberration(UV, 0.0025);
    #endif
}

void glintInvert() {
    vec4 texture = TEXTURE;
    texture.rgb = vec3(1.0) - texture.rgb;

    transform.color.rgb = texture.rgb;

    #if defined(IS_ITEM)
    applyShading();
    #endif
}

void glintTint(vec3 color, float blend) {
    glintGrayscale();
    transform.color.rgb = tint(transform.color.rgb, color, blend);

    #if defined(IS_ITEM)
    applyShading();
    #endif
}

void glintShadow() {
    float speed = 1.0;
    float length = 5.0;

    vec2 uv = EFFECT_UV;

    vec2 xy = vec2(1, -0.2) * 0.3;
    uv = xy * uv;

    float x = uv.x + uv.y - speed * TIME;
    float shine = x - floor(x);
    shine = 1 - pow(shine, length);

    transform.color.rgb = TEXTURE.rgb * vec3(shine, shine, shine);

    #if defined(IS_ITEM)
    applyShading();
    #endif
}

void glintAurora() {
    #if defined(IS_ENTITY)
    vec2 uv = EFFECT_UV;
    #elif defined(IS_ITEM)
    vec2 uv = EFFECT_UV / 2;
    #endif

    float radius = length(uv);
    vec2 pattern = sin(uv * radius);

    pattern = rotate(pattern, -cos(radius * 5.0 + TIME * 10));
    float dist = length(exp(-pattern * pattern));

    dist = smoothen(length(pattern), dist, 0.9);

    vec4 color = sin(dist * vec4(4, 3, 2, 1)) * 0.5 + 0.5;

    transform.color.rgb = blend(TEXTURE, color, 0.5);
}

void glintReflection() {
    #if defined(IS_ENTITY)
    vec2 uv = EFFECT_UV / 8;
    #elif defined(IS_ITEM)
    vec2 uv = EFFECT_UV;
    #endif

    float intensity = 0.4;
    float speed = 1;
    float smoothness = 0.7;

    float band = sin((uv.x + uv.y + TIME * speed) * 10.0) * 0.5 + 0.5;
    float reflect = smoothstep(smoothness, 1.0, band);

    transform.color.rgb = TEXTURE.rgb + vec3(reflect * intensity);
}

void glintPlasma() {
    #if defined(IS_ENTITY)
    vec2 uv = EFFECT_UV * 4;
    #elif defined(IS_ITEM)
    vec2 uv = EFFECT_UV * 16;
    #endif

    float time = TIME * 2;

    float offset = 0.1 + cos(uv.y + sin(0.15 - time)) + 1 * time;
    float distort = 0.9 + sin(uv.x + cos(0.65 + time)) - 1 * time;
    float dist = length(uv);
    float pattern = 8 * cos(dist + distort) * sin(offset - distort);

    transform.color.rgb = blend(TEXTURE, -sin(pattern + vec4(0.5, 0.7, 0.8, 1.0)), 0.1);
}

void glintDistort() {
    vec2 uv = UV;

    #if defined(IS_ENTITY)
    float strength = 0.1 * sin(10.0) / 2;
    vec2 distort = uv * 10.0 + TIME * 2;
    #elif defined(IS_ITEM)
    float strength = 0.01 * sin(0.05) / 2;
    vec2 distort = uv * 1000.0 + TIME * 4;
    #endif

    float n = smoothNoise(distort);
    vec2 offset = vec2(n - 0.5, n - 0.5) * strength;

    vec2 distortUV = uv + offset;
    vec4 color = texture(Sampler0, distortUV);

    transform.color.rgb = blend(TEXTURE, color, color.a);

    #if defined(IS_ITEM)
    applyShading();
    #endif
}

void glintChrome() {
    vec2 uv = EFFECT_UV;
    float time = TIME * 4;

    vec4 color = vec4(0.5 + 0.5 * sin(10.0 * uv.x + time), 0.5 + 0.5 * sin(10.0 * uv.y + time + 1.0), 0.5 + 0.5 * sin(10.0 * (uv.x + uv.y) + time + 2.0), 1);
    color = pow(color, vec4(2.0));

    transform.color.rgb = blend(TEXTURE, color, 0.3);
}

void glintRunic() {
    vec3 color = atlas(vec2(0, 48), 16, 2, 0, 10, -TIME) +
        atlas(vec2(16, 48), 16, 2, 0, 8, TIME) +
        atlas(vec2(32, 48), 16, 2, 0, 5, -TIME) +
        atlas(vec2(48, 48), 16, 2, 0, 2, TIME) +
        atlas(vec2(64, 48), 16, 2, 0, 0, -TIME);

    transform.color.rgb = TEXTURE.rgb + color * 0.2;
}

void glintFlipbook() {
    transform.color.rgb = TEXTURE.rgb * fetchAtlas(vec2(flipbook(4, 4), 16));
}

#moj_import <config/glint.glsl>

#endif
#endif