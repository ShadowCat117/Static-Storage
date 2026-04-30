#version 150
#if defined(POSITION_TEX) || defined(POSITION_TEX_COLOR)

uniform sampler2D Sampler0;

#ifdef VERTEX_SHADER

struct Transform {
    vec4 color;
    vec4 vertexColor;
    float guiScale;
    float gameTime;
    float elementDepth;
    vec3 position;
    vec2 textureUV;
} transform;

void padding() {
    ivec4 check = getVertex(Sampler0, 0, 1);
    if(check != ivec4(255, 0, 0, 255)) {
        return;
    }
    ivec4 element = getVertex(Sampler0, 0, 0);
    if(element.a != 0 && element.a != 255) {
        transform.textureUV = corners[gl_VertexID % 4];
        transform.position.xy += (transform.textureUV - 0.5) * (ivec2(256) - element.ba);
        int frame = int(transform.gameTime * element.y * 1400.0) % element.x;
        ivec2 cells = textureSize(Sampler0, 0) / 256;
        transform.textureUV += ivec2(frame % cells.x, frame / cells.y);
        transform.textureUV /= cells;
    }
}

void applyTextureProperties() {
    if(!TEXTURE_PROPERTIES_ENABLED)
        return;

    padding();
}

#endif

#ifdef FRAGMENT_SHADER

struct Transform {
    vec4 color;
    vec4 colorMod;
    vec2 textureUV;
} transform;

void removePixel(ivec2 coordinate, ivec4 color) {
    ivec4 check = getVertex(Sampler0, 0, 1);
    if(ivec2(transform.textureUV * textureSize(Sampler0, 0)) == coordinate && check == color)
        discard;
}

#endif
#endif