package game

import rl "vendor:raylib"

Window :: struct {
	size, center:      Vec2,
	padding, safe_dim: i32,
}

get_center :: proc(size: Vec2) -> Vec2 {
	return size / 2
}

get_safe_size :: proc(size: Vec2, padding: i32) -> i32 {
	return min(size.x, size.y) - padding
}

init_window :: proc() -> Window {
	size := Vec2{1280, 720}
	padding: i32 = 30
	window := Window {
		size     = size,
		center   = get_center(size),
		padding  = padding,
		safe_dim = get_safe_size(size, padding),
	}
	rl.InitWindow(window.size.x, window.size.y, "My Odin + Raylib game")
	return window
}

close_window :: proc() {
	rl.CloseWindow()
}
