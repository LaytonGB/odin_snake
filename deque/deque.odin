package deque

Deque :: struct($N: i32, $T: typeid) where N >= 0 {
	data:        [N]T,
	back_index:  int,
	front_index: int,
}

new :: proc($N: i32, $T: typeid) -> (res: Deque(N, T)) where N >= 0 {
	return
}

nth :: proc(deque: ^Deque($N, $T), index: int) -> Maybe(T) {
	if index < 0 {
		if -index >= len(deque) {
			return nil
		}
		return deque.data[len(deque) + index]
	}
	if index >= len(deque) {
		return nil
	}
	return deque.data[index]
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

	deque.back_index = (deque.back_index + int(N) - 1) % int(N)
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

pop_back :: proc(deque: ^Deque($N, $T)) -> Maybe(T) {
	if is_empty(deque) {
		return nil
	}

	res := deque.data[deque.back_index]
	deque.back_index = (deque.back_index + 1) % int(N)
	return res
}

pop_front :: proc(deque: ^Deque($N, $T)) -> Maybe(T) {
	if is_empty(deque) {
		return nil
	}

	deque.front_index = (deque.front_index + N - 1) % int(N)
	res := deque.data[deque.back_index]
	return res
}

peek_back :: proc(deque: ^Deque($N, $T)) -> Maybe(T) {
	if is_empty(deque) {
		return nil
	}

	return deque.data[deque.back_index]
}

peek_front :: proc(deque: ^Deque($N, $T)) -> Maybe(T) {
	if is_empty(deque) {
		return nil
	}
	return deque.data[(deque.front_index + int(N) - 1) % int(N)]
}

is_empty :: proc(deque: ^Deque($N, $T)) -> bool {
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
