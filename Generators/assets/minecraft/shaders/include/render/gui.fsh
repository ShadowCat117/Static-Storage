#version 150
#define FRAGMENT_SHADER

#moj_import <define/transforms.glsl>

#moj_import <gui.glsl>
#moj_import <version.glsl>

in vec4 vertexColor;

out vec4 fragColor;

void main() {
    transform.color = vertexColor;

    if(transform.color.a == 0.0)
        discard;

    fragColor = transform.color * ColorModulator;
}