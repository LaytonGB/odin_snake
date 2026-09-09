package game

import "../deque"
import "../types"
import "../window"
import "core:math/rand"
import "core:strconv"
import rl "vendor:raylib"

Vec2 :: types.Vec2
Window :: window.Window

GRID_SIZE: i32 : 11

play :: proc(state: ^types.State, window: Window) {
	score: i64 = 0

	last_move_dir := Vec2{0, 1}
	last_step_time: f64 = rl.GetTime()
	sec_per_move: f64 = .7
	move_delay_modifier: f64 = .95

	food_position := get_random_grid_pos()
	snake_positions := deque.new(GRID_SIZE * GRID_SIZE, Vec2)
	deque.push_front(&snake_positions, Vec2{GRID_SIZE / 2, GRID_SIZE / 2})

	for state^ == .PLAY {
		// handle input and snake move
		if new_move_dir, has_last_input := get_input_vector().?; has_last_input {
			if is_input_valid(&snake_positions, new_move_dir) {
				last_move_dir = new_move_dir
			}
		}
		if do_move_snake(last_step_time, sec_per_move) {
			next_pos := get_next_pos(&snake_positions, last_move_dir)
			if !is_in_bounds(next_pos) || is_pos_in_snake(&snake_positions, next_pos) {
				state^ = .LOSE
				return
			}
			move_snake(&snake_positions, next_pos)
			last_step_time = rl.GetTime()
		}

		// generate food pos
		if is_snake_head_in_pos(&snake_positions, food_position) {
			grow_snake(&snake_positions)
			score = i64(f64(score) * 1.2 + 1)
			sec_per_move *= move_delay_modifier
			food_position = get_random_grid_pos()
		}

		// draw values
		rl.BeginDrawing()
		rl.ClearBackground({100, 100, 100, 255})
		draw_snake(window.center, window.safe_dim, &snake_positions)
		draw_food(window.center, window.safe_dim, food_position)
		draw_game_board(window.center, window.safe_dim)
		draw_score(score, window.padding)

		rl.EndDrawing()
	}
}

draw_score :: proc(score: i64, padding: i32) {
	score_text_buf: [128]byte
	strconv.write_int(score_text_buf[:], score, 10)
	ptr: [^]byte = raw_data(score_text_buf[:])
	cstr := cstring(ptr)
	rl.DrawText(cstr, padding, padding, 24, {150, 150, 150, 255})
}

is_input_valid :: proc(snake: ^deque.Deque($N, Vec2), move: Vec2) -> bool {
	prev_pos, has_prev_pos := deque.nth(snake, -2).?
	if !has_prev_pos {
		return true
	}

	current_pos := deque.peek_front(snake).?
	next_pos := current_pos + move
	return next_pos != prev_pos
}

is_pos_in_snake :: proc(snake: ^deque.Deque($N, Vec2), pos: Vec2) -> bool {
	// cant enter self at lengths < 5
	if deque.len(snake) < 5 {
		return false
	}

	snake_positions := deque.iter(snake)
	// skip fist two: cant enter them
	// skip last: movement not yet applied, so it wont be there when we move into that square
	return is_pos_in_list(snake_positions[3:len(snake_positions) - 1], pos)
}

is_pos_in_list :: proc(list: []Vec2, pos: Vec2) -> bool {
	for pos2 in list {
		if pos2 == pos {
			return true
		}
	}
	return false
}

grow_snake :: proc(snake: ^deque.Deque($N, Vec2)) {
	first_pos := deque.peek_back(snake).?
	deque.push_back(snake, first_pos)
}

is_snake_head_in_pos :: proc(snake: ^deque.Deque($N, Vec2), pos: Vec2) -> bool {
	return deque.peek_front(snake).? == pos
}

get_random_grid_pos :: proc() -> Vec2 {
	return Vec2{rand.int32_range(0, GRID_SIZE), rand.int32_range(0, GRID_SIZE)}
}

move_snake :: proc(snake: ^deque.Deque($N, Vec2), next: Vec2) {
	deque.pop_back(snake)
	deque.push_front(snake, next)
}

is_in_bounds :: proc(pos: Vec2) -> bool {
	return pos.x >= 0 && pos.x < GRID_SIZE && pos.y >= 0 && pos.y < GRID_SIZE
}

get_next_pos :: proc(snake: ^deque.Deque($N, Vec2), move_dir: Vec2) -> Vec2 {
	curr_square := deque.peek_front(snake).?
	next_square := curr_square + move_dir
	return next_square
}

is_pos_out_of_bounds :: proc(pos: Vec2) -> bool {
	return pos.x < 0 || pos.x >= GRID_SIZE || pos.y < 0 || pos.y >= GRID_SIZE
}

do_move_snake :: proc(last_step_time, sec_per_move: f64) -> bool {
	return rl.GetTime() - last_step_time >= sec_per_move
}

get_input_vector :: proc() -> Maybe(Vec2) {
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

draw_food :: proc(center: Vec2, min_dimension: i32, pos: Vec2) {
	start := center - (min_dimension / 2)
	margin_percent: i32 = 10

	rl.DrawRectangle(
		start.x +
		pos.x * min_dimension / GRID_SIZE +
		min_dimension * margin_percent / (100 * GRID_SIZE),
		start.y +
		pos.y * min_dimension / GRID_SIZE +
		min_dimension * margin_percent / (100 * GRID_SIZE),
		min_dimension / GRID_SIZE - min_dimension * (margin_percent * 2) / (100 * GRID_SIZE),
		min_dimension / GRID_SIZE - min_dimension * (margin_percent * 2) / (100 * GRID_SIZE),
		{180, 80, 30, 255},
	)
}

draw_snake :: proc(center: Vec2, min_dimension: i32, snake: ^deque.Deque($N, Vec2)) {
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
