#version 150
#define VERTEX_SHADER

#moj_import <define/pipelines.glsl>
#moj_import <define/transforms.glsl>
#moj_import <define/globals.glsl>
#moj_import <define/projection.glsl>
#moj_import <define/custom_fog.glsl>
#moj_import <define/sample_lightmap.glsl>

#moj_import <config/toggle.glsl>

#moj_import <util.glsl>
#moj_import <text.glsl>
#moj_import <data/texture.glsl>
#moj_import <movement.glsl>
#moj_import <effect.glsl>
#moj_import <transition.glsl>
#moj_import <version.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;

#if defined(MC_1_21_6) || defined(MC_1_21_9) || defined(MC_1_21_11) || defined(MC_26_1)
out float sphericalVertexDistance;
out float cylindricalVertexDistance;
#else
out float vertexDistance;
#endif

out vec4 vertexColor;
out vec2 texCoord0;

out float shadow;

out vec3 position;
flat out int vertexId;
flat out int transition;
out vec2 screen;

void main() {
	transform.color = Color;
	transform.textureColor = getVertexColor(Sampler0, gl_VertexID, UV0) * 255;
	transform.textureUV = UV0;
	transform.texture = round(texture(Sampler0, transform.textureUV) * 255);
	transform.screenSize = ScreenSize;
	transform.position = Position;
	transform.screenOffset = vec4(0);
	transform.initScreen = ProjMat * ModelViewMat * vec4(Position, 1.0);
	transform.gameTime = GameTime;

	transform.vertexId = gl_VertexID % 4;
	transform.screen = corners[transform.vertexId];
	transform.transition = 0;

	shadow = transform.color.r / 4 < 0.23 && transform.color.g / 4 < 0.23 && transform.color.b / 4 < 0.23 ? 1.0 : 0.0;
	transform.isShadow = shadow > 0.5;

	encode();
	hideScoreboardNumbers(vec3(0.94, -0.35, 2000), vec3(255, 85, 85), 4);
	applyMovements();
	applyEffects();
	applyTiles();
	applyAnchors();
	verticalSlide(vec4(43, 255, 0, 1), transform.color.a);

	gl_Position = (ProjMat * ModelViewMat * vec4(transform.position, 1.0)) + transform.screenOffset;

	initTransitions();
	transition = transform.transition;
	screen = transform.screen;
	texCoord0 = transform.textureUV;
	position = transform.position;
	vertexId = transform.vertexId;

#if defined(MC_1_21_6) || defined(MC_1_21_9) || defined(MC_1_21_11) || defined(MC_26_1)
	sphericalVertexDistance = fog_spherical_distance(transform.position);
	cylindricalVertexDistance = fog_cylindrical_distance(transform.position);
#else
	vertexDistance = fog_distance(transform.position, FogShape);
#endif

	#if defined(RENDERTYPE_TEXT_SEE_THROUGH)
	vertexColor = transform.color;
	#elif defined(RENDERTYPE_TEXT)

#if defined(MC_26_1)
	vertexColor = transform.color * sample_lightmap(Sampler2, UV2);
#else
	vertexColor = transform.color * texelFetch(Sampler2, UV2 / 16, 0);
#endif
	#endif
}