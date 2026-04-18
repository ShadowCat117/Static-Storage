#version 150
#if defined(RENDERTYPE_TEXT) || defined(RENDERTYPE_TEXT_SEE_THROUGH) || defined(RENDERTYPE_ENTITY_TRANSLUCENT_CULL) || defined(RENDERTYPE_ITEM_ENTITY_TRANSLUCENT_CULL) || defined(ITEM)

bool isMovement(ivec3 color, int G, int B) {
    if(color.g == G && color.b == B) {
        return true;
    }

    if(color.g == (G >> 2) && color.b == (B >> 2)) {
        return true;
    }
    return false;
}

#define MOVEMENT(G, B) if (isMovement(color, G, B))

#define MOVEMENT_PROGRESS (color.r)
#define MOVEMENT_TIME (transform.gameTime * 12000)
#define COLOR vec3(1)

const vec2[] MOVEMENT_CORNERS = vec2[](vec2(0, 0), vec2(0, 1), vec2(1, 1), vec2(1, 0));
const int MOVEMENT_MARKER = 235;

void overrideShadow(float factor) {
    #ifdef IS_TEXT
    if(transform.isShadow) {
        transform.color.rgb *= factor;
    }
    #endif
}

float hash(float n) {
    return fract(sin(n) * 43758.5453);
}

vec2 pivot() {
    return MOVEMENT_CORNERS[transform.vertexId & 3] - 0.5;
}

float pixelY() {
    float y = (fract(transform.textureUV.y) - data.lower.y);

    return clamp(y, 0.0, 1.0);
}

void movementSlide(vec3 direction, float speed) {
    float time = MOVEMENT_TIME;
    transform.position += direction * sin(time) * speed;

    transform.color.rgb = COLOR;
    overrideShadow(0.25);
}

void movementOrbit(vec3 axisA, vec3 axisB, float radius, float speed) {
    float time = MOVEMENT_TIME;
    time *= speed;
    transform.position += (axisA * cos(time) + axisB * sin(time)) * radius;

    transform.color.rgb = COLOR;
    overrideShadow(0.25);
}

void movementBlink(float speed) {
    float time = MOVEMENT_TIME;

    transform.color.rgb = COLOR;
    overrideShadow(0.25);

    if(sin(time * speed * PI) < 0.0) {
        transform.color.a = 0.0;
    }
}

void movementShake(float strength, float time) {
    transform.position.xy += vec2(hash(time), hash(time + 1.0)) * strength / 255.0;

    transform.color.rgb = COLOR;
    overrideShadow(0.25);
}

float movementWarp(float amount, float direction) {
    float time = MOVEMENT_TIME;

    transform.color.rgb = COLOR;
    overrideShadow(0.25);

    return sin(time + direction * 0.05) * amount;
}

void movementStretch(float strength) {
    float time = MOVEMENT_TIME;
    float y = pixelY() * strength;
    y -= 1;

    if(transform.vertexId == 3 || transform.vertexId == 0) {
        transform.position.y -= cos(time) * y;
        transform.position.y += max(cos(time), 0.0) * y;
    }

    transform.color.rgb = COLOR;
    overrideShadow(0.25);
}

void movementVibrate(float strength, float time) {
    transform.position.xy += vec2(cos(time), sin(time)) * random(time) * strength / 255.0;

    transform.color.rgb = COLOR;
    overrideShadow(0.25);
}

void movementScale(float base, float amount, float speed) {
    float time = MOVEMENT_TIME;
    float scale = base + sin(time * speed) * amount;

    transform.position.xy += pivot() * scale;

    transform.color.rgb = COLOR;
    overrideShadow(0.25);
}

void movementScaleStatic(float base, float amount) {
    float scale = base * amount;

    transform.position.xy += pivot() * scale;

    transform.color.rgb = COLOR;
    overrideShadow(0.25);
}

void movementBump(float amount, float speed) {
    float time = MOVEMENT_TIME;
    float phase = time * speed + transform.position.x;

    transform.position.x += sin(phase) * amount;

    transform.color.rgb = COLOR;
    overrideShadow(0.25);
}

void movementItalic(float strength, float offset) {
    transform.position.x += pixelY() * strength + offset;

    transform.color.rgb = COLOR;
    overrideShadow(0.25);
}

void movementOffset(float direction, float amount) {
    float angle = direction * TAU;
    vec2 offset = vec2(cos(angle), sin(angle)) * amount;

    transform.position.xy += offset;
    transform.color.rgb = COLOR;

    #if defined(IS_TEXT)
    if(transform.isShadow) {
        transform.color = vec4(0);
    }
    #endif
}

void applyMovements() {
    if(!MOVEMENTS_ENABLED)
        return;

    #ifdef VERTEX_SHADER
    if(isGui(ProjMat))
        return;
    #endif

    ivec3 color = ivec3(floor(transform.color.rgb * 255.0 + 0.5));

    #if defined(IS_ITEM)
    if(color.g != MOVEMENT_MARKER && color.g / 4.0 != MOVEMENT_MARKER / 4.0)
        return;
    #endif

    #moj_import <config/movement.glsl>
}
#endif