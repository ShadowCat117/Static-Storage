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
#moj_import <item.glsl>
#moj_import <data/texture.glsl>
#moj_import <movement.glsl>
#moj_import <effect.glsl>
#moj_import <glint.glsl>
#moj_import <translucency.glsl>
#moj_import <version.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

#if defined(MC_1_21_6) || defined(MC_1_21_9) || defined(MC_1_21_11) || defined(MC_26_1)
out float sphericalVertexDistance;
out float cylindricalVertexDistance;
#else
out float vertexDistance;
#endif

out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;

out vec4 lightMapColor;
out vec4 dyeColor;
out float depth;
out float gui;
flat out int vertexId;

out vec3 position;
flat out int glint;
flat out int translucent;

void main() {
    transform.color = Color;
    transform.position = Position;
    transform.gameTime = GameTime;
    transform.screenSize = ScreenSize;
    transform.textureUV = UV0 * 64;
    transform.vertexId = gl_VertexID % 4;
    transform.fogColor = FogColor;

    transform.glint = 0;
    transform.translucent = 0;

    #if defined(MC_26_1)
    transform.lightMapColor = sample_lightmap(Sampler2, UV2);
    #else
    transform.lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);
    #endif

    encode();
    applyEffects();
    applyMovements();
    initGlints();
    initTranslucency();
    anchorZ(551, 2201);

    gl_Position = ProjMat * ModelViewMat * vec4(transform.position, 1.0);

    lightMapColor = transform.lightMapColor;
    dyeColor = transform.color;
    depth = transform.position.z;
    glint = transform.glint;
    translucent = transform.translucent;
    position = transform.position;
    vertexId = transform.vertexId;
    gui = isGui(ProjMat) ? 1.0 : 0.0;

#if defined(MC_1_21_6) || defined(MC_1_21_9) || defined(MC_1_21_11) || defined(MC_26_1)
    sphericalVertexDistance = fog_spherical_distance(transform.position);
    cylindricalVertexDistance = fog_cylindrical_distance(transform.position);
#else
    vertexDistance = fog_distance((ModelViewMat * vec4(transform.position, 1)).xyz, FogShape);
#endif

    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, transform.color) * transform.lightMapColor;

    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
}
