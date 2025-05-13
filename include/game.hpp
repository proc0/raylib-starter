#pragma once

#include <raylib.h>
#include <string>

#include "config.h"

#define WAV_SOUND_SPLAT "splat1.wav"

class Game {
    int count;
    Sound splat;

    public:
        void Load();
        void Unload();
        void Update();
        void Render() const;
};
