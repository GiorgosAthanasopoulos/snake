package main

import mlr "./my_raylib"
import "./snake"
import rl "vendor:raylib"

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
