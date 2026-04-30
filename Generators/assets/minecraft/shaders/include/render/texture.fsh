#version 150
#define FRAGMENT_SHADER

#moj_import <define/transforms.glsl>

#moj_import <util.glsl>
#moj_import <texture.glsl>
#moj_import <version.glsl>

in vec2 texCoord0;
in vec4 vertexColor;

out vec4 fragColor;

void main() {
    transform.textureUV = texCoord0;
    transform.colorMod = ColorModulator;

    transform.color = texture(Sampler0, texCoord0) * vertexColor;

    removePixel(ivec2(0, 0), ivec4(255, 0, 0, 255));
    removePixel(ivec2(0, 1), ivec4(255, 0, 0, 255));

    if(transform.color.a == 0.0 || transform.color.a == 1.0 / 255.0)
        discard;

    fragColor = transform.color * transform.colorMod;
}