#version 150

#moj_import <version.glsl>

#if defined(MC_1_21_6) || defined(MC_1_21_9) || defined(MC_1_21_11) || defined(MC_26_1)
layout(std140) uniform Projection {
    mat4 ProjMat;
};
#else
uniform mat4 ProjMat;
#endif

vec4 projection_from_position(vec4 position) {
    vec4 projection = position * 0.5;
    projection.xy = vec2(projection.x + projection.w, projection.y + projection.w);
    projection.zw = position.zw;
    return projection;
}