Deque :: struct($N: int, $T: typeid) where N >= 0 {
	data: [N]T
	back_index: int
	front_index: int
}

deque_push_back :: proc(deque: ^Deque($N, $T), value: $T) -> (err: Allocation_Error) {
	if deque_is_full(deque) {
		return Allocation_Error()
	}

	deque.data[deque.front_index] = value
	deque.front_index = (deque.front_index + 1) % N
}

deque_is_full :: proc(deque: ^Deque($N, $T)) -> bool {
	return (deque.front_index + 1) % N == back_index
}