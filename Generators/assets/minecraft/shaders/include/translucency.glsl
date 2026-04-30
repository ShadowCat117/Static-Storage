#version 150
#if defined(RENDERTYPE_ENTITY_TRANSLUCENT_CULL) || defined(RENDERTYPE_ITEM_ENTITY_TRANSLUCENT_CULL) || defined(RENDERTYPE_ARMOR_CUTOUT_NO_CULL) || defined(ENTITY) || defined(ITEM)

#if defined(VERTEX_SHADER)

void initTranslucency() {
    if(transform.color.gb != vec2(254, 0) / 255)
        return;

    if(transform.color.r < 1) {
        int y = int(round(transform.color.r * 255.0));
        transform.color = vec4(1);
        #if defined(IS_ITEM)
        transform.dyeColor = vec4(1);
        #endif

        transform.translucent = y;
    }
}
#endif

#if defined(FRAGMENT_SHADER)

void applyTranslucent(float alpha) {
    transform.color.a = mix(transform.color.a, 0.0, alpha);
}

void applyTranslucency() {
    if(!TRANSLUCENCY_ENABLED)
        return;

    if(transform.translucent == 0)
        return;

    applyTranslucent(float(transform.translucent) / 100.0);
}
#endif
#endif