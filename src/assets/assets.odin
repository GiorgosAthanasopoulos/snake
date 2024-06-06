package assets

import rl "vendor:raylib"
import cfg "../config"

Assets :: struct {
    apple: rl.Texture2D,
    head: rl.Texture2D,
    body: rl.Texture2D
}

Init :: proc() -> ^Assets {
    assets := new(Assets)

    assets.apple = rl.LoadTexture(cfg.APPLE_PATH)
    assets.head = rl.LoadTexture(cfg.HEAD_PATH)
    assets.body = rl.LoadTexture(cfg.BODY_PATH)

    return assets
}

Close :: proc(assets: ^Assets) {
    rl.UnloadTexture(assets.apple)
    rl.UnloadTexture(assets.head)
    rl.UnloadTexture(assets.body)

    free(assets)
}
