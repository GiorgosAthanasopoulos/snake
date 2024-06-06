package snake

import rl "vendor:raylib"
import cfg "../config"
import "../lib"
import "../util"
import "../assets"

// TODO: Add bgm, sfx

Snake :: struct {
    debug: bool,

    winSize: lib.Vector2i,
    tileSize: lib.Vector2i,

    snake: [dynamic]lib.Vector2i,
    incrementTail: bool,
    apple: lib.Vector2i,

    direction: lib.Direction,
    timerMove: f32,

    lost: bool,
    score: i32,

    assets: ^assets.Assets
}

Init :: proc() -> ^Snake {
    game := new(Snake)

    game.debug = cfg.DEBUG_DEFAULT_ON
    game.winSize = { cfg.WINDOW_SIZE.x, cfg.WINDOW_SIZE.y }
    game.tileSize = { game.winSize.x / cfg.TILE_AMOUNT_AXIS, game.winSize.y / cfg.TILE_AMOUNT_AXIS }
    game.snake = make([dynamic]lib.Vector2i)
    append(&game.snake, cfg.DEFAULT_HEAD_POSITION)
    game.direction = cfg.DEFAULT_DIRECTION
    game.timerMove = cfg.TIMER_MOVE
    game.lost = false
    game.score = 0
    HandleSpawnApple(game)
    game.incrementTail = false
    game.assets = assets.Init()

    rl.PlayMusicStream(game.assets.bgm)

    return game
}

HandleSpawnApple :: proc(game: ^Snake) {
    outer_for: for true {
        new_apple_pos: lib.Vector2i = { rl.GetRandomValue(0, cfg.TILE_AMOUNT_AXIS - 1), rl.GetRandomValue(0, cfg.TILE_AMOUNT_AXIS - 1) }

        for i := 0; i <len(game.snake); i += 1 {
            if new_apple_pos.x == game.snake[i].x && new_apple_pos.y == game.snake[i].y {
                continue outer_for
            }
        }

        game.apple = new_apple_pos
        return
    }
}

HandleResize :: proc(game: ^Snake) {
    game.winSize = { rl.GetRenderWidth(), rl.GetRenderHeight() }
    game.tileSize = { game.winSize.x / cfg.TILE_AMOUNT_AXIS, game.winSize.y / cfg.TILE_AMOUNT_AXIS }
}

HandleKeybinds :: proc(game: ^Snake) {
        if rl.IsKeyPressed(cfg.KEY_MOVE_UP) || rl.IsKeyPressed(cfg.KEY_MOVE_UP_2) || rl.IsKeyPressed(cfg.KEY_MOVE_UP_3) {
            if game.direction != .DOWN || cfg.ALLOW_TURNING_OPPOSITE_WAY_SUICIDE {
                game.direction = .UP
            }
        } else if rl.IsKeyPressed(cfg.KEY_MOVE_DOWN) || rl.IsKeyPressed(cfg.KEY_MOVE_DOWN_2) || rl.IsKeyPressed(cfg.KEY_MOVE_DOWN_3) {
            if game.direction != .UP || cfg.ALLOW_TURNING_OPPOSITE_WAY_SUICIDE {
                game.direction = .DOWN
            }
        } else if rl.IsKeyPressed(cfg.KEY_MOVE_LEFT) ||  rl.IsKeyPressed(cfg.KEY_MOVE_LEFT_2) || rl.IsKeyPressed(cfg.KEY_MOVE_LEFT_3) {
            if game.direction != .RIGHT || cfg.ALLOW_TURNING_OPPOSITE_WAY_SUICIDE {
                game.direction = .LEFT
            }
        } else if rl.IsKeyPressed(cfg.KEY_MOVE_RIGHT) || rl.IsKeyPressed(cfg.KEY_MOVE_RIGHT_2) || rl.IsKeyPressed(cfg.KEY_MOVE_RIGHT_3) {
            if game.direction != .LEFT || cfg.ALLOW_TURNING_OPPOSITE_WAY_SUICIDE {
                game.direction = .RIGHT
            }
        }
}

