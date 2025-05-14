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
}

void Game::Render() const {
    ClearBackground(BLACK);
    DrawRectangleGradientH(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, BLUE, GREEN);
    const char* countText = TextFormat("Count: %i", count);
    DrawText(countText, 50, 50, 20, RED);
}
