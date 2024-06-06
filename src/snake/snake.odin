package snake

import rl "vendor:raylib"
import cfg "../config"
import "../lib"
import "../util"

// TODO: Add bgm, sfx, apple/snake sprites?

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
    score: i32
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
            game.direction = .UP
        } else if rl.IsKeyPressed(cfg.KEY_MOVE_DOWN) || rl.IsKeyPressed(cfg.KEY_MOVE_DOWN_2) || rl.IsKeyPressed(cfg.KEY_MOVE_DOWN_3) {
            game.direction = .DOWN
        } else if rl.IsKeyPressed(cfg.KEY_MOVE_LEFT) ||  rl.IsKeyPressed(cfg.KEY_MOVE_LEFT_2) || rl.IsKeyPressed(cfg.KEY_MOVE_LEFT_3) {
            game.direction = .LEFT
        } else if rl.IsKeyPressed(cfg.KEY_MOVE_RIGHT) || rl.IsKeyPressed(cfg.KEY_MOVE_RIGHT_2) || rl.IsKeyPressed(cfg.KEY_MOVE_RIGHT_3) {
            game.direction = .RIGHT
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
                game.lost = true
            }
        case .DOWN:
            if game.snake[0].y == cfg.TILE_AMOUNT_AXIS {
                game.lost = true
            }
        case .LEFT:
            if game.snake[0].x == -1 {
                game.lost = true
            }
        case .RIGHT:
            if game.snake[0].x == cfg.TILE_AMOUNT_AXIS {
                game.lost = true
            }
        case .NONE:
            break
    }
}

HandleRestart :: proc(game: ^Snake) {
    clear(&game.snake)
    append(&game.snake, cfg.DEFAULT_HEAD_POSITION)
    game.direction = .NONE
    game.timerMove = cfg.TIMER_MOVE
    game.lost = false
    game.score = 0
}

HandleCollisions :: proc(game: ^Snake) {
    if game.snake[0].x == game.apple.x && game.snake[0].y == game.apple.y {
        HandleSpawnApple(game)
        game.incrementTail = true
    }
    for i := 1; i < len(game.snake); i += 1 {
        if game.snake[0].x == game.snake[i].x && game.snake[0].y == game.snake[i].y {
            game.lost = true
        }
    }
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
}

DrawSnake :: proc(game: ^Snake) {
    color := cfg.COLOR_HEAD
    for i := 0; i < len(game.snake); i += 1 {
        rl.DrawRectangle(game.snake[i].x * game.tileSize.x, game.snake[i].y * game.tileSize.y, game.tileSize.x, game.tileSize.y, color)
        if i == 0 {
            color = cfg.COLOR_BODY
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
}

DrawApple :: proc(game: ^Snake) {
    rl.DrawRectangle(game.apple.x * game.tileSize.x,
                  game.apple.y * game.tileSize.y,
                  game.tileSize.x,
                  game.tileSize.y,
                 cfg.COLOR_APPLE)
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
    free(game)
}
