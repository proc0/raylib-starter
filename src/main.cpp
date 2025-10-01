#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#endif

#include "game.hpp"

Game NewGame;

void main_loop(){
    NewGame.Loop();
}

int main(void){
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Example");
    InitAudioDevice();

    NewGame.Load();

    #ifdef __EMSCRIPTEN__
        emscripten_set_main_loop(main_loop, 0, 1);
    #else
        SetTargetFPS(120);
        while (!WindowShouldClose()) {
            NewGame.Loop();
        }
    #endif
    
    NewGame.Unload();
    CloseAudioDevice();
    CloseWindow();

    return 0;
}