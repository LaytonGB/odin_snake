package main

import "deque"
import rl "vendor:raylib"

Grid_State :: enum {
	Empty,
	Food,
}

Vec2 :: [2]i32

GRID_SIZE: i32 : 11
GRID: [GRID_SIZE * GRID_SIZE]Grid_State

main :: proc() {
	// seconds_per_move := 1.0
	snake_positions := deque.new(GRID_SIZE * GRID_SIZE, Vec2)
	deque.push_front(&snake_positions, Vec2{GRID_SIZE / 2, GRID_SIZE / 2})

	window_size := Vec2{1280, 720}
	window_center := window_size / 2
	window_padding: i32 = 30
	window_min_safe := min(window_size.x, window_size.y) - window_padding
	rl.InitWindow(window_size[0], window_size[1], "My Odin + Raylib game")

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({100, 100, 100, 255})
		draw_snake(window_center, window_min_safe, &snake_positions)
		draw_game_board(window_center, window_min_safe)
		rl.EndDrawing()
	}

	rl.CloseWindow()
}

draw_game_board :: proc(center: Vec2, min_dimension: i32) {
	start := center - (min_dimension / 2)
	end := center + (min_dimension / 2)

	// horizontal lines
	for i in 0 ..= GRID_SIZE {
		rl.DrawLine(
			start.x,
			start.y + (i * min_dimension / GRID_SIZE),
			end.x,
			start.y + (i * min_dimension / GRID_SIZE),
			{255, 255, 255, 255},
		)
	}

	// vertical lines
	for i in 0 ..= GRID_SIZE {
		rl.DrawLine(
			start.x + (i * min_dimension / GRID_SIZE),
			start.y,
			start.x + (i * min_dimension / GRID_SIZE),
			end.y,
			{255, 255, 255, 255},
		)
	}
}

draw_snake :: proc(center: Vec2, min_dimension: i32, snake: ^deque.Deque($N, $T)) {
	start := center - (min_dimension / 2)

	for pos in deque.iter(snake) {
		rl.DrawRectangle(
			start.x + pos.x * min_dimension / GRID_SIZE,
			start.y + pos.y * min_dimension / GRID_SIZE,
			min_dimension / GRID_SIZE,
			min_dimension / GRID_SIZE,
			{150, 150, 150, 255},
		)
	}
}
