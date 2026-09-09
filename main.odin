package main

import "game"
import "types"
import rl "vendor:raylib"
import "window"

main :: proc() {
	prev_state := types.State.Exit
	state := types.State.Play
	game_state: game.Game_State

	w := window.init_window()

	loop: for state != .Exit {
		if rl.IsKeyDown(.ESCAPE) {
			break
		}

		#partial switch state {
		case .Play:
			if prev_state != .Play {
				game_state = game.init(w)
			}
			new_state := game.play(w, &game_state)
			set_state(&prev_state, &state, new_state)
		case:
			break loop
		}
	}

	window.close_window()
}

set_state :: proc(prev_state, state: ^types.State, new_state: types.State) {
	prev_state^ = state^
	state^ = new_state
}
