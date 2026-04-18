#version 150

EFFECT(0, 240, 0) {
    effectRainbow();
}

EFFECT(0, 240, 4) {
    effectGradient(rgb(245, 98, 23), rgb(11, 72, 107), 500);
}

EFFECT(0, 240, 8) {
    effectFade(1.0);
    overrideColor(rgb(90, 240, 130));
}

EFFECT(0, 240, 12) {
    effectBlink(0.2);
    overrideColor(rgb(200, 50, 50));
}

EFFECT(0, 240, 16) {
    effectGradient(rgb(86, 5, 5), rgb(138, 3, 3), 1000);
}

EFFECT(0, 240, 20) {
    effectShine(rgb(160, 200, 75), rgb(255, 255, 210), 500, 0.5);
}

EFFECT(0, 240, 24) {
    #if defined(IS_TEXT)
    movementShake(0.5, MOVEMENT_TIME);
    #elif defined(IS_ITEM)
    movementShake(0.2, MOVEMENT_TIME);
    #endif
    effectFaded(vec3(0.3, 0.3, 0.3), 0.2, 1.0);
    effectFade(1.0);
}

EFFECT(0, 240, 28) {
    #if defined(IS_TEXT)
    movementItalic(-64, 1);
    overrideColor(rgb(85, 255, 255));
    #elif defined(IS_ITEM)
    overrideColor(rgb(85, 255, 255));
    #endif
}

EFFECT(0, 240, 32) {
    #if defined(IS_TEXT)
    movementItalic(-64, 1);
    overrideColor(rgb(198, 198, 198));
    #elif defined(IS_ITEM)
    overrideColor(rgb(198, 198, 198));
    #endif
}

EFFECT(0, 240, 36) {
    transform.position.y += movementWarp(2, transform.position.x);
    overrideColor(rgb(198, 198, 198));
}