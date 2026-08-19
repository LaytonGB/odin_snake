package deque

Deque :: struct($N: i32, $T: typeid) where N >= 0 {
	data:        [N]T,
	back_index:  int,
	front_index: int,
}

new :: proc($N: i32, $T: typeid) -> (res: Deque(N, T)) where N >= 0 {
	return
}

iter :: proc(deque: ^Deque($N, $T)) -> [dynamic; N]T {
	res: [dynamic; N]T
	for i in 0 ..< len(deque) {
		append(&res, deque.data[(deque.back_index + int(i)) % int(N)])
	}
	return res
}

push_back :: proc(deque: ^Deque($N, $T), value: T) -> bool {
	if is_full(deque) {
		return false
	}

	deque.back_index = (deque.back_index + N - 1) % N
	deque.data[deque.back_index] = value
	return true
}

push_front :: proc(deque: ^Deque($N, $T), value: T) -> bool {
	if is_full(deque) {
		return false
	}

	deque.data[deque.front_index] = value
	deque.front_index = (deque.front_index + 1) % int(N)
	return true
}

pop_back :: proc(deque: ^Deque($N, $T)) -> (int, bool) {
	if is_empty(deque) {
		return nil, false
	}

	res := deque.data[deque.back_index]
	deque.back_index = (deque.back_index + 1) % int(N)
	return res, true
}

pop_front :: proc(deque: ^Deque($N, $T)) -> (int, bool) {
	if is_empty(deque) {
		return nil, false
	}

	deque.front_index = (deque.front_index + N - 1) % int(N)
	res := deque.data[deque.back_index]
	return res, true
}

peek_back :: proc(deque: ^Deque($N, $T)) -> (int, bool) {
	if is_empty(deque) {
		return nil, false
	}

	return deque.data[deque.back_index], true
}

peek_front :: proc(deque: ^Deque($N, $T)) -> (int, bool) {
	if is_empty(deque) {
		return nil, false
	}

	return deque.data[deque.front_index - 1], true
}

is_empty :: proc(deque: ^Deque) -> bool {
	return len(deque) == 0
}

is_full :: proc(deque: ^Deque($N, $T)) -> bool {
	return len(deque) == cap(deque)
}

len :: proc(deque: ^Deque($N, $T)) -> int {
	front := deque.back_index > deque.front_index ? deque.front_index + int(N) : deque.front_index
	return front - deque.back_index
}

cap :: proc(deque: ^Deque($N, $T)) -> int {
	return int(N)
}
