package main

import rl "vendor:raylib"

Vec2 :: [2]i32

drawGameBoard :: proc(centerX, centerY, minDimension, gridSize: i32) {
  zeroX := centerX - (minDimension / 2)
  zeroY := centerY - (minDimension / 2)
  step := minDimension / gridSize

  // horizontal lines
  for i in 0..=gridSize {
    rl.DrawLine(zeroX, zeroY + (i * step), zeroX + minDimension, zeroY + (i * step), {255, 255, 255, 255})
  }

  // vertical lines
  for i in 0..=gridSize {
    rl.DrawLine(zeroX + (i * step), zeroY, zeroX + (i * step), zeroY + minDimension, {255, 255, 255, 255})
  }
}

main :: proc() {
  windowSize := Vec2{1280, 720}
  windowCenter := windowSize / 2
  windowPadding: i32 = 30
	rl.InitWindow(windowSize[0], windowSize[1], "My Odin + Raylib game")

  for !rl.WindowShouldClose() {
    rl.BeginDrawing()
    rl.ClearBackground({100, 100, 100, 255})
    drawGameBoard(windowCenter[0], windowCenter[1], min(windowSize[0], windowSize[1]) - windowPadding, 10)
    rl.EndDrawing()
  }

  rl.CloseWindow()
}