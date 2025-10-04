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

// #if __EMSCRIPTEN__
// EM_JS(int, getBrowserWidth, (), {
//     return window.innerWidth;
// });

// EM_JS(int, getBrowserHeight, (), {
//     return window.innerHeight;
// });
// #endif

void Game::Render() const {

// #if __EMSCRIPTEN__
//     static int PADDING = 30; // set padding to avoid scrollbar and browser edge overlap
//     SetWindowSize(getBrowserWidth() - PADDING, getBrowserHeight() - PADDING);
// #endif

    BeginDrawing();
    ClearBackground(BLACK);
    DrawRectangleGradientH(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, BLUE, GREEN);
    DrawCircleV(ballPosition, 40, ballColor);
    const char* countText = TextFormat("Count: %i", count);
    DrawText(countText, 50, 50, 20, WHITE);
    if (isCursorHidden == 1) DrawText("CURSOR HIDDEN", SCREEN_WIDTH/2-100, 60, 20, BLACK);
    else DrawText("CURSOR VISIBLE", SCREEN_WIDTH/2-100, 60, 20, WHITE);
    EndDrawing();
}

void Game::Loop(void *self) {
    Game *client = static_cast<Game *>(self);

    client->Update();
    client->Render();
}

void Game::Run() {
    // no target FPS for web (performance)
    #ifdef __EMSCRIPTEN__
        emscripten_set_main_loop_arg(Loop, this, 0, 1);
    #else
        SetTargetFPS(60);
        while (!WindowShouldClose()) {
            Loop(this);
        }
    #endif
}