HandleMoving :: proc(game: ^Snake) {
    game.timerMove -= rl.GetFrameTime()
    if game.timerMove <= 0 {
        game.timerMove = cfg.TIMER_MOVE
        switch game.direction {
        case .UP:
            inject_at(&game.snake, 0, lib.Vector2i { game.snake[0].x, game.snake[0].y - 1 })
        case .DOWN:
            inject_at(&game.snake, 0, lib.Vector2i { game.snake[0].x, game.snake[0].y + 1 })
        case .LEFT:
            inject_at(&game.snake, 0, lib.Vector2i { game.snake[0].x - 1, game.snake[0].y })
        case .RIGHT:
            inject_at(&game.snake, 0, lib.Vector2i { game.snake[0].x + 1, game.snake[0].y })
        case .NONE:
            break
        }
        if game.direction != .NONE {
            if game.incrementTail {
                game.incrementTail = false
            } else {
                pop(&game.snake)
            }
        }
    }
}

HandleOutOfBoundaries :: proc(game: ^Snake) {
    switch game.direction {
        case .UP:
            if game.snake[0].y == -1 {
                if !cfg.ALLOW_SNAKE_WRAP_THROUGH_BORDER {
                    game.lost = true
                } else {
                    game.snake[0] = {game.snake[0].x, cfg.TILE_AMOUNT_AXIS - 1}
                }
            }
        case .DOWN:
            if game.snake[0].y == cfg.TILE_AMOUNT_AXIS {
                if !cfg.ALLOW_SNAKE_WRAP_THROUGH_BORDER {
                    game.lost = true
                } else {
                    game.snake[0] = {game.snake[0].x, 0}
                }
            }
        case .LEFT:
            if game.snake[0].x == -1 {
                if !cfg.ALLOW_SNAKE_WRAP_THROUGH_BORDER {
                    game.lost = true
                } else {
                    game.snake[0] = {cfg.TILE_AMOUNT_AXIS - 1, game.snake[0].y}
                }
            }
        case .RIGHT:
            if game.snake[0].x == cfg.TILE_AMOUNT_AXIS {
                if !cfg.ALLOW_SNAKE_WRAP_THROUGH_BORDER {
                    game.lost = true
                } else {
                    game.snake[0] = {0, game.snake[0].y}
                }
            }
        case .NONE:
            break
    }

    if game.lost {
        rl.StopMusicStream(game.assets.bgm)
        rl.PlaySound(game.assets.lost)
    }
}

HandleRestart :: proc(game: ^Snake) {
    clear(&game.snake)
    append(&game.snake, cfg.DEFAULT_HEAD_POSITION)
    game.direction = .NONE
    game.timerMove = cfg.TIMER_MOVE
    game.lost = false
    game.score = 0
    HandleSpawnApple(game)
    if !rl.IsMusicStreamPlaying(game.assets.bgm) {
        rl.PlayMusicStream(game.assets.bgm)
    }
}

HandleCollisions :: proc(game: ^Snake) {
    if game.snake[0].x == game.apple.x && game.snake[0].y == game.apple.y {
        rl.PlaySound(game.assets.eat)
        HandleSpawnApple(game)
        game.incrementTail = true
    }
    for i := 1; i < len(game.snake); i += 1 {
        if game.snake[0].x == game.snake[i].x && game.snake[0].y == game.snake[i].y {
            game.lost = true
            rl.StopMusicStream(game.assets.bgm)
            rl.PlaySound(game.assets.lost)
        }
    }
}

HandleMusic :: proc(game:^Snake) {
    if rl.IsKeyPressed(cfg.KEY_MUTE) {
        if rl.IsMusicStreamPlaying(game.assets.bgm) {
            rl.PauseMusicStream(game.assets.bgm)
        } else {
            rl.ResumeMusicStream(game.assets.bgm)
        }
    }

    rl.UpdateMusicStream(game.assets.bgm)
}

