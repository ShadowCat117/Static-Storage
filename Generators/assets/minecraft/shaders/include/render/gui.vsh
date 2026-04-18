#version 150
#define VERTEX_SHADER

#moj_import <define/transforms.glsl>
#moj_import <define/projection.glsl>

#moj_import <config/toggle.glsl>

#moj_import <util.glsl>
#moj_import <gui.glsl>
#moj_import <version.glsl>

in vec3 Position;
in vec4 Color;

out vec4 vertexColor;

void main() {
    transform.color = Color;
    transform.position = Position;
    transform.projMat = ProjMat;

    gl_Position = ProjMat * ModelViewMat * vec4(transform.position, 1.0);

    disableBadges(2);
    disableTooltips();
    vertexColor = transform.color;
}