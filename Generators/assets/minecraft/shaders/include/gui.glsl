#version 150
#if defined(RENDERTYPE_GUI) || defined(POSITION_COLOR)

#ifdef VERTEX_SHADER

struct Transform {
    vec4 color;
    vec3 position;
    mat4 projMat;
} transform;

void disableBadges(float x) {
    if(!DISABLE_BADGES_ENABLED)
        return;

    if (transform.position.x <= x) {
        switch (toInt(ivec3(transform.color.rgb*254.5))) {
            case 0xE6AF49:
            case 0x77B3E9:
            case 0xA0A0A0:
            case 0xE84F58:
            case 0xEAC864:
            case 0xCFCFCF:
                transform.color = vec4(0);
            break;
        }
    }
}

void disableTooltips() {
    if (isTooltip(transform.projMat, transform.position) && (gl_Position.x > 1 || gl_Position.x < -0.99)) {
       transform.color = vec4(0);
    }
}
#endif

#ifdef FRAGMENT_SHADER

struct Transform {
    vec4 color;
} transform;

#endif
#endif