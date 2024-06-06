package util

import rl "vendor:raylib"
import "../lib"

// Returns a vector where x is width and y is height of text so that it fits within maxSize vector with font as close to fontSize (descending)
AssertTextFitsInViewport :: proc(text: cstring, fontSize: i32, maxSize: lib.Vector2i) -> lib.Vector2i {
    textW := rl.MeasureText(text, fontSize)
    fontSize := fontSize

    for textW > maxSize.x || fontSize > maxSize.y {
        fontSize -= 1
        textW = rl.MeasureText(text, fontSize)
    }

    return { textW, fontSize }
}
