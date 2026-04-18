#version 150
#define FRAGMENT_SHADER

#moj_import <define/pipelines.glsl>
#moj_import <define/transforms.glsl>
#moj_import <define/globals.glsl>
#moj_import <define/custom_fog.glsl>

#moj_import <config/toggle.glsl>

uniform sampler2D Sampler0;

#moj_import <util.glsl>
#moj_import <item.glsl>
#moj_import <data/texture.glsl>
#moj_import <movement.glsl>
#moj_import <effect.glsl>
#moj_import <glint.glsl>
#moj_import <translucency.glsl>
#moj_import <skybox.glsl>
#moj_import <version.glsl>

#if defined(MC_1_21_6) || defined(MC_1_21_9) || defined(MC_1_21_11) || defined(MC_26_1)
in float sphericalVertexDistance;
in float cylindricalVertexDistance;
#else
in float vertexDistance;
#endif

in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;

in vec4 lightMapColor;
in vec4 dyeColor;
in float depth;
in float gui;

in vec3 position;
flat in int vertexId;
flat in int glint;
flat in int translucent;

out vec4 fragColor;

void main() {
    transform.position = position;
    transform.vertexColor = vertexColor;
    transform.textureColor = texture(Sampler0, texCoord0);
    transform.vertexId = vertexId;
    transform.screenSize = ScreenSize;
    transform.fogColor = FogColor;
#if defined(MC_1_21_6) || defined(MC_1_21_9) || defined(MC_1_21_11) || defined(MC_26_1)
    transform.vertexDistance = sphericalVertexDistance;
#else
    transform.vertexDistance = vertexDistance;
#endif

    transform.colorModulator = ColorModulator;
    transform.gameTime = GameTime;

    transform.textureSize = vec2(textureSize(Sampler0, 0));
    transform.textureUV = texCoord0 * transform.textureSize;

    transform.emissive = sign(abs(transform.textureColor.a - EMISSIVE_ALPHA / 255.0));
    transform.shadeless = sign(abs(transform.textureColor.a - SHADELESS_ALPHA / 255.0));
    transform.lightMapColor = lightMapColor;
    transform.dyeColor = dyeColor;
    transform.depth = depth;
    transform.gui = gui < 0.5;

    transform.glint = glint;
    transform.translucent = translucent;

    transform.color = transform.textureColor * transform.vertexColor * transform.colorModulator;

    encode();
    applyMovements();
    applyGlints();
    applyTranslucency();
    applyTextureProperties();
    applySkyboxes();

    if(transform.color.a < 1 / 255.0)
        discard;

#if defined(MC_1_21_6) || defined(MC_1_21_9) || defined(MC_1_21_11) || defined(MC_26_1)
    fragColor = apply_fog(transform.color, transform.vertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, transform.fogColor);
#else
    fragColor = linear_fog(transform.color, transform.vertexDistance, FogStart, FogEnd, transform.fogColor);
#endif
}
