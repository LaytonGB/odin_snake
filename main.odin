package main

import "game"

main :: proc() {
	state := game.State.PLAY

	window := game.init_window()

	for state == .PLAY {
		game.play(&state, window)
	}

	game.close_window()
}
