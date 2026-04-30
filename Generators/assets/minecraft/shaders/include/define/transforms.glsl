#version 150

#moj_import <version.glsl>

#if defined(MC_1_21_6) || defined(MC_1_21_9)
layout(std140) uniform DynamicTransforms {
    mat4 ModelViewMat;
    vec4 ColorModulator;
    vec3 ModelOffset;
    mat4 TextureMat;
    float LineWidth;
};
#elif defined(MC_1_21_11) || defined(MC_26_1)
layout(std140) uniform DynamicTransforms {
    mat4 ModelViewMat;
    vec4 ColorModulator;
    vec3 ModelOffset;
    mat4 TextureMat;
};
#else
uniform mat4 ModelViewMat;
uniform vec4 ColorModulator;
uniform mat4 TextureMat;
#endif