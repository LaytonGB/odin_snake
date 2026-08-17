package deque

Deque :: struct($N: i32, $T: typeid) where N >= 0 {
	data: [N]T,
	back_index: int,
	front_index: int,
}

new :: proc($N: i32, $T: typeid) -> (res: ^Deque(N, T))
	where N >= 0 {
	res.front_index = 1
	return
}

iter :: proc(deque: ^Deque($N, $T)) -> []T {
	return // TODO
}

push_back :: proc(deque: ^Deque($N, $T), value: T) -> bool {
	if deque_is_full(deque) {
		return false
	}

	deque.back_index = (deque.back_index + N - 1) % N
	deque.data[deque.back_index] = value
	return true
}

push_front :: proc(deque: ^Deque($N, $T), value: T) -> bool {
	if deque_is_full(deque) {
		return false
	}

	deque.data[deque.front_index] = value
	deque.front_index = (deque.front_index + 1) % N
	return true
}

pop_back :: proc(deque: ^Deque($N, $T)) -> (int, bool) {
	if deque_is_empty(deque) {
		return nil, false
	}

	res := deque.data[deque.back_index]
	deque.back_index = (deque.back_index + 1) % N
	return res, true
}

pop_front :: proc(deque: ^Deque($N, $T)) -> (int, bool) {
	if deque_is_empty(deque) {
		return nil, false
	}

	deque.front_index = (deque.front_index + N - 1) % N
	res := deque.data[deque.back_index]
	return res, true
}

is_empty :: proc(deque: ^Deque) -> bool {
	return deque_len(deque) == 0
}

is_full :: proc(deque: ^Deque($N, $T)) -> bool {
	return deque.front_index == back_index
}

len :: proc(deque: ^Deque($N, $T)) -> int {
	front := deque.back_index >= deque.front_index ? deque.front_index + N : deque.front_index
	return front - deque.back_index - 1
}

cap :: proc(deque: ^Deque($N, $T)) -> int {
	return N
}