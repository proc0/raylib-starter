#include "game.hpp"

int main(void){
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Example");
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