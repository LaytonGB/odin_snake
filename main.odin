package main

import "game"
import "types"
import rl "vendor:raylib"
import "window"

State :: struct {
	prev_state, curr_state: types.State,
	last_state_change_time: f64,
	game_state:             game.State,
}

main :: proc() {
	state := State {
		prev_state             = types.State.Exit,
		curr_state             = types.State.Play,
		last_state_change_time = rl.GetTime(),
	}

	w := window.init_window()

	loop: for state.curr_state != .Exit {
		if rl.IsKeyDown(.ESCAPE) {
			break
		}

		#partial switch state.curr_state {
		case .Play:
			if state.prev_state != .Play {
				state.game_state = game.init(w)
			}
			new_state := game.play(w, &state.game_state)
			set_state(&state, new_state)
		case:
			break loop
		}
	}

	window.close_window()
}

set_state :: proc(state: ^State, new_state: types.State) {
	state.prev_state = state.curr_state
	state.curr_state = new_state
	state.last_state_change_time = rl.GetTime()
}
