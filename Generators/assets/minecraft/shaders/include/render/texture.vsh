#version 150
#define VERTEX_SHADER

#moj_import <define/transforms.glsl>
#moj_import <define/globals.glsl>
#moj_import <define/projection.glsl>

#moj_import <config/toggle.glsl>

#moj_import <util.glsl>
#moj_import <texture.glsl>
#moj_import <version.glsl>

in vec3 Position;
in vec2 UV0;
in vec4 Color;

out vec2 texCoord0;
out vec4 vertexColor;

void main() {
	texCoord0 = UV0;

	transform.position = Position;
	transform.vertexColor = Color;
	transform.textureUV = UV0;
	transform.gameTime = GameTime;
	transform.guiScale = getGuiScale(ProjMat, ScreenSize);
	transform.color = getVertexColor(Sampler0, gl_VertexID, texCoord0) * 255.0;
	transform.elementDepth = Position.z;

	applyTextureProperties();

	gl_Position = ProjMat * ModelViewMat * vec4(transform.position, 1.0);
	texCoord0 = transform.textureUV;

	vertexColor = transform.vertexColor;
}