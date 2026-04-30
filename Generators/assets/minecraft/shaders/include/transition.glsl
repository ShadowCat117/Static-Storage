#version 150
#if defined(RENDERTYPE_TEXT) || defined(RENDERTYPE_TEXT_SEE_THROUGH)

#ifdef VERTEX_SHADER

void initTransitions() {
    if(transform.texture.a == 253) {
        transform.transition = int(transform.texture.b);

        if(transform.transition != 0) {
            transform.textureUV = vec2(transform.textureUV - transform.screen / 255);
            gl_Position.xy = vec2(transform.screen * 2 - 1) * vec2(1, -1);
        }

        if(transform.isShadow) {
            transform.textureColor = vec4(0);
        }
    }
}

#endif

#ifdef FRAGMENT_SHADER

#if defined(MC_1_21_4) || defined(MC_1_21_5)
#define UV (transform.centerUV / vec2(transform.aspectRatio, 1) / 2)
#else
#define UV (transform.centerUV / vec2(transform.aspectRatio, 1))
#endif
#define PROGRESS (cos(transform.vertexColor.a * PI / 2))

void resetColor() {
    transform.color = vec4(0);
}

void transitionIris() {
    transform.color = vec4(transform.vertexColor.rgb, (length((gl_FragCoord.xy / transform.screenSize - 0.5) / vec2(transform.screenSize.y / transform.screenSize.x, 1)) + 0.1 - PROGRESS * 1.5) * (1 - PROGRESS) * 100);
}

void transitionBlink() {
    transform.color = vec4(transform.vertexColor.rgb, clamp(length(transform.centerUV * vec2(1, 2 / (1 - transform.vertexColor.a))) - 1, 0, 1));
}

void transitionSpeed(float speed, float radius, float count, float blur) {
    resetColor();
    float angle = (atan(transform.centerUV.y, transform.centerUV.x) / PI / 2 + 0.5) * count;
    float time = transform.gameTime * speed + hash(int(angle)) % 100 * 64.2343;
    float s = (abs(fract(angle) - 0.5) * 20 / count - 0.2) * length(transform.centerUV) + radius + (1 - transform.vertexColor.a) * 0.05 + abs(fract(time) - 0.5) * 0.25;

    if(s < 0) {
        transform.color = vec4(transform.vertexColor.rgb, clamp(-s * blur, 0, 1));
    }
}

void transitionDiamond() {
    vec2 grid = (ivec2(gl_FragCoord.xy / 64) * 64);
    vec2 inGrid = gl_FragCoord.xy - grid - 32;
    float size = grid.y / transform.screenSize.y;
    size = (size - transform.vertexColor.a * 2 + 1) * 64;

    transform.color = (abs(inGrid.x) + abs(inGrid.y) > size) ? vec4(transform.vertexColor.rgb, 1) : vec4(0);
}

void transitionNoise() {
    ivec2 grid = ivec2(gl_FragCoord.xy / 64) * 64;

    transform.color = abs(hash(grid.x ^ hash(grid.y)) % 0x100) < int(transform.vertexColor.a * (length(grid / transform.screenSize.xy - 0.5) * 2 + 1) * 0x100) ? vec4(transform.vertexColor.rgb, 1) : vec4(0);
}

void transitionPortal() {
    vec2 uv = (gl_FragCoord.xy / transform.screenSize.xy) * 2.0 - 1.0;
    vec2 uv_unscaled = gl_FragCoord.xy / transform.screenSize.xy;

    uv.x *= transform.screenSize.x / transform.screenSize.y;

    float progress = transform.vertexColor.a;
    float time = progress * 8.5;

    float r = length(uv);
    float theta = atan(uv.y, uv.x);

    float swirlStrength = mix(0.0, 4.0, progress);
    theta += swirlStrength * sin(r * 8.0 - time * 3.0) * (1.0 - progress);

    float maxRadius = length(vec2(transform.screenSize.x / transform.screenSize.y, 1.0));

    float transparentRadius = (1.0 - progress) * maxRadius;

    float alpha = smoothstep(transparentRadius - 0.25, transparentRadius, r);

    float swirl_color = sin(theta * 6.0 + time) * 0.5 + 0.5;
    vec3 portalColor = mix(vec3(189. / 255., 72. / 255., 232. / 255.), vec3(139. / 255., 25. / 255., 191. / 255.), swirl_color);

    vec4 color = vec4(portalColor, alpha);

    float fade = smoothstep(0.8, 1.0, progress);

    color = mix(color, vec4(170. / 255., 39. / 255., 207. / 255., 1.0), fade);
    transform.color = color;
}

