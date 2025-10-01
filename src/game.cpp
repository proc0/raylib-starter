#include "game.hpp"

void Game::Load(){
    std::string pathAssets = DIR_ASSETS;
    const char* pathSoundSplat = pathAssets.append("/").append(URI_SOUND_SPLAT).c_str();

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
    DrawText(countText, 50, 50, 20, WHITE);
    if (isCursorHidden == 1) DrawText("CURSOR HIDDEN", SCREEN_WIDTH/2-100, 60, 20, BLACK);
    else DrawText("CURSOR VISIBLE", SCREEN_WIDTH/2-100, 60, 20, WHITE);
}

void Game::Loop() {
    Update();

    BeginDrawing();
    Render();
    EndDrawing();
}