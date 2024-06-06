package config

import rl "vendor:raylib"
import "../lib"

WINDOW_FLAGS : rl.ConfigFlags : { .WINDOW_RESIZABLE }
WINDOW_SIZE: lib.Vector2i : { 1280, 720 }
WINDOW_TITLE :: "Snake"
WINDOW_TARGET_FPS :: 60
WINDOW_MIN_SIZE: lib.Vector2i : { 640, 360 }
WINDOW_MAX_SIZE: lib.Vector2i : { 3840, 2160 }

KEY_EXIT : rl.KeyboardKey : .KEY_NULL
KEY_TOGGLE_DEBUG: rl.KeyboardKey : .F2
KEY_MOVE_UP: rl.KeyboardKey : .UP
KEY_MOVE_DOWN: rl.KeyboardKey : .DOWN
KEY_MOVE_LEFT: rl.KeyboardKey : .LEFT
KEY_MOVE_RIGHT: rl.KeyboardKey : .RIGHT
KEY_MOVE_UP_2: rl.KeyboardKey : .W
KEY_MOVE_DOWN_2: rl.KeyboardKey : .S
KEY_MOVE_LEFT_2: rl.KeyboardKey : .A
KEY_MOVE_RIGHT_2: rl.KeyboardKey : .D
KEY_MOVE_UP_3: rl.KeyboardKey : .K
KEY_MOVE_DOWN_3: rl.KeyboardKey : .J
KEY_MOVE_LEFT_3: rl.KeyboardKey : .H
KEY_MOVE_RIGHT_3: rl.KeyboardKey : .L
KEY_RESTART: rl.KeyboardKey : .R

DEFAULT_FONT_SIZE :: 1000
COLLISION_RECTS_THICKNESS :: 1.0
TILE_AMOUNT_AXIS :: 16
DEFAULT_HEAD_POSITION: lib.Vector2i = { TILE_AMOUNT_AXIS / 2, TILE_AMOUNT_AXIS / 2 }
TIMER_MOVE: f32 : 0.25
TEXT_SIZE_TO_WINDOW_RATIO :: 3
YOU_LOST_TEXT: cstring = "You lost!"
DIRECTION_NONE_TEXT: cstring = "Direction: None"
DIRECTION_UP_TEXT: cstring = "Direction: Up"
DIRECTION_DOWN_TEXT: cstring = "Direction: Down"
DIRECTION_LEFT_TEXT: cstring = "Direction: Left"
DIRECTION_RIGHT_TEXT: cstring = "Direction: Right"
DEFAULT_DIRECTION: lib.Direction : .NONE

COLOR_BG :: rl.BLACK
COLOR_COLLISION_RECTS :: rl.RED
COLOR_TEXT :: rl.GREEN
COLOR_HEAD :: rl.GREEN
COLOR_BODY :: rl.LIME
COLOR_APPLE :: rl.RED

DEBUG_FPS_POS: lib.Vector2i : {0, 0}
DEBUG_TEXT: cstring = "DEBUG"
DEBUG_TEXT_PADDING :: 5
DEBUG_TEXT_SIZE_TO_WINDOW_RATIO :: 10
DEBUG_DEFAULT_ON :: false
DEBUG_DIRECTION_TEXT_X_PADDING :: 5
