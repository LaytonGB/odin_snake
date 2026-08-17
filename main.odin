package main

import rl "vendor:raylib"

Grid_State :: enum {Empty, Food}

Vec2 :: [2]i32

GRID_SIZE : i32 : 10
GRID : [GRID_SIZE * GRID_SIZE]Grid_State

draw_game_board :: proc(center_x, center_y, min_dimension, grid_size: i32) {
	zero_x := center_x - (minDimension / 2)
	zero_y := center_y - (minDimension / 2)
	step := min_dimension / grid_size

	// horizontal lines
	for i in 0..=grid_size {
		rl.DrawLine(zero_x, zero_y + (i * step), zero_x + min_dimension, zero_y + (i * step), {255, 255, 255, 255})
	}

	// vertical lines
	for i in 0..=gridSize {
		rl.DrawLine(zero_x + (i * step), zero_y, zero_x + (i * step), zero_y + min_dimension, {255, 255, 255, 255})
	}
}

main :: proc() {
	seconds_per_move := 1.0
	snake_positions := [dynamic; GRID_SIZE * GRID_SIZE]int

	window_size := Vec2{1280, 720}
	window_center := window_size / 2
	window_padding: i32 = 30
	rl.InitWindow(window_size[0], window_size[1], "My Odin + Raylib game")

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({100, 100, 100, 255})
		draw_snake(window_center[0], window_center[1], min(window_size[0], window_size[1]) - window_padding, 10, )
		draw_game_board(window_center[0], window_center[1], min(window_size[0], window_size[1]) - window_padding, GRID_SIZE)
		rl.EndDrawing()
	}

	rl.CloseWindow()
}