Update :: proc(game: ^Snake) {
    if rl.IsWindowResized() {
        HandleResize(game)
    }

    if !game.lost {
        HandleKeybinds(game)
        HandleMoving(game)
        HandleOutOfBoundaries(game)
        HandleCollisions(game)
    }

    if rl.IsKeyPressed(cfg.KEY_RESTART) {
        HandleRestart(game)
    }

    if rl.IsKeyPressed(cfg.KEY_TOGGLE_DEBUG) {
        game.debug = !game.debug
    }

    HandleMusic(game)
}

DrawSnake :: proc(game: ^Snake) {
    texture := game.assets.head
    tint := cfg.COLOR_HEAD_TINT
    for i := 0; i < len(game.snake); i += 1 {
        rl.DrawTexturePro(texture, {0, 0, f32(texture.width), f32(texture.height)},
                          {f32(game.snake[i].x * game.tileSize.x),
                           f32(game.snake[i].y * game.tileSize.y),
                           f32(game.tileSize.x),
                           f32(game.tileSize.y)},
                            {0, 0}, 0, tint)
        if i == 0 {
            texture = game.assets.body
            tint = cfg.COLOR_BODY_TINT
        }
    }
}

DrawLost :: proc(game: ^Snake) {
    textSize := util.AssertTextFitsInViewport(cfg.YOU_LOST_TEXT, cfg.DEFAULT_FONT_SIZE, { game.winSize.x - game.winSize.x / cfg.TEXT_SIZE_TO_WINDOW_RATIO, game.winSize.y - game.winSize.y / cfg.TEXT_SIZE_TO_WINDOW_RATIO })
    rl.DrawText(cfg.YOU_LOST_TEXT, game.winSize.x / 2 - textSize.x / 2, game.winSize.y / 2 - textSize.y / 2, textSize.y, cfg.COLOR_TEXT)
}

