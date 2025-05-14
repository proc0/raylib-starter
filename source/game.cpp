#include "game.hpp"

void Game::Load(){
    std::string pathResource = PATH_RESOURCE;
    const char* pathSoundSplat = pathResource.append("/").append(WAV_SOUND_SPLAT).c_str();

    splat = LoadSound(pathSoundSplat);
    count = 0;
}

void Game::Unload(){
    UnloadSound(splat);
}

void Game::Update(){
    if(IsKeyPressed(KEY_SPACE)){
        count++;
        PlaySound(splat);
    }
    
    if (IsKeyPressed(KEY_H)){
        if (isCursorHidden == 0)
        {
            HideCursor();
            isCursorHidden = 1;
        }
        else
        {
            ShowCursor();
            isCursorHidden = 0;
        }
    }
    
    ballPosition = GetMousePosition();
}

void Game::Render() const {
    ClearBackground(BLACK);
    DrawRectangleGradientH(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, BLUE, GREEN);
    DrawCircleV(ballPosition, 40, ballColor);
    const char* countText = TextFormat("Count: %i", count);
    DrawText(countText, 50, 50, 20, RED);
    if (isCursorHidden == 1) DrawText("CURSOR HIDDEN", 20, 60, 20, RED);
    else DrawText("CURSOR VISIBLE", 20, 60, 20, LIME);
}

void Game::Loop() {
    Update();
    
    BeginDrawing();
    Render();
    EndDrawing();
}