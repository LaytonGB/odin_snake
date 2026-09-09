package main

import "game"
import "types"
import "window"

main :: proc() {
	state := types.State.PLAY

	w := window.init_window()

	for state == .PLAY {
		game.play(&state, w)
	}

	window.close_window()
}