void transitionLoad(float speed) {
    resetColor();
    float radius = length(UV);

    if(radius >= 0.07 && radius < 0.1 && transform.vertexColor.a >= 0.99) {
        float angle = fract(-atan(UV.y, UV.x) / TAU - transform.gameTime * speed);
        transform.color = vec4(transform.vertexColor.rgb, angle);
    }
}

void transitionVignette(float intensity) {
    vec2 coord = transform.centerUV * (transform.screenSize.x / transform.screenSize.y);
    float dist = length(coord);

    dist /= length(vec2(1.0, transform.screenSize.y / transform.screenSize.x));
    float vignette = smoothstep(0.0, 1.0, dist * intensity);

    transform.color = vec4(transform.vertexColor.rgb, vignette) * (1.0 - PROGRESS);
}

void transitionClose(float direction) {
    float s = 2 - abs(direction / (1 - PROGRESS) - 1);

    transform.color = vec4(transform.vertexColor.rgb, smoothstep(0, 0, s));
}

void transitionFade() {
    transform.color = vec4(transform.vertexColor.rgb, mix(0, 1, (1 - PROGRESS)));
}

void transitionLetterbox() {
    resetColor();
    float top = 2 - abs((transform.centerUV.y - 0.5) / (1 - PROGRESS));
    float bottom = 2 - abs((transform.centerUV.y + 0.5) / (1 - PROGRESS));

    if(UV.y > 1 - (1.2 * 0.5))
        transform.color = vec4(transform.vertexColor.rgb, smoothstep(0, 0, top));
    if(UV.y < (-0.8 * 0.5))
        transform.color = vec4(transform.vertexColor.rgb, smoothstep(0, 0, bottom));
}

void transitionWheel() {
    float circPos = atan(UV.y, UV.x) + PROGRESS * 2;
    float signed = sign(PROGRESS - mod(circPos, 3.14 / 4));

    transform.color = vec4(transform.vertexColor.rgb, step(signed, 0.5));
}

void transitionAngular(float startingAngle) {
    float os = startingAngle * PI / 180.0;
    float angle = atan(UV.y, UV.x) + os;
    float normal = (angle + PI) / (2.0 * PI);
    normal = normal - floor(normal);

    transform.color = vec4(transform.vertexColor.rgb, step(normal, (1 - PROGRESS)));
}

void transitionStatic() {
    float time = transform.gameTime * 2000;
    float t1 = time * 0.654321;
    float t2 = time * (t1 * 0.123456);

    vec3 st = vec3(noise(UV, t1, t2));

    transform.color = vec4(transform.vertexColor.rgb, st * (1 - PROGRESS));
}

void transitionVignetteFog(float intensity) {
    vec2 coord = transform.centerUV * (transform.screenSize.x / transform.screenSize.y);
    float dist = length(coord);
    float time = transform.gameTime * 4000;

    dist /= length(vec2(1.0, transform.screenSize.y / transform.screenSize.x));
    float vignette = smoothstep(0.0, 1.0, dist * intensity);
    float fbm = fbm(coord * 1.5 + vec2(time * 0.1, 0.0));
    vignette *= fbm;

    transform.color = vec4(transform.vertexColor.rgb, vignette) * (1.0 - PROGRESS);
}

void transitionFocus(float intensity) {
    vec2 coord = transform.centerUV * (transform.screenSize.x / transform.screenSize.y);
    float dist = length(coord);
    float time = transform.gameTime * 3000;
    float pulse = (transform.screenSize.x / transform.screenSize.y) + 0.1 * sin(time);

    dist /= length(vec2(1.0, transform.screenSize.y / transform.screenSize.x));
    float vignette = smoothstep(0.1, 1.0, dist * intensity * pulse);

    transform.color = vec4(transform.vertexColor.rgb, vignette) * (1.0 - PROGRESS);
}

#moj_import <config/transition.glsl>

#endif
#endif
