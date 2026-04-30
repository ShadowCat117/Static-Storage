#if defined(RENDERTYPE_TEXT) || defined(RENDERTYPE_TEXT_SEE_THROUGH)

void applyTransitions() {
    if(!TRANSITIONS_ENABLED)
        return;

    if(transform.transition == 0) {
        return;
    }

    switch(transform.transition) {
        case 1:
            transitionIris();
            break;
        case 2:
            transitionBlink();
            break;
        case 3:
            transitionSpeed(2000, 0.07, 30, 200);
            break;
        case 4:
            transitionDiamond();
            break;
        case 5:
            transitionNoise();
            break;
        case 6:
            transitionLoad(1000);
            break;
        case 7:
            transitionVignette(0.4);
            break;
        case 8:
            transitionClose(transform.centerUV.y - 0.5);
            break;
        case 9:
            transitionClose(transform.centerUV.y + 0.5);
            break;
        case 10:
            transitionClose(transform.centerUV.x - 0.5);
            break;
        case 11:
            transitionClose(transform.centerUV.x + 0.5);
            break;
        case 12:
            transitionFade();
            break;
        case 13:
            transitionLetterbox();
            break;
        case 14:
            transitionWheel();
            break;
        case 15:
            transitionAngular(90);
            break;
        case 16:
            transitionStatic();
            break;
        case 17:
            transitionVignetteFog(0.5);
            break;
        case 18:
            transitionFocus(0.25);
            break;
        case 19:
            transitionPortal();
            break;
    }
}
#endif