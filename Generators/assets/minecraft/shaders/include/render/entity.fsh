#version 150
#define FRAGMENT_SHADER

#moj_import <define/pipelines.glsl>
#moj_import <define/transforms.glsl>
#moj_import <define/globals.glsl>
#moj_import <define/custom_fog.glsl>

#moj_import <config/toggle.glsl>

#moj_import <util.glsl>
#moj_import <entity.glsl>
#moj_import <glint.glsl>
#moj_import <translucency.glsl>
#moj_import <version.glsl>

#ifdef DISSOLVE
uniform sampler2D DissolveMaskSampler;
#endif

#if defined(MC_1_21_6) || defined(MC_1_21_9) || defined(MC_1_21_11) || defined(MC_26_1)
in float sphericalVertexDistance;
in float cylindricalVertexDistance;
#else
in float vertexDistance;
#endif

#ifdef PER_FACE_LIGHTING
in vec4 vertexPerFaceColor[2];
#else
in vec4 vertexColor;
#endif

in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec2 texCoord1;

in float gui;
in vec3 position;
flat in int glint;
flat in int translucent;
in float nearFade;

out vec4 fragColor;

void main() {
    transform.position = position;
    transform.fogColor = FogColor;

#ifdef PER_FACE_LIGHTING
    transform.vertexColor = vertexPerFaceColor[1];
#else
    transform.vertexColor = vertexColor;
#endif

#ifdef DISSOLVE
    if(transform.vertexColor.a < texture(DissolveMaskSampler, texCoord0).a) {
        discard;
    }

    transform.vertexColor.a = 1.0;
#endif

    transform.textureColor = texture(Sampler0, texCoord0);

#if defined(MC_1_21_6) || defined(MC_1_21_9) || defined(MC_1_21_11) || defined(MC_26_1)
    transform.vertexDistance = sphericalVertexDistance;
#else
    transform.vertexDistance = vertexDistance;
#endif

    transform.colorModulator = ColorModulator;
    transform.gameTime = GameTime;

    transform.textureSize = vec2(textureSize(Sampler0, 0));
    transform.textureUV = texCoord0 * transform.textureSize;

    transform.lightMapColor = lightMapColor;
    transform.glint = glint;
    transform.translucent = translucent;
    transform.nearFade = nearFade;
    transform.gui = gui < 0.5;

    if(transform.nearFade <= 0.01) {
        discard;
    }

    transform.color = texture(Sampler0, texCoord0);

#ifdef ALPHA_CUTOUT
    if(transform.color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif

#ifdef PER_FACE_LIGHTING
    transform.color *= vertexPerFaceColor[int(gl_FrontFacing)] * transform.colorModulator;
#else
    transform.color *= transform.vertexColor * transform.colorModulator;
#endif

#ifndef NO_OVERLAY
    transform.color.rgb = mix(overlayColor.rgb, transform.color.rgb, overlayColor.a);
#endif

#ifndef EMISSIVE
    transform.color *= transform.lightMapColor;
#endif

    applyGlints();
    applyTranslucency();

    transform.color *= transform.nearFade;

    if(transform.color.a < 0.1) {
        discard;
    }

#if defined(MC_1_21_6) || defined(MC_1_21_9) || defined(MC_1_21_11) || defined(MC_26_1)
    fragColor = apply_fog(transform.color, transform.vertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, transform.fogColor);
#else
    fragColor = linear_fog(transform.color, transform.vertexDistance, FogStart, FogEnd, transform.fogColor);
#endif
}
