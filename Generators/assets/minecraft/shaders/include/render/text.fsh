#version 150
#define FRAGMENT_SHADER

#moj_import <define/pipelines.glsl>
#moj_import <define/transforms.glsl>
#moj_import <define/globals.glsl>
#moj_import <define/custom_fog.glsl>

#moj_import <config/toggle.glsl>

#moj_import <util.glsl>
#moj_import <text.glsl>
#moj_import <data/texture.glsl>
#moj_import <movement.glsl>
#moj_import <effect.glsl>
#moj_import <transition.glsl>
#moj_import <version.glsl>

uniform sampler2D Sampler0;

#if defined(MC_1_21_6) || defined(MC_1_21_9) || defined(MC_1_21_11) || defined(MC_26_1)
in float sphericalVertexDistance;
in float cylindricalVertexDistance;
#else
in float vertexDistance;
#endif

in vec4 vertexColor;
in vec2 texCoord0;

in float shadow;

in vec3 position;
flat in int vertexId;
flat in int transition;
in vec2 screen;

out vec4 fragColor;

void main() {
    transform.vertexColor = vertexColor;
    transform.colorMod = ColorModulator;
    transform.position = position;
    transform.textureUV = texCoord0;
    transform.texColor = texture(Sampler0, transform.textureUV);
    transform.texAlpha = int(transform.texColor.a * 255 + 0.5);
    transform.color = transform.texColor * transform.vertexColor * transform.colorMod;
    transform.gameTime = GameTime;
    transform.screenSize = ScreenSize;
    transform.centerUV = gl_FragCoord.xy / transform.screenSize - 0.5;
    transform.aspectRatio = transform.screenSize.y / transform.screenSize.x;
    transform.isShadow = shadow > 0.5;

    transform.transition = transition;
    transform.vertexId = vertexId;
    transform.screen = screen;

    encode();
    applyMovements();
    applyTransitions();
    applyColorRestorations();
    alphaCutoff(1);
    disableShadow(254);

    #if defined(RENDERTYPE_TEXT_SEE_THROUGH)
    fragColor = transform.color * ColorModulator;
    #elif defined(RENDERTYPE_TEXT)

    #if defined(MC_1_21_6) || defined(MC_1_21_9) || defined(MC_1_21_11) || defined(MC_26_1)
    fragColor = apply_fog(transform.color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
    #else
    fragColor = linear_fog(transform.color, vertexDistance, FogStart, FogEnd, FogColor);
    #endif
    #endif
}