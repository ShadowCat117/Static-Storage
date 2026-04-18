#version 150
#if defined(RENDERTYPE_ENTITY_TRANSLUCENT_CULL) || defined(RENDERTYPE_ITEM_ENTITY_TRANSLUCENT_CULL) || defined(ITEM)

#define FOG_COLOR vec4(0);

#define SKYBOX_TIME (transform.gameTime * 12000)

#define WORLD_DIRECTION normalize(transform.position)
#define CAMERA_DIRECTION normalize(mat3(ModelViewMat) * transform.position)
#define SKY_DIRECTION vec3(0, WORLD_DIRECTION.y, 0)

void skyboxRainbow(float time, vec3 direction) {
    float speed = 0.02;

    transform.color.rgb = hsvToRgb(vec3((direction.x, direction.z) - time * speed, 1.0, 1.0));
}

void skyboxSpiral(float time, vec3 direction) {
    float speed = 0.05;

    vec2 uv = vec2(atan(direction.x, direction.z) / PI, direction.y);

    float r = length(uv);
    float f = 1.0 / max(r, 0.001);

    f += atan(uv.x, uv.y) / PI;
    f += time * speed;

    f = 1.0 - clamp(sin(f * PI * 2.0) * r * 40 + 0.5, 0.0, 1.0);
    f *= sin(r - 0.1);

    transform.color.rgb = vec3(f);
}

void skyboxMemoryMist(float time, vec3 direction) {
    vec3 mistColor = vec3(0.89, 0.91, 0.95);
    float shiftS = 0.025 * time;

    float mystifyA = fbm(direction + vec3(0.0, sin(shiftS), 0.0));
    vec2 reMiss = vec2(0.8 * fbm(direction.xy + vec2(mystifyA, 0.1)), fbm(direction.yz - mystifyA));
    float mystifyB = fbm(0.25 * (direction + vec3(0.0, atan(reMiss.x, reMiss.y) / PI, 0.0)));

    transform.color.rgb = mix(vec3(-0.15), mistColor + vec3(0.25), mystifyB);
}

void skyboxMemoryFog(float time, vec3 direction) {
    vec3 fogColor = vec3(0.55, 0.5, 0.6);
    float shiftS = -0.05 * time;
    vec3 pos = direction + 0.25 * vec3(sin(shiftS), shiftS, cos(shiftS));
    float noises = fbm(pos + vec3(0.2, 0.3, 0.2)) * 0.3;
    float redir = direction.y + noises;
    float q = (1.0 - redir * redir * 1.4) * 0.9;

    float fogAlpha = 1.0 - smoothstep(0.0, 0.6, redir);
    transform.color.rgba = vec4(mix(vec3(-0.2), fogColor + vec3(0.2), q), 0.85 * fogAlpha);
}

void skyboxRedCloudy(float time, vec3 direction) {
    float speed = 0.01;
    float intensity = 2.5;
    float scale = 1.2;
    vec3 color1 = vec3(0.600, 0.000, 0.000);
    vec3 color2 = vec3(1.000, 0.200, 0.000);
    vec3 color3 = vec3(0.000, 0.200, 0.000);
    vec3 color4 = vec3(1.000, 0.600, 0.600);
    vec3 color5 = vec3(0.300, 0.300, 0.300);
    vec3 color6 = vec3(1.200, 1.200, 1.200);

    float shift = time * speed;
    vec3 position1 = direction * intensity + vec3(0.0, shift, shift);
    float noise1 = fbm(scale * position1);
    vec2 position2 = vec2(fbm(position1.xy + noise1), fbm(position1.yz - noise1));
    float noise2 = fbm(scale * (position1 + vec3(position2, 0.0)));

    vec3 color = mix(color1, color2, noise2);
    color += mix(color3, color4, position2.x);
    color -= mix(color5, color6, position2.y);
    color = clamp(color, 0.0, 1.0);

    transform.color.rgb = color;
}

