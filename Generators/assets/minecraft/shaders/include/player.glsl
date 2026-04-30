#version 150
#if defined(ENTITY) || defined(RENDERTYPE_ENTITY_TRANSLUCENT)

#ifdef VERTEX_SHADER

const int Y_POSITION_RADIX = 512;
const int STEVE_ALEX_RADIX = 2;
const int LIMB_FADE_RADIX = 3;
const int LIMB_INDEX_RADIX = 6;

const float SKIN_TEXTURE_SIZE = 64.0;
const float SKIN_TEXTURE_SIZE_INV = 1.0 / SKIN_TEXTURE_SIZE;

const float SOFT_FADE_START_SQ = 0.5;
const float SOFT_FADE_END_SQ = 1.0;

const float HARD_FADE_SQ = 6.0;

struct LimbUv {
    vec2 faceSizes[6];
    vec2 faceOrigins[6];
    vec2 overlayOffset;
};

const LimbUv LIMB_UVS[8] = LimbUv[](
    LimbUv( // Head
        vec2[](
            vec2(8.0, 8.0), vec2(8.0, 8.0), vec2(8.0, 8.0),
            vec2(8.0, 8.0), vec2(8.0, 8.0), vec2(8.0, 8.0)
        ),
        vec2[](
            vec2(16.0, 0.0), vec2(24.0, 8.0), vec2(8.0, 8.0),
            vec2(16.0, 8.0), vec2(24.0, 8.0), vec2(32.0, 8.0)
        ),
        vec2(32.0, 0.0)
    ),
    LimbUv( // Body
        vec2[](
            vec2(8.0, 4.0), vec2(8.0, 4.0), vec2(4.0, 12.0),
            vec2(8.0, 12.0), vec2(4.0, 12.0), vec2(8.0, 12.0)
        ),
        vec2[](
            vec2(28.0, 16.0), vec2(36.0, 20.0), vec2(20.0, 20.0),
            vec2(28.0, 20.0), vec2(32.0, 20.0), vec2(40.0, 20.0)
        ),
        vec2(0.0, 16.0)
    ),
    LimbUv( // Left Arm (Steve)
        vec2[](
            vec2(4.0, 4.0), vec2(4.0, 4.0), vec2(4.0, 12.0),
            vec2(4.0, 12.0), vec2(4.0, 12.0), vec2(4.0, 12.0)
        ),
        vec2[](
            vec2(40.0, 48.0), vec2(44.0, 52.0), vec2(36.0, 52.0),
            vec2(40.0, 52.0), vec2(44.0, 52.0), vec2(48.0, 52.0)
        ),
        vec2(16.0, 0.0)
    ),
    LimbUv( // Right Arm (Steve)
        vec2[](
            vec2(4.0, 4.0), vec2(4.0, 4.0), vec2(4.0, 12.0),
            vec2(4.0, 12.0), vec2(4.0, 12.0), vec2(4.0, 12.0)
        ),
        vec2[](
            vec2(48.0, 16.0), vec2(52.0, 20.0), vec2(44.0, 20.0),
            vec2(48.0, 20.0), vec2(52.0, 20.0), vec2(56.0, 20.0)
        ),
        vec2(0.0, 16.0)
    ),
    LimbUv( // Left Leg
        vec2[](
            vec2(4.0, 4.0), vec2(4.0, 4.0), vec2(4.0, 12.0),
            vec2(4.0, 12.0), vec2(4.0, 12.0), vec2(4.0, 12.0)
        ),
        vec2[](
            vec2(24.0, 48.0), vec2(28.0, 52.0), vec2(20.0, 52.0),
            vec2(24.0, 52.0), vec2(28.0, 52.0), vec2(32.0, 52.0)
        ),
        vec2(-16.0, 0.0)
    ),
    LimbUv( // Right Leg
        vec2[](
            vec2(4.0, 4.0), vec2(4.0, 4.0), vec2(4.0, 12.0),
            vec2(4.0, 12.0), vec2(4.0, 12.0), vec2(4.0, 12.0)
        ),
        vec2[](
            vec2(8.0, 16.0), vec2(12.0, 20.0), vec2(4.0, 20.0),
            vec2(8.0, 20.0), vec2(12.0, 20.0), vec2(16.0, 20.0)
        ),
        vec2(0.0, 16.0)
    ),
    LimbUv( // Left Arm (Alex)
        vec2[](
            vec2(3.0, 4.0), vec2(3.0, 4.0), vec2(4.0, 12.0),
            vec2(3.0, 12.0), vec2(4.0, 12.0), vec2(3.0, 12.0)
        ),
        vec2[](
            vec2(39.0, 48.0), vec2(42.0, 52.0), vec2(36.0, 52.0),
            vec2(39.0, 52.0), vec2(43.0, 52.0), vec2(46.0, 52.0)
        ),
        vec2(16.0, 0.0)
    ),
    LimbUv( // Right Arm (Alex)
        vec2[](
            vec2(3.0, 4.0), vec2(3.0, 4.0), vec2(4.0, 12.0),
            vec2(3.0, 12.0), vec2(4.0, 12.0), vec2(3.0, 12.0)
        ),
        vec2[](
            vec2(47.0, 16.0), vec2(50.0, 20.0), vec2(44.0, 20.0),
            vec2(47.0, 20.0), vec2(51.0, 20.0), vec2(54.0, 20.0)
        ),
        vec2(0.0, 16.0)
    )
);

