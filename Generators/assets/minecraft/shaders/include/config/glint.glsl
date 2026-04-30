#define BLUE rgb(80, 130, 230)
#define GREEN rgb(30, 230, 130)
#define RED rgb(235, 70, 70)
#define CYAN rgb(100, 190, 190)
#define ORANGE rgb(250, 120, 20)
#define BLACK rgb(50, 50, 50)
#define WHITE rgb(250, 230, 230)
#define PINK rgb(255, 150, 200)
#define PURPLE rgb(200, 60, 230)
#define YELLOW rgb(240, 240, 80)

#define TINT_BLEND_AMT 0.5

#define DEFAULT_SHINY rgb(255, 200, 100)
#define NORMAL_SHINY rgb(255, 255, 255)
#define SET_SHINY rgb(85, 255, 85)
#define UNIQUE_SHINY rgb(255, 255, 85)
#define RARE_SHINY rgb(255, 85, 255)
#define LEGENDARY_SHINY rgb(85, 255, 255)
#define FABLED_SHINY rgb(255, 85, 85)
#define MYTHIC_SHINY rgb(170, 0, 170)

#define SHINY_INTENSITY_AMT 0.4
#define SHINY_BRIGHTNESS_AMT 2

void applyGlints() {
    if(!GLINTS_ENABLED)
        return;

    if(transform.glint == 0)
        return;

    switch(int(transform.glint)) {
        case 1:
            glintShiny(DEFAULT_SHINY, SHINY_INTENSITY_AMT, SHINY_BRIGHTNESS_AMT);
            break;
        case 2:
            glintClear();
            break;
        case 3:
            glintRainbow();
            applyLighting();
            break;
        case 4:
            glintGlitch();
            break;
        case 5:
            glintRipple();
            applyLighting();
            break;
        case 6:
            glintVibrate();
            break;
        case 7:
            glintGrayscale();
            break;
        case 8:
            glintInvert();
            break;
        case 9:
            glintShadow();
            break;
        case 10:
            glintAurora();
            applyLighting();
            break;
        case 11:
            glintReflection();
            applyLighting();
            break;
        case 12:
            glintPlasma();
            applyLighting();
            break;
        case 13:
            glintDistort();
            break;
        case 14:
            glintChrome();
            applyLighting();
            break;
        case 15:
            glintTint(BLUE, TINT_BLEND_AMT);
            break;
        case 16:
            glintTint(GREEN, TINT_BLEND_AMT);
            break;
        case 17:
            glintTint(RED, TINT_BLEND_AMT);
            break;
        case 18:
            glintTint(CYAN, TINT_BLEND_AMT);
            break;
        case 19:
            glintTint(ORANGE, TINT_BLEND_AMT);
            break;
        case 20:
            glintTint(BLACK, TINT_BLEND_AMT);
            break;
        case 21:
            glintTint(WHITE, TINT_BLEND_AMT);
            break;
        case 22:
            glintTint(PINK, TINT_BLEND_AMT);
            break;
        case 23:
            glintTint(PURPLE, TINT_BLEND_AMT);
            break;
        case 24:
            glintTint(YELLOW, TINT_BLEND_AMT);
            break;
        case 25:
            glintShiny(NORMAL_SHINY, SHINY_INTENSITY_AMT, SHINY_BRIGHTNESS_AMT);
            break;
        case 26:
            glintShiny(SET_SHINY, SHINY_INTENSITY_AMT, SHINY_BRIGHTNESS_AMT);
            break;
        case 27:
            glintShiny(UNIQUE_SHINY, SHINY_INTENSITY_AMT, SHINY_BRIGHTNESS_AMT);
            break;
        case 28:
            glintShiny(RARE_SHINY, SHINY_INTENSITY_AMT, SHINY_BRIGHTNESS_AMT);
            break;
        case 29:
            glintShiny(LEGENDARY_SHINY, SHINY_INTENSITY_AMT, SHINY_BRIGHTNESS_AMT);
            break;
        case 30:
            glintShiny(FABLED_SHINY, SHINY_INTENSITY_AMT, SHINY_BRIGHTNESS_AMT);
            break;
        case 31:
            glintShiny(MYTHIC_SHINY, SHINY_INTENSITY_AMT, SHINY_BRIGHTNESS_AMT);
            break;
        case 32:
            clearFog();
            break;
    }

    #if defined(IS_ENTITY)
    applyLighting();
    applyShading();
    #endif
}