#version 150

#moj_import <version.glsl>

#if defined(MC_1_21_6) || defined(MC_1_21_9)
layout(std140) uniform Globals {
    vec2 ScreenSize;
    float GlintAlpha;
    float GameTime;
    int MenuBlurRadius;
};
#elif defined(MC_1_21_11) || defined(MC_26_1)
layout(std140) uniform Globals {
    ivec3 CameraBlockPos;
    vec3 CameraOffset;
    vec2 ScreenSize;
    float GlintAlpha;
    float GameTime;
    int MenuBlurRadius;
    int UseRgss;
};
#else
uniform vec2 ScreenSize;
uniform float GlintAlpha;
uniform float GameTime;
#endif
