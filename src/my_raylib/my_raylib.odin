package my_raylib

import cfg "../config"
import rl "vendor:raylib"

Init :: proc() {
	rl.SetConfigFlags(cfg.WINDOW_FLAGS)
	rl.InitWindow(cfg.WINDOW_SIZE.x, cfg.WINDOW_SIZE.y, cfg.WINDOW_TITLE)
	rl.SetTargetFPS(cfg.WINDOW_TARGET_FPS)
	rl.SetExitKey(cfg.KEY_EXIT)
	rl.SetWindowMinSize(cfg.WINDOW_MIN_SIZE.x, cfg.WINDOW_MIN_SIZE.y)
	rl.SetWindowMaxSize(cfg.WINDOW_MAX_SIZE.x, cfg.WINDOW_MAX_SIZE.y)
	rl.InitAudioDevice()
}

Close :: proc() {
	rl.CloseAudioDevice()
	rl.CloseWindow()
}
