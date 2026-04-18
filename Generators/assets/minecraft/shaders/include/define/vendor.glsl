#ifndef __GLSL_CG_DATA_TYPES
#define IS_APPLE
#define IS_AMD
#define IS_INTEL
#else
#define IS_NVIDIA
#endif

#if defined(IS_APPLE) || defined(IS_AMD) || defined(IS_INTEL)
#define IS_ALT_VENDOR
#endif