// the following three functions are literally all used
// for one shader. it might be a bit heavy but it was fine
// in my performance testing. maybe we should move this to
// a different file?
// - sockmower, 13/03/2026
float lightningBolt(vec2 uv, vec2 start, vec2 end, float seed, float width) {
    vec2 dir = end - start;
    float len = length(dir);
    vec2 norm = dir / len;
    vec2 perp = vec2(-norm.y, norm.x);

    vec2 toPoint = uv - start;
    float t = clamp(dot(toPoint, norm) / len, 0.0, 1.0);
    float along = dot(toPoint, norm);
    float across = dot(toPoint, perp);

    float disp = 0.0;
    disp += 0.06 * sin(t * 8.0 + seed * 3.7) * smoothstep(0.0, 0.3, t) * smoothstep(1.0, 0.7, t);
    disp += 0.03 * sin(t * 17.0 + seed * 7.1);
    disp += 0.015 * sin(t * 31.0 + seed * 11.3);
    disp += 0.008 * sin(t * 61.0 + seed * 19.7);

    float dist = abs(across - disp);

    float core = smoothstep(width * 0.5, 0.0, dist);
    float glow1 = smoothstep(width * 3.0, 0.0, dist) * 0.6;
    float glow2 = smoothstep(width * 8.0, 0.0, dist) * 0.2;

    float bolt = (core + glow1 + glow2) * step(0.0, t) * step(t, 1.0);

    float branch = 0.0;

    float bt1 = 0.4 + 0.2 * fract(seed * 1.618);
    vec2 branchPt1 = start + dir * bt1 + perp * disp;
    vec2 branchEnd1 = branchPt1 + vec2(0.08, -0.12) + vec2(fract(seed * 2.71) * 0.1 - 0.05, 0.0);
    {
        vec2 bd = branchEnd1 - branchPt1;
        float bl = length(bd);
        vec2 bn = bd / bl;
        vec2 bp = vec2(-bn.y, bn.x);
        vec2 tp = uv - branchPt1;
        float bt = clamp(dot(tp, bn) / bl, 0.0, 1.0);
        float ba = dot(tp, bp);
        float bd2 = 0.04 * sin(bt * 12.0 + seed * 5.3);
        float bd3 = abs(ba - bd2);
        branch += smoothstep(width * 0.3, 0.0, bd3) * step(0.0, bt) * step(bt, 1.0);
        branch += smoothstep(width * 2.0, 0.0, bd3) * 0.4 * step(0.0, bt) * step(bt, 1.0);
    }

    float bt2 = 0.65 + 0.15 * fract(seed * 2.414);
    vec2 branchPt2 = start + dir * bt2 + perp * disp;
    vec2 branchEnd2 = branchPt2 + vec2(-0.10, -0.09) + vec2(fract(seed * 1.41) * 0.08 - 0.04, 0.0);
    {
        vec2 bd = branchEnd2 - branchPt2;
        float bl = length(bd);
        vec2 bn = bd / bl;
        vec2 bp = vec2(-bn.y, bn.x);
        vec2 tp = uv - branchPt2;
        float bt = clamp(dot(tp, bn) / bl, 0.0, 1.0);
        float ba = dot(tp, bp);
        float bd2 = 0.03 * sin(bt * 15.0 + seed * 8.1);
        float bd3 = abs(ba - bd2);
        branch += smoothstep(width * 0.25, 0.0, bd3) * step(0.0, bt) * step(bt, 1.0);
        branch += smoothstep(width * 2.0, 0.0, bd3) * 0.35 * step(0.0, bt) * step(bt, 1.0);
    }

    return clamp(bolt + branch * 0.7, 0.0, 1.0);
}

float lightningFlash(float time, float seed) {
    float period = 35.0 + 25.0 * random(seed);
    float phase = fract((time + seed * 37.3) / period);

    float numFlashes = floor(random(seed + floor((time + seed * 37.3) / period) * 7.91) * 3.0) + 1.0;
    float spacing = 0.012 + 0.018 * random(seed + 44.1);
    float duration = 0.025 + 0.015 * random(seed + 88.3);

    float result = 0.0;
    for(int f = 0; f < 3; f++) {
        if(float(f) >= numFlashes)
            break;
        float offset = float(f) * spacing;
        float brightness = pow(0.55, float(f));
        result += brightness * smoothstep(0.0, 0.003, phase - offset) * smoothstep(duration + offset, duration + offset - 0.008, phase);
    }
    return clamp(result, 0.0, 1.0);
}

