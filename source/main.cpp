#include "game.hpp"

int main(void){
    InitWindow(1280, 720, "Example");
    InitAudioDevice();

    Game NewGame;

    NewGame.Load();
    
    while(!WindowShouldClose()){
        NewGame.Update();
        BeginDrawing();
        NewGame.Render();
        EndDrawing();
    }
    
    NewGame.Unload();
    CloseAudioDevice();
    CloseWindow();

    return 0;
}