package assets

import rl "vendor:raylib"
import cfg "../config"

Assets :: struct {
    apple: rl.Texture2D,
    head: rl.Texture2D,
    body: rl.Texture2D,

    bgm: rl.Music,

    eat: rl.Sound,
    lost: rl.Sound
}

Init :: proc() -> ^Assets {
    assets := new(Assets)

    assets.apple = rl.LoadTexture(cfg.APPLE_PATH)
    assets.head = rl.LoadTexture(cfg.HEAD_PATH)
    assets.body = rl.LoadTexture(cfg.BODY_PATH)

    assets.bgm = rl.LoadMusicStream(cfg.BGM_PATH)
    rl.SetMusicVolume(assets.bgm, cfg.MUSIC_VOLUME)

    assets.eat = rl.LoadSound(cfg.EAT_PATH)
    rl.SetSoundVolume(assets.eat, cfg.SOUND_VOLUME)
    assets.lost = rl.LoadSound(cfg.LOST_PATH)
    rl.SetSoundVolume(assets.lost, cfg.SOUND_VOLUME)

    return assets
}

Close :: proc(assets: ^Assets) {
    rl.UnloadTexture(assets.apple)
    rl.UnloadTexture(assets.head)
    rl.UnloadTexture(assets.body)

    rl.UnloadMusicStream(assets.bgm)

    rl.UnloadSound(assets.eat)
    rl.UnloadSound(assets.lost)

    free(assets)
}
