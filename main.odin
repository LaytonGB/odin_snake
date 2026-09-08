package main

import "game"

main :: proc() {
	keep_playing := true
	game.play(&keep_playing)
}
