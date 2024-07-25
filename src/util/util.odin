package util

import "../lib"
import "core:fmt"
import rl "vendor:raylib"

// Returns a vector where x is width and y is height of text so that it fits within maxSize vector with font as close to fontSize (descending)
AssertTextFitsInViewport :: proc(
	text: cstring,
	fontSize: i32,
	maxSize: rl.Vector2,
) -> lib.Vector2i {
	textW := rl.MeasureText(text, fontSize)
	fontSize := fontSize

	for f32(textW) > maxSize.x || f32(fontSize) > maxSize.y {
		fontSize -= 1
		textW = rl.MeasureText(text, fontSize)
	}

	return {textW, fontSize}
}

ClearConsole :: proc() {
	fmt.println("\033[H\033[2J")
}
