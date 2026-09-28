#+feature using-stmt

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

window: Window

State :: struct {
	score:               i64,
	score_buf:           [128]byte,
	last_move_dir:       Vec2,
	last_step_time:      f64,
	sec_per_move:        f64,
	move_delay_modifier: f64,
	food_position:       Vec2,
	snake_positions:     deque.Deque(GRID_SIZE * GRID_SIZE, Vec2),
}

init :: proc(window: Window) -> State {
	snake_positions := deque.new(GRID_SIZE * GRID_SIZE, Vec2)
	deque.push_front(&snake_positions, Vec2{GRID_SIZE / 2, GRID_SIZE / 2})

	return State {
		score = 0,
		score_buf = [128]byte{},
		last_move_dir = Vec2{0, 1},
		last_step_time = rl.GetTime(),
		sec_per_move = .7,
		move_delay_modifier = .95,
		food_position = get_random_grid_pos(),
		snake_positions = snake_positions,
	}
}

play :: proc(window: Window, state: ^State) -> types.State {
	// handle input and snake move
	if new_move_dir, has_last_input := get_input_vector().?; has_last_input {
		if is_input_valid(&state.snake_positions, new_move_dir) {
			state.last_move_dir = new_move_dir
		}
	}
	if do_move_snake(state.last_step_time, state.sec_per_move) {
		next_pos := get_next_pos(&state.snake_positions, state.last_move_dir)
		if !is_in_bounds(next_pos) || is_pos_in_snake(&state.snake_positions, next_pos) {
			return .Lose
		}
		move_snake(&state.snake_positions, next_pos)
		state.last_step_time = rl.GetTime()
	}

	// generate food pos
	if is_snake_head_in_pos(&state.snake_positions, state.food_position) {
		grow_snake(&state.snake_positions)
		state.score = i64(f64(state.score) * 1.2 + 1)
		set_score_buf(state.score_buf[:], state.score)
		state.sec_per_move *= state.move_delay_modifier
		state.food_position = get_random_grid_pos()
	}

	// draw values
	rl.BeginDrawing()
	rl.ClearBackground({100, 100, 100, 255})
	draw_snake(window.center, window.safe_dim, &state.snake_positions)
	draw_food(window.center, window.safe_dim, state.food_position)
	draw_game_board(window.center, window.safe_dim)
	score_cstr := get_score_cstr(state.score_buf[:])
	draw_score(score_cstr, {window.padding, window.padding}, 24)
	rl.EndDrawing()

	return .Play
}

SCORE_POSITION_TRANSITION_DURATION_ON_LOSS: f32 : 2.0
SCORE_FONT_SIZE: i32 : 100

lose :: proc(window: Window, state: ^State) -> types.State {
	rl.BeginDrawing()

	// draw board
	rl.ClearBackground({100, 100, 100, 255})
	draw_snake(window.center, window.safe_dim, &state.snake_positions)
	draw_food(window.center, window.safe_dim, state.food_position)
	draw_game_board(window.center, window.safe_dim)

	score_cstr := get_score_cstr(state.score_buf[:])
	text_width := rl.MeasureText(score_cstr, SCORE_FONT_SIZE)

	// draw score
	rl.DrawRectangleRounded(
		rl.Rectangle {
			f32(window.center.x / 2),
			f32(window.center.y * 2 / 3),
			f32(window.center.x),
			f32(window.center.y * 2 / 3),
		},
		24.0,
		12,
		{80, 80, 80, 200},
	)
	draw_score(
		score_cstr,
		{window.center.x - text_width / 2, window.center.y - SCORE_FONT_SIZE / 2},
		SCORE_FONT_SIZE,
	)

	rl.EndDrawing()

	return .Lose
}

set_score_buf :: proc(buf: []byte, score: i64) {
	strconv.write_int(buf, score, 10)
}

get_score_cstr :: proc(buf: []byte) -> cstring {
	ptr: [^]byte = raw_data(buf[:])
	return cstring(ptr)
}

draw_score :: proc(cstr: cstring, position: [2]i32, size: i32) {
	rl.DrawText(cstr, position.x, position.y, size, {150, 150, 150, 255})
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