DrawDebug :: proc(game: ^Snake) {
    for x: i32 = 0; x < cfg.TILE_AMOUNT_AXIS; x += 1 {
        for y: i32 = 0; y < cfg.TILE_AMOUNT_AXIS; y += 1 {
            rl.DrawRectangleLinesEx({ f32(x * game.tileSize.x), f32(y * game.tileSize.y), f32(game.tileSize.x), f32(game.tileSize.y) }, cfg.COLLISION_RECTS_THICKNESS, cfg.COLOR_COLLISION_RECTS);
        }
    }

    rl.DrawFPS(cfg.DEBUG_FPS_POS.x, cfg.DEBUG_FPS_POS.y)

    textSize := util.AssertTextFitsInViewport(cfg.DEBUG_TEXT, cfg.DEFAULT_FONT_SIZE, { game.winSize.x / cfg.DEBUG_TEXT_SIZE_TO_WINDOW_RATIO, game.winSize.y / cfg.DEBUG_TEXT_SIZE_TO_WINDOW_RATIO })
    rl.DrawText(cfg.DEBUG_TEXT, game.winSize.x - textSize.x - cfg.DEBUG_TEXT_PADDING, game.winSize.y - textSize.y, textSize.y, cfg.COLOR_TEXT)

    text :=  cfg.DIRECTION_NONE_TEXT
    switch game.direction {
    case .UP:
        text = cfg.DIRECTION_UP_TEXT
    case .DOWN:
        text = cfg.DIRECTION_DOWN_TEXT
    case .LEFT:
        text = cfg.DIRECTION_LEFT_TEXT
    case .RIGHT:
        text = cfg.DIRECTION_RIGHT_TEXT
    case .NONE:
        break
    }
    textSize = util.AssertTextFitsInViewport(text, cfg.DEFAULT_FONT_SIZE, { game.winSize.x / (cfg.DEBUG_TEXT_SIZE_TO_WINDOW_RATIO / 3), game.winSize.y / (cfg.DEBUG_TEXT_SIZE_TO_WINDOW_RATIO / 3) })
    rl.DrawText(text, cfg.DEBUG_DIRECTION_TEXT_X_PADDING, game.winSize.y - textSize.y, textSize.y, cfg.COLOR_TEXT)

    wrapSizeY: i32
    if cfg.ALLOW_SNAKE_WRAP_THROUGH_BORDER {
        text :: "Wrap: True"
        textSize = util.AssertTextFitsInViewport(text, cfg.DEFAULT_FONT_SIZE, { game.winSize.x / cfg.DEBUG_TEXT_SIZE_TO_WINDOW_RATIO, game.winSize.y / cfg.DEBUG_TEXT_SIZE_TO_WINDOW_RATIO })
        wrapSizeY = textSize.y
        rl.DrawText(text, game.winSize.x - textSize.x - cfg.DEBUG_TEXT_PADDING, cfg.DEBUG_TEXT_PADDING, textSize.y, cfg.COLOR_TEXT)
    } else {
        text :: "Wrap: False"
        textSize = util.AssertTextFitsInViewport(text, cfg.DEFAULT_FONT_SIZE, { game.winSize.x / cfg.DEBUG_TEXT_SIZE_TO_WINDOW_RATIO, game.winSize.y / cfg.DEBUG_TEXT_SIZE_TO_WINDOW_RATIO })
        wrapSizeY = textSize.y
        rl.DrawText(text, game.winSize.x - textSize.x - cfg.DEBUG_TEXT_PADDING, cfg.DEBUG_TEXT_PADDING, textSize.y, cfg.COLOR_TEXT)
    }

    if cfg.ALLOW_TURNING_OPPOSITE_WAY_SUICIDE {
        text :: "Move Opposite: True"
        textSize = util.AssertTextFitsInViewport(text, cfg.DEFAULT_FONT_SIZE, { game.winSize.x / (cfg.DEBUG_TEXT_SIZE_TO_WINDOW_RATIO / 3), game.winSize.y / (cfg.DEBUG_TEXT_SIZE_TO_WINDOW_RATIO / 3) })
        rl.DrawText(text, game.winSize.x - textSize.x - cfg.DEBUG_TEXT_PADDING, wrapSizeY + cfg.DEBUG_TEXT_PADDING, textSize.y, cfg.COLOR_TEXT)
    } else {
        text :: "Move Opposite: False"
        textSize = util.AssertTextFitsInViewport(text, cfg.DEFAULT_FONT_SIZE, { game.winSize.x / (cfg.DEBUG_TEXT_SIZE_TO_WINDOW_RATIO / 3), game.winSize.y / (cfg.DEBUG_TEXT_SIZE_TO_WINDOW_RATIO / 3) })
        rl.DrawText(text, game.winSize.x - textSize.x - cfg.DEBUG_TEXT_PADDING, wrapSizeY + cfg.DEBUG_TEXT_PADDING, textSize.y, cfg.COLOR_TEXT)
    }
}

DrawApple :: proc(game: ^Snake) {
    rl.DrawTexturePro(game.assets.apple, {0, 0, f32(game.assets.apple.width),
                                          f32(game.assets.apple.height)},
                      {f32(game.apple.x * game.tileSize.x),
                       f32(game.apple.y * game.tileSize.y),
                       f32(game.tileSize.x),
                       f32(game.tileSize.y)},
                      {0, 0}, 0, cfg.COLOR_APPLE_TINT)
}

Draw :: proc(game: ^Snake) {
    rl.BeginDrawing()
    rl.ClearBackground(cfg.COLOR_BG)

    DrawSnake(game)
    DrawApple(game)

    if game.lost {
        DrawLost(game)
    }

    if game.debug {
        DrawDebug(game)
    }

    rl.EndDrawing()
}

Close :: proc(game: ^Snake) {
    assets.Close(game.assets)
    free(game)
}
