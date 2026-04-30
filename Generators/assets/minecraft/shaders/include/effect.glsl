#version 150
#if defined(RENDERTYPE_TEXT) || defined(RENDERTYPE_TEXT_SEE_THROUGH) || defined(RENDERTYPE_ENTITY_TRANSLUCENT_CULL) || defined(RENDERTYPE_ITEM_ENTITY_TRANSLUCENT_CULL) || defined(ITEM)

#define EFFECT(r, g, b) break; case ((uint(r/4) << 16) | (uint(g/4) << 8) | (uint(b/4))):

const float TEXTURE_ATLAS = 256.0;

void overrideColor(vec3 color) {
    transform.color.rgb = color;
    overrideShadow(0.25);
}

void effectRainbow() {
    transform.color.rgb = hsvToRgb(vec3(0.005 * (transform.position.x + transform.position.y) - transform.gameTime * 300.0, 0.7, 1.0));
    overrideShadow(0.25);
}

void effectGradient(vec3 color1, vec3 color2, float time) {
    float rot = 0.08 * (transform.position.x + transform.position.y) - transform.gameTime * time * PI;
    float t = (sin(rot) + 1.0) * 0.5;

    transform.color.rgb = mix(color1, color2, t);
    overrideShadow(0.25);
}

void effectPulse(vec3 color1, vec3 color2) {
    transform.color.rgb = mix(color1, color2, sin(transform.gameTime * 800.0 * TAU) * 0.5 + 0.5);
    overrideShadow(0.25);
}

void effectFade(float speed) {
    transform.color.a = mix(transform.color.a, 0.0, sin(transform.gameTime * 1200 * speed * PI) * 0.5 + 0.5);
}

void effectFadeColor(vec3 color) {
    transform.color.rgb = color;
    transform.color.a = mix(transform.color.a, 0.0, sin(transform.gameTime * 1200 * PI) * 0.5 + 0.5);
    overrideShadow(0.25);
}

void effectFaded(vec3 color, float start, float end) {
    vec2 uv = transform.textureUV;
    vec2 glyphMin = vec2(floor(uv.x * TEXTURE_ATLAS) / TEXTURE_ATLAS, floor(uv.y * TEXTURE_ATLAS) / TEXTURE_ATLAS);
    vec2 glyphMax = vec2(ceil(uv.x * TEXTURE_ATLAS) / TEXTURE_ATLAS, ceil(uv.y * TEXTURE_ATLAS) / TEXTURE_ATLAS);

    float height = max(glyphMax.y - glyphMin.y, 0.0001);
    float y = clamp((uv.y - glyphMin.y) / height, start, end);
    float t = smoothstep(0.0, 1.0, y);

    transform.color = vec4(color, t);
    overrideShadow(0.25);
}

void effectBlink(float speed) {
    if(sin(transform.gameTime * 6400 * speed * PI) < 0.0) {
        transform.color.a = 0.0;
    }
}

void effectShine(vec3 color, vec3 highlight, float time, float width) {
    float shine = smoothstep(0.0, 1.0, sin((transform.position.x * 0.1) + transform.gameTime * time * TAU) + width);

    transform.color.rgb = mix(color, highlight, shine);
    overrideShadow(0.25);
}

void applyEffects() {
    if(!EFFECTS_ENABLED)
        return;

    uint vertexColorId = colorId(floor(round(transform.color.rgb * 255.0) / 4.0) / 255.0);
    #ifdef RENDERTYPE_TEXT
    if(transform.isShadow) {
        vertexColorId = colorId(transform.color.rgb);
    }
    #endif

    switch(vertexColorId >> 8) {
        case 0xFFFFFFFFu:
            #moj_import <config/effect.glsl>
    }
}
#endif