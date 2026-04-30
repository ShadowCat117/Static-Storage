#version 150

struct TextureData {
    vec2 cornerUV1;
    vec2 cornerUV2;
    vec2 cornerUV3;

    vec2 minUV;
    vec2 maxUV;

    vec2 lower;
    vec2 upper;
} data;

#ifdef VERTEX_SHADER

out vec3 cornerTex1;
out vec3 cornerTex2;
out vec3 cornerTex3;

void encode() {
    data.lower = vec2(0);
    data.upper = vec2(0);

    if(gl_VertexID % 4 == 0)
        cornerTex1 = vec3(transform.textureUV * 64.0, 1);
    if(gl_VertexID % 4 == 2)
        cornerTex2 = vec3(transform.textureUV * 64.0, 1);
    if(gl_VertexID % 2 == 1)
        cornerTex3 = vec3(transform.textureUV * 64.0, 1);
}

#endif

#ifdef FRAGMENT_SHADER

in vec3 cornerTex1;
in vec3 cornerTex2;
in vec3 cornerTex3;

void encode() {
    data.cornerUV1 = cornerTex1.xy / max(cornerTex1.z, 0.0001);
    data.cornerUV2 = cornerTex2.xy / max(cornerTex2.z, 0.0001);
    data.cornerUV3 = cornerTex3.xy / max(cornerTex3.z, 0.0001);
    data.minUV = min(data.cornerUV1, min(data.cornerUV2, data.cornerUV3));
    data.maxUV = max(data.cornerUV1, max(data.cornerUV2, data.cornerUV3));

    data.lower = fract(data.minUV);
    data.upper = fract(data.maxUV);
}

#endif