const int STEVE_LIMB_UV_OFFSETS[6] = int[](0, 0, 0, 0, 0, 0);
const int ALEX_LIMB_UV_OFFSETS[6] = int[](0, 0, 4, 4, 0, 0);

const int LIMB_UV_HEAD_INDEX = 0;
const int LIMB_UV_BODY_INDEX = 1;
const int LIMB_UV_LEFT_ARM_INDEX = 2;
const int LIMB_UV_RIGHT_ARM_INDEX = 3;
const int LIMB_UV_LEFT_LEG_INDEX = 4;
const int LIMB_UV_RIGHT_LEG_INDEX = 5;

const LimbUv LIMB_UV_HEAD = LIMB_UVS[LIMB_UV_HEAD_INDEX];

const int FACE_TOP_INDEX = 0;
const int FACE_BOTTOM_INDEX = 1;
const int FACE_RIGHT_INDEX = 2;
const int FACE_FRONT_INDEX = 3;
const int FACE_LEFT_INDEX = 4;
const int FACE_BACK_INDEX = 5;

const vec2 FACE_RIGHT_HEAD = LIMB_UV_HEAD.faceOrigins[FACE_RIGHT_INDEX];
const vec2 FACE_LEFT_HEAD = LIMB_UV_HEAD.faceOrigins[FACE_LEFT_INDEX];

const vec2 FACE_DIVIDE_HEAD = (FACE_RIGHT_HEAD + FACE_LEFT_HEAD) / 2.0;
const int FACE_DIVIDE_OFFSET = FACE_LEFT_INDEX - FACE_RIGHT_INDEX;

void applyPlayer() {
    if(!PLAYER_ENABLED) {
        return;
    }

    if(transform.position.y < 2.0 * Y_POSITION_RADIX || ModelViewMat == mat4(1.0)) {
        return;
    }

    int metadata = int(transform.position.y) - 2 * Y_POSITION_RADIX;

    int steveAlex = (metadata /= Y_POSITION_RADIX) % STEVE_ALEX_RADIX;
    int limbFade = (metadata /= STEVE_ALEX_RADIX) % LIMB_FADE_RADIX;
    int limbIndex = (metadata /= LIMB_FADE_RADIX) % LIMB_INDEX_RADIX;

    transform.position.y = mod(transform.position.y, Y_POSITION_RADIX) - (Y_POSITION_RADIX / 2.0 - 1.0);

    int face = (gl_VertexID % 24) / 4;
    int overlay = (gl_VertexID / 24) % 2;

    int limbUvOffset = steveAlex == 0 ? STEVE_LIMB_UV_OFFSETS[limbIndex] : ALEX_LIMB_UV_OFFSETS[limbIndex];
    LimbUv limbUv = LIMB_UVS[limbIndex + limbUvOffset];

    transform.textureUV -= overlay * LIMB_UV_HEAD.overlayOffset * SKIN_TEXTURE_SIZE_INV;

    int divide = int(transform.textureUV.x >= FACE_DIVIDE_HEAD.x * SKIN_TEXTURE_SIZE_INV);

    face += divide * int(face == FACE_RIGHT_INDEX) * FACE_DIVIDE_OFFSET;
    face -= (1 - divide) * int(face == FACE_LEFT_INDEX) * FACE_DIVIDE_OFFSET;

    vec2 sizeRatio = limbUv.faceSizes[face] / LIMB_UV_HEAD.faceSizes[face];
    vec2 originOffset = limbUv.faceOrigins[face] - (LIMB_UV_HEAD.faceOrigins[face] * sizeRatio);

    transform.textureUV *= sizeRatio;
    transform.textureUV += originOffset * SKIN_TEXTURE_SIZE_INV;

    transform.textureUV += overlay * limbUv.overlayOffset * SKIN_TEXTURE_SIZE_INV;

    vec4 blockPosition = ModelViewMat * vec4(transform.position, 1.0);
    float blockDistanceSq = dot(blockPosition.xyz, blockPosition.xyz);

    float softFade = smoothstep(SOFT_FADE_START_SQ, SOFT_FADE_END_SQ, blockDistanceSq);
    float hardFade = step(HARD_FADE_SQ, blockDistanceSq);

    float nearFade = mix(1.0, mix(softFade, hardFade, limbFade == 2), limbFade != 0);

    int headBody = int(limbIndex == LIMB_UV_HEAD_INDEX || limbIndex == LIMB_UV_BODY_INDEX);
    transform.nearFade = mix(1.0, nearFade, headBody);
}

#endif
#endif
