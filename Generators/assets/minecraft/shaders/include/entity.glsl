#version 150
#if defined(RENDERTYPE_ARMOR_CUTOUT_NO_CULL) || defined(ENTITY)

#ifdef VERTEX_SHADER

struct Transform {
    vec4 color;
    vec3 position;
    vec2 textureUV;
    float gameTime;
    vec4 fogColor;

    vec4 lightMapColor;

    int glint;
    int translucent;
    float nearFade;
} transform;
#endif

#ifdef FRAGMENT_SHADER

uniform sampler2D Sampler0;

struct Transform {
    vec4 color;
    vec3 position;
    vec4 vertexColor;
    vec4 textureColor;
    vec4 colorModulator;
    vec4 fogColor;
    float vertexDistance;
    float gameTime;
    bool gui;

    vec2 textureSize;
    vec2 textureUV;

    vec4 lightMapColor;

    int glint;
    int translucent;
    float nearFade;
} transform;

#endif
#endif
