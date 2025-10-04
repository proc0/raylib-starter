#pragma once

#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#endif
#include <raylib.h>
#include <string>

#include "config.h"

#define URI_SOUND_SPLAT "splat1.wav"
// initial screen dimensions
#define SCREEN_WIDTH 1280
#define SCREEN_HEIGHT 720

class Game {
    int count;
    Sound splat;
    Color ballColor = RED;
    Vector2 ballPosition = { -100.0f, -100.0f };
    bool isCursorHidden = false;
    
    public:
        int screenWidth = SCREEN_WIDTH;
        int screenHeight = SCREEN_HEIGHT;

        void Load();
        static void Loop(void *self);
        void Render() const;
        void Resize();
        void Run();
        void Unload();
        void Update();
};
