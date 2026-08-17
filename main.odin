package main

import rl "vendor:raylib"
import "deque"

Grid_State :: enum {Empty, Food}

Vec2 :: [2]i32

GRID_SIZE : i32 : 11
GRID : [GRID_SIZE * GRID_SIZE]Grid_State

main :: proc() {
	seconds_per_move := 1.0
	snake_positions := deque.new(GRID_SIZE * GRID_SIZE, Vec2)

	window_size := Vec2{1280, 720}
	window_center := window_size / 2
	window_padding: i32 = 30
	rl.InitWindow(window_size[0], window_size[1], "My Odin + Raylib game")

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({100, 100, 100, 255})
		// draw_snake(window_center[0], window_center[1], min(window_size[0], window_size[1]) - window_padding, 10, )
		draw_game_board(window_center, min(window_size.x, window_size.y) - window_padding, GRID_SIZE)
		rl.EndDrawing()
	}

	rl.CloseWindow()
}

draw_game_board :: proc(center: Vec2, min_dimension, grid_size: i32) {
	start := center - (min_dimension / 2)
	end := center + (min_dimension / 2)

	// horizontal lines
	for i in 0..=grid_size {
		rl.DrawLine(
			start.x,
			start.y + (i * min_dimension / grid_size),
			end.x,
			start.y + (i * min_dimension / grid_size),
			{255, 255, 255, 255},
		)
	}

	// vertical lines
	for i in 0..=grid_size {
		rl.DrawLine(
			start.x + (i * min_dimension / grid_size),
			start.y,
			start.x + (i * min_dimension / grid_size),
			end.y,
			{255, 255, 255, 255},
		)
	}
}

draw_snake :: proc(center: Vec2, min_dimension, grid_size: i32, snake: $T/deque.Deque) {
	for pos in deque.iter(snake) {

	}
}