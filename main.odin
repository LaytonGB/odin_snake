package main

import "core:fmt"
import "deque"
import rl "vendor:raylib"

Grid_State :: enum {
	Empty,
	Food,
}

Vec2 :: [2]i32
Vec2Zero :: Vec2{0, 0}

GRID_SIZE: i32 : 11
GRID: [GRID_SIZE * GRID_SIZE]Grid_State

main :: proc() {
	last_move_dir := Vec2Zero
	last_step_time: f64 = rl.GetTime()
	sec_per_move: f64 = 1.

	snake_positions := deque.new(GRID_SIZE * GRID_SIZE, Vec2)
	deque.push_front(&snake_positions, Vec2{GRID_SIZE / 2, GRID_SIZE / 2})

	window_size := Vec2{1280, 720}
	window_center := window_size / 2
	window_padding: i32 = 30
	window_min_safe := min(window_size.x, window_size.y) - window_padding
	rl.InitWindow(window_size[0], window_size[1], "My Odin + Raylib game")

	for !rl.WindowShouldClose() {
		// TODO generate goal pos

		// handle input and snake move
		if new_move_dir, has_last_input := get_last_input().?; has_last_input {
			last_move_dir = new_move_dir
		}
		if do_move_snake(last_step_time, sec_per_move) {
			next_pos := get_next_pos(&snake_positions, last_move_dir)
			if !is_in_bounds(next_pos) {
				end_game()
				return
			}
			move_snake(&snake_positions, next_pos)
			last_step_time = rl.GetTime()
		}

		// draw values
		rl.BeginDrawing()
		rl.ClearBackground({100, 100, 100, 255})
		draw_snake(window_center, window_min_safe, &snake_positions)
		draw_game_board(window_center, window_min_safe)

		rl.EndDrawing()
	}

	rl.CloseWindow()
}

move_snake :: proc(snake: ^deque.Deque($N, $T), next: Vec2) {
	deque.pop_back(snake)
	deque.push_front(snake, next)
}

end_game :: proc() {
	return // TODO main menu stuff
}

is_in_bounds :: proc(pos: Vec2) -> bool {
	return pos.x >= 0 && pos.x < GRID_SIZE && pos.y >= 0 && pos.y < GRID_SIZE
}

get_next_pos :: proc(snake: ^deque.Deque($N, $T), move_dir: Vec2) -> Vec2 {
	curr_square := deque.peek_front(snake).?
	if move_dir == Vec2Zero {
		prev_square, has_prev := deque.nth(snake, -2).?
		if !has_prev {
			return curr_square + Vec2{0, 1}
		}
		return curr_square * 2 - prev_square
	}

	next_square := curr_square + move_dir
	if prev, has_prev := deque.nth(snake, -2).?; has_prev && prev == next_square {
		next_square = curr_square - move_dir
	}
	return next_square
}

is_pos_out_of_bounds :: proc(pos: Vec2) -> bool {
	return pos.x < 0 || pos.x >= GRID_SIZE || pos.y < 0 || pos.y >= GRID_SIZE
}

do_move_snake :: proc(last_step_time, sec_per_move: f64) -> bool {
	return rl.GetTime() - last_step_time >= sec_per_move
}

get_last_input :: proc() -> Maybe(Vec2) {
	if rl.IsKeyDown(.UP) {
		return Vec2{0, -1}
	}
	if rl.IsKeyDown(.DOWN) {
		return Vec2{0, 1}
	}
	if rl.IsKeyDown(.LEFT) {
		return Vec2{-1, 0}
	}
	if rl.IsKeyDown(.RIGHT) {
		return Vec2{1, 0}
	}
	return nil
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