float distantCloudFlash(float time, float seed) {
    float period = 40.0 + 80.0 * random(seed + 100.0);
    float phase = fract((time + seed * 53.7) / period);
    float duration = 0.08 + 0.06 * random(seed + 200.0);
    float envelope = smoothstep(0.0, duration * 0.4, phase) * smoothstep(duration, duration * 0.6, phase);
    return envelope * 0.18;
}

// chaos, chaos!
void skyboxRedLightning(float time, vec3 direction) {
    vec3 valuationUpper = vec3(0.106, 0.358, 0.036);
    vec3 colorUpper = vec3(1.000, 1.000, 1.000);

    vec3 colorHorizon = vec3(0.05, 0.05, 0.05);
    float heightHorizon = 0.15;
    float widthHorizon = 0.30;
    float mixHorizon = 0.10;

    skyboxRedCloudy(time, direction);
    vec3 colorUpperSky = vec3(dot(transform.color.rgb, valuationUpper) * colorUpper);
    float influenceUpper = smoothstep(heightHorizon - widthHorizon, heightHorizon, direction.y);
    vec3 colorSky = mix(vec3(0, 0, 0), colorUpperSky, influenceUpper);

    float influenceSky = mix(mixHorizon, 1.0, smoothstep(0.0, widthHorizon, abs(direction.y - heightHorizon)));
    transform.color.rgb = mix(colorHorizon, colorSky, influenceSky);

    float cloudGlow = 0.0;
    for(int i = 0; i < 3; i++) {
        float seed = float(i) * 17.13 + 3.7;
        float glow = distantCloudFlash(time, seed);

        float cycle = floor((time + seed * 53.7) / (20.0 + 40.0 * random(seed + 100.0)));
        float az = fract(seed * 0.137 + cycle * 0.318) * 6.28318;
        vec3 flashDir = vec3(cos(az), 0.0, sin(az));

        float azimuthalFocus = dot(normalize(direction.xz), flashDir.xz);
        float azimuthalMask = smoothstep(0.55, 0.90, azimuthalFocus);

        float flashEl = 0.25 + fract(seed * 0.331 + cycle * 0.271) * 0.30;
        float elevationMask = smoothstep(0.18, 0.0, abs(direction.y - flashEl));

        cloudGlow += glow * azimuthalMask * elevationMask;
    }

    transform.color.rgb += vec3(1.0, 0.10, 0.05) * clamp(cloudGlow, 0.0, 0.35);

    float totalLightning = 0.0;
    float totalScreenFlash = 0.0;

    for(int i = 0; i < 4; i++) {
        float seed = float(i) * 31.41592 + 7.3;
        float strikeIntensity = lightningFlash(time, seed);

        if(strikeIntensity > 0.0) {
            float cycle = floor((time + seed * 37.3) / (35.0 + 25.0 * random(seed)));
            float az = fract(seed * 0.137 + cycle * 0.419) * 6.28318;
            float el = 0.3 + fract(seed * 0.271 + cycle * 0.347) * 0.35;
            vec3 boltCenter = normalize(vec3(cos(az) * sqrt(1.0 - el * el), el, sin(az) * sqrt(1.0 - el * el)));

            vec3 up = vec3(0.0, 1.0, 0.0);
            vec3 tangentX = normalize(cross(up, boltCenter));
            vec3 tangentY = normalize(cross(boltCenter, tangentX));

            vec3 d = normalize(direction);
            vec2 localUV = vec2(dot(d, tangentX), dot(d, tangentY));

            vec2 origin = vec2(fract(seed * 0.413 + cycle * 0.531) * 0.3 - 0.15, 0.25);
            vec2 target = origin + vec2(fract(seed * 0.619 + cycle * 0.217) * 0.16 - 0.08, -0.5);

            float proximity = smoothstep(0.5, 0.85, dot(d, boltCenter));

            float bolt = lightningBolt(localUV, origin, target, seed + cycle, 0.003);
            totalLightning += bolt * strikeIntensity * proximity;
            totalScreenFlash += strikeIntensity * 0.25 * proximity;
        }
    }

    totalLightning = clamp(totalLightning, 0.0, 1.0);
    totalScreenFlash = clamp(totalScreenFlash, 0.0, 1.0);

    vec3 boltColor = mix(vec3(1.0, 0.05, 0.02), vec3(1.0, 0.85, 0.80), totalLightning);
    vec3 flashColor = vec3(0.9, 0.08, 0.04) * totalScreenFlash;

    transform.color.rgb = clamp(transform.color.rgb + flashColor + boltColor * totalLightning, 0.0, 1.0);
}

