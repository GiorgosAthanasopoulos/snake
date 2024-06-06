package main

import rl "vendor:raylib"
import mlr "./my_raylib"
import "./snake"

main :: proc() {
    mlr.Init()
    game := snake.Init()

    for !rl.WindowShouldClose() {
        snake.Update(game)
        snake.Draw(game)
    }

    snake.Close(game)
    mlr.Close()
}
