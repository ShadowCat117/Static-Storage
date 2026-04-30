#version 150
#if defined(RENDERTYPE_TEXT) || defined(RENDERTYPE_TEXT_SEE_THROUGH)

#ifdef VERTEX_SHADER

#moj_import <config/anchor.glsl>

uniform sampler2D Sampler0;

struct Transform {
    vec4 color;
    vec4 textureColor;
    vec2 textureUV;
    vec4 texture;
    vec2 screenSize;
    vec3 position;
    vec4 screenOffset;
    vec4 initScreen;
    float gameTime;
    int transition;
    vec2 screen;
    bool isShadow;
    int vertexId;
} transform;

vec4 fetchAtlas(ivec2 coords) {
    return texelFetch(Sampler0, coords, 0) * 255.0;
}

void hideScoreboardNumbers(vec3 position, vec3 numberColor, int vertex) {
    if(!HIDE_SCOREBOARD_NUMBERS_ENABLED)
        return;
    if(transform.position.z != position.z || gl_VertexID % vertex > 0)
        return;
    if(transform.initScreen.x < position.x || transform.initScreen.y < position.y)
        return;
    if(transform.color.r != numberColor.r / 255.0 || transform.color.g != numberColor.g / 255.0 || transform.color.b != numberColor.b / 255.0)
        return;

    transform.position.x += transform.screenSize.x + 100;
}

void screenAnchor(vec4 atlas, int marker, vec2 offset, int anchor) {
    if(!ANCHORS_ENABLED)
        return;

    if(atlas != vec4(marker, 255, 0, 1)) {
        return;
    }

    vec2 screen = vec2(0);
    switch(anchor) {
        case 0:
            screen = TOP_LEFT;
            break;
        case 1:
            screen = TOP_RIGHT;
            break;
        case 2:
            screen = TOP_MIDDLE;
            break;
        case 3:
            screen = CENTER_LEFT;
            break;
        case 4:
            screen = CENTER_RIGHT;
            break;
        case 5:
            screen = CENTER_MIDDLE;
            break;
        case 6:
            screen = BOTTOM_LEFT;
            break;
        case 7:
            screen = BOTTOM_MIDDLE;
            break;
        case 8:
            screen = BOTTOM_RIGHT;
            break;
        default:
            return;
    }

    if(anchor == 5 && mod(round(transform.screenSize.x), 2) != 0) {
        transform.position.x += 1;
    }

    transform.position.x += offset.x;
    transform.position.y += offset.y;
    transform.screenOffset.x += screen.x;
    transform.screenOffset.y += screen.y;
}

void verticalSlide(vec4 color, float time) {
    if(!VERTICAL_SLIDE_ENABLED)
        return;

    if(transform.textureColor != color) {
        return;
    }

    transform.position.y += (time * 15) - 10;
}

void tile(bool autoplay, int frames, int limiter, int time, int marker, float res, int width, int height) {
    if(!TILES_ENABLED)
        return;

    if(transform.textureColor != vec4(marker, 255, 0, 1)) {
        return;
    }

    limiter -= 1;

    int tile;
    int rows = 4;
    int columns = 4;
    float progress = transform.color.a * limiter;

    if(frames == 0)
        frames = rows * columns;

    #if defined(RENDER_SCREEN)
    if(transform.isShadow)
        transform.color = vec4(0);
    #endif

    if(autoplay == true) {
        tile = int(mod(transform.gameTime * time, frames));
    } else {
        tile = int(mod(progress, frames));
    }

    int x = tile % columns;
    int y = tile / columns;

    float tileWidth = width / columns;
    float tileHeight = height / rows;
    float widthRatio = (1 / tileWidth) * res;
    float heightRatio = (1 / tileHeight) * res;

    vec2 texture = vec2(transform.textureUV.x + (widthRatio * x), transform.textureUV.y + (heightRatio * y));

    switch(int(gl_VertexID % 4)) {
        case 1:
            texture.y -= heightRatio * (rows - 1);
            break;
        case 2:
            texture.y -= heightRatio * (rows - 1);
            texture.x -= widthRatio * (columns - 1);
            break;
        case 3:
            texture.x -= widthRatio * (columns - 1);
            break;
    }

    if(autoplay != true) {
        if(progress <= limiter - frames) {
            transform.color = vec4(0);
        } else {
            transform.color.a = transform.textureColor.a;
        }
    }

    transform.textureUV = texture;
}

void applyTiles() {
    tile(true, 16, 0, 10000, 57, 0.25, 16, 16);
    tile(true, 16, 0, 10000, 58, 4.0, 64, 64);
    tile(true, 16, 0, 4000, 59, 0.25, 16, 16);
}

void applyAnchors() {
    screenAnchor(fetchAtlas(ivec2(6, 8)), 50, vec2(0, 0), 0);
    screenAnchor(fetchAtlas(ivec2(0, 0)), 45, vec2(0, 0), 0);
    screenAnchor(fetchAtlas(ivec2(6, 0)), 44, vec2(8, 2), 1);
    screenAnchor(fetchAtlas(ivec2(6, 8)), 49, vec2(0, 0), 2);
    screenAnchor(fetchAtlas(ivec2(0, 0)), 48, vec2(0, 0), 3);
    screenAnchor(fetchAtlas(ivec2(6, 8)), 48, vec2(0, 0), 3);
    screenAnchor(fetchAtlas(ivec2(0, 0)), 46, vec2(0, 0), 4);
    screenAnchor(fetchAtlas(ivec2(6, 8)), 47, vec2(0, 0), 4);
    screenAnchor(fetchAtlas(ivec2(6, 8)), 51, vec2(0, 0), 5);
    screenAnchor(fetchAtlas(ivec2(6, 0)), 52, vec2(8, 2), 6);
}

#endif

#ifdef FRAGMENT_SHADER

struct Transform {
    vec4 texColor;
    int texAlpha;
    vec4 color;
    vec4 colorMod;
    vec4 vertexColor;
    float gameTime;
    bool isShadow;

    vec2 screenSize;
    vec2 centerUV;
    vec2 textureUV;
    float aspectRatio;

    int transition;
    int vertexId;
    vec2 screen;

    vec3 position;
} transform;

void alphaCutoff(int alpha) {
    if(transform.color.a <= alpha / 255.0 && transform.texColor.rgb != vec3(255)) {
        discard;
    }
}

void disableShadow(float alpha) {
    if(!DISABLE_TEXT_SHADOWS_ENABLED)
        return;

    if(transform.texAlpha != alpha)
        return;

    if(transform.isShadow)
        discard;
}

void restoreColor(vec3 color) {
    if(transform.texColor.rgb * 255.0 != color)
        return;

    transform.color.rgb = color / 255.0;

    if(transform.isShadow) {
        transform.color.rgb = transform.texColor.rgb * 0.25;
    }
}

void applyColorRestorations() {
    if(!COLOR_RESTORATIONS_ENABLED)
        return;

    restoreColor(vec3(43, 24, 24));
}

#endif
#endif