void skyboxStormy(float time, vec3 direction) {
    vec3 valuationUpper = vec3(0.106, 0.358, 0.036);
    vec3 colorUpper = vec3(1.000, 1.000, 1.000);

    vec3 colorHorizon = vec3(0.05, 0.05, 0.05);
    float heightHorizon = 0.15;
    float widthHorizon = 0.30;
    float mixHorizon = 0.10;

    skyboxRedCloudy(time, direction);
    vec3 colorUpperSky = vec3(dot(transform.color.rgb, valuationUpper) * colorUpper);
    float influenceUpper = smoothstep(heightHorizon - widthHorizon, heightHorizon, direction.y);
    vec3 colorSky = mix(vec3(0, 0, 0), colorUpperSky, influenceUpper);

    float influenceSky = mix(mixHorizon, 1.0, smoothstep(0.0, widthHorizon, abs(direction.y - heightHorizon)));
    transform.color.rgb = mix(colorHorizon, colorSky, influenceSky);
}

void skyboxWarSurface(float time, vec3 direction) {
    vec3 colorHorizon = vec3(0.000, 0.000, 0.000);
    float heightHorizon = 0.5;

    skyboxRedCloudy(time, direction);
    vec3 colorSky = transform.color.rgb;

    float influenceSky = smoothstep(0.0, heightHorizon, direction.y);
    transform.color.rgb = mix(colorHorizon, colorSky, influenceSky);
}

void skyboxWarHeights(float time, vec3 direction) {
    vec3 valuationUpper = vec3(0.106, 0.358, 0.036);
    vec3 colorUpper = vec3(1.000, 1.000, 1.000);

    vec3 colorHorizon = vec3(0.05, 0.05, 0.05);
    float heightHorizon = 0.15;
    float widthHorizon = 0.30;
    float mixHorizon = 0.10;

    skyboxRedCloudy(time, direction);
    vec3 colorLowerSky = transform.color.rgb;
    vec3 colorUpperSky = vec3(dot(colorLowerSky, valuationUpper) * colorUpper);
    float influenceUpper = smoothstep(heightHorizon - widthHorizon, heightHorizon, direction.y);
    vec3 colorSky = mix(colorLowerSky, colorUpperSky, influenceUpper);

    float influenceSky = mix(mixHorizon, 1.0, smoothstep(0.0, widthHorizon, abs(direction.y - heightHorizon)));
    transform.color.rgb = mix(colorHorizon, colorSky, influenceSky);
}

void skyboxLight(float time, vec3 direction) {
    vec3 color1 = vec3(0.850, 0.850, 1.000);
    vec3 color2 = vec3(0.750, 0.400, 0.000);

    float noise = crystalNoise(direction * 3.0, time * 0.01);

    vec3 color = mix(color1, color2, noise);

    transform.color.rgb = mix(vec3(1.0, 0.9, 0.8), color, smoothstep(0.1, 0.5, direction.y));
}

void applySkyboxes() {
    if(!SKYBOXES_ENABLED)
        return;

    if(abs(transform.textureColor.ga) != vec2(251, 254) / 255.0)
        return;

    #moj_import <config/skybox.glsl>

    transform.fogColor = FOG_COLOR;
}

#endif