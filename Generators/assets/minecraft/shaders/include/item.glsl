#version 150
#if defined(RENDERTYPE_ENTITY_TRANSLUCENT_CULL) || defined(RENDERTYPE_ITEM_ENTITY_TRANSLUCENT_CULL) || defined(ITEM)

#ifdef VERTEX_SHADER

struct Transform {
    vec4 color;
    vec3 position;
    float gameTime;
    vec2 screenSize;
    vec2 textureUV;
    vec4 fogColor;

    vec4 lightMapColor;
    vec4 dyeColor;

    int glint;
    int translucent;
    int vertexId;
} transform;

void anchorZ(float depth, float target) {
    if(transform.position.z != depth) {
        return;
    }

    transform.position.z = target;
}
#endif

#ifdef FRAGMENT_SHADER

const float SHADELESS_ALPHA = 251.0;
const float INTERFACE_ALPHA = 252.0;
const float WORLD_ALPHA = 253.0;
const float EMISSIVE_ALPHA = 254.0;

struct Transform {
    vec4 color;
    vec3 position;
    vec4 vertexColor;
    vec4 textureColor;
    vec4 colorModulator;
    vec4 fogColor;
    float vertexDistance;
    float gameTime;

    vec2 textureSize;
    vec2 textureUV;
    vec2 screenSize;

    float emissive;
    float shadeless;
    vec4 lightMapColor;
    vec4 dyeColor;
    float depth;
    bool gui;

    int glint;
    int translucent;
    int vertexId;
} transform;

void emissive() {
    if(transform.emissive == 1)
        return;

    transform.color = mix(transform.color, transform.textureColor * transform.dyeColor, transform.textureColor.a * transform.color.a);
}

void shadeless() {
    if(transform.shadeless == 1)
        return;

    transform.color = mix(transform.color, transform.textureColor * transform.dyeColor * transform.lightMapColor * transform.colorModulator, transform.textureColor.a * transform.color.a);
}

void perspective(float worldAlpha, float interfaceAlpha, float depth, int dist) {
    float textureAlpha = transform.textureColor.a * 255;

    if(alpha(textureAlpha, worldAlpha) && transform.vertexDistance < dist)
        discard;

    if(transform.vertexDistance >= dist) {
        if(alpha(textureAlpha, worldAlpha) && transform.depth < depth)
            discard;
        else if(alpha(textureAlpha, interfaceAlpha) && transform.depth >= depth)
            discard;
    }
}

void applyTextureProperties() {
    if(!TEXTURE_PROPERTIES_ENABLED)
        return;

    #if defined(MC_1_21_4) || defined(MC_1_21_5)
    perspective(WORLD_ALPHA, INTERFACE_ALPHA, -800.0, 800);
    #else
    perspective(WORLD_ALPHA, INTERFACE_ALPHA, -800.0, 5);
    #endif

    emissive();
    shadeless();
}

#endif
#endif