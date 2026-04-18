#version 150

#if defined(RENDERTYPE_ITEM_TRANSLUCENT_CULL) || defined(RENDERTYPE_ITEM_ENTITY_TRANSLUCENT_CULL) || defined(ITEM)

switch(int(round(transform.textureColor.b * 255.0))) {
    case 1:
        skyboxMemoryMist(SKYBOX_TIME, WORLD_DIRECTION);
        break;
    case 2:
        skyboxMemoryFog(SKYBOX_TIME, WORLD_DIRECTION);
        break;
    case 3:
        skyboxStormy(SKYBOX_TIME, WORLD_DIRECTION);
        break;
    case 4:
        skyboxWarSurface(SKYBOX_TIME, WORLD_DIRECTION);
        break;
    case 5:
        skyboxWarHeights(SKYBOX_TIME, WORLD_DIRECTION);
        break;
    case 6:
        skyboxLight(SKYBOX_TIME, WORLD_DIRECTION);
        break;
    case 7:
        skyboxRedLightning(SKYBOX_TIME, WORLD_DIRECTION);
        break;


    case 0:
        // Experiment with skyboxes here:
        skyboxRainbow(SKYBOX_TIME, WORLD_DIRECTION);
        break;
}

#endif