#version 150

#if defined(RENDERTYPE_TEXT) || defined(RENDERTYPE_ITEM_TRANSLUCENT_CULL) || defined(RENDERTYPE_ITEM_ENTITY_TRANSLUCENT_CULL) || defined(ITEM)

MOVEMENT(MOVEMENT_MARKER, 0) {
    movementSlide(vec3(0, 1, 0), 3);
}

MOVEMENT(MOVEMENT_MARKER, 4) {
    movementSlide(vec3(1, 0, 0), 3);
}

MOVEMENT(MOVEMENT_MARKER, 8) {
    transform.position.y += movementWarp(2, transform.position.y);
}

MOVEMENT(MOVEMENT_MARKER, 12) {
    transform.position.x += movementWarp(2, transform.position.y);
}

MOVEMENT(MOVEMENT_MARKER, 16) {  
    transform.position.y += movementWarp(2, transform.position.x);
}

MOVEMENT(MOVEMENT_MARKER, 20) {
    transform.position.x += movementWarp(2, transform.position.x);
}

MOVEMENT(MOVEMENT_MARKER, 24) {
    movementVibrate(MOVEMENT_PROGRESS, MOVEMENT_TIME);
}

MOVEMENT(MOVEMENT_MARKER, 28) {
    #if defined(IS_TEXT)
    movementScale(1, 2, 1);
    #elif defined(IS_ITEM)
    
    #if defined(MC_1_21_4) || defined(MC_1_21_5)
    movementScale(1, 1, 1);
    #else
    movementScale(1, 4, 1);
    #endif

    #endif
}

MOVEMENT(MOVEMENT_MARKER, 32) {
    movementOrbit(vec3(1, 0, 0), vec3(0, 1, 0), 3, 1);
}

MOVEMENT(MOVEMENT_MARKER, 36) {
    movementBlink(0.5);
}

MOVEMENT(MOVEMENT_MARKER, 40) {
    movementShake(MOVEMENT_PROGRESS, MOVEMENT_TIME);
}

MOVEMENT(MOVEMENT_MARKER, 44) {
    movementStretch(5);
}

MOVEMENT(MOVEMENT_MARKER, 48) {
    movementBump(1, 1);
}

MOVEMENT(MOVEMENT_MARKER, 52) {
    movementItalic(-64, 1);
}

MOVEMENT(MOVEMENT_MARKER, 56) {
    movementScaleStatic(12, 1);
}

MOVEMENT(MOVEMENT_MARKER, 60) {
    movementOffset(0.0, MOVEMENT_PROGRESS);
}

MOVEMENT(MOVEMENT_MARKER, 64) {
    movementOffset(0.25, MOVEMENT_PROGRESS);
}

MOVEMENT(MOVEMENT_MARKER, 68) {
    movementOffset(0.5, MOVEMENT_PROGRESS);
}

MOVEMENT(MOVEMENT_MARKER, 72) {
    movementOffset(0.75, MOVEMENT_PROGRESS);
}
#endif

return;