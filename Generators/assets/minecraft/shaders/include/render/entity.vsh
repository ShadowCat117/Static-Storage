#version 150
#define VERTEX_SHADER

#moj_import <define/pipelines.glsl>
#moj_import <define/transforms.glsl>
#moj_import <define/globals.glsl>
#moj_import <define/projection.glsl>
#moj_import <define/custom_light.glsl>
#moj_import <define/custom_fog.glsl>
#moj_import <define/sample_lightmap.glsl>

#moj_import <config/toggle.glsl>

#moj_import <util.glsl>
#moj_import <entity.glsl>
#moj_import <glint.glsl>
#moj_import <translucency.glsl>
#moj_import <player.glsl>
#moj_import <version.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler1;
uniform sampler2D Sampler2;

#if defined(MC_1_21_6) || defined(MC_1_21_9) || defined(MC_1_21_11) || defined(MC_26_1)
out float sphericalVertexDistance;
out float cylindricalVertexDistance;
#else
out float vertexDistance;
#endif

#ifdef PER_FACE_LIGHTING
out vec4 vertexPerFaceColor[2];
#else
out vec4 vertexColor;
#endif

out vec4 lightMapColor;
out vec4 overlayColor;
out vec2 texCoord0;
out vec2 texCoord1;

out float gui;
out vec3 position;
flat out int glint;
flat out int translucent;
out float nearFade;

void main() {
    transform.color = Color;
    transform.position = Position;
    transform.textureUV = UV0;
    transform.fogColor = FogColor;
    transform.gameTime = GameTime;

    #if defined(MC_26_1)
    transform.lightMapColor = sample_lightmap(Sampler2, UV2);
    #else
    transform.lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);
    #endif
    transform.glint = 0;
    transform.translucent = 0;
    transform.nearFade = 1.0;

    initGlints();
    initTranslucency();
    applyPlayer();

    gl_Position = ProjMat * ModelViewMat * vec4(transform.position, 1.0);

#if defined(MC_1_21_6) || defined(MC_1_21_9) || defined(MC_1_21_11) || defined(MC_26_1)
    sphericalVertexDistance = fog_spherical_distance(transform.position);
    cylindricalVertexDistance = fog_cylindrical_distance(transform.position);
#else
    vertexDistance = fog_distance(transform.position, FogShape);
#endif

#ifdef PER_FACE_LIGHTING
    vec2 light = minecraft_compute_light(Light0_Direction, Light1_Direction, Normal);
    vertexPerFaceColor[0] = minecraft_mix_light_separate(-light, transform.color);
    vertexPerFaceColor[1] = minecraft_mix_light_separate(light, transform.color);
#elif defined(NO_CARDINAL_LIGHTING)
    vertexColor = transform.color;
#else
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, transform.color);
#endif

#ifndef EMISSIVE
    lightMapColor = transform.lightMapColor;
#endif
    overlayColor = texelFetch(Sampler1, UV1, 0);

    texCoord0 = transform.textureUV;
#ifdef APPLY_TEXTURE_MATRIX
    texCoord0 = (TextureMat * vec4(transform.textureUV, 0.0, 1.0)).xy;
#endif

    lightMapColor = transform.lightMapColor;
    glint = transform.glint;
    translucent = transform.translucent;
    nearFade = transform.nearFade;
    position = transform.position;
    gui = isGui(ProjMat) ? 1.0 : 0.0;
}
