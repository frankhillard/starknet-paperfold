#[derive(Drop)]
enum Direction {
    Up: (),
    Down: (),
    Left: (),
    Right: ()
}

impl DirectionSerdeImpl of Serde<Direction> {
    fn serialize(self: @Direction, ref output: Array<felt252>) {
        match self {
            Direction::Up(_) => { output.append(0.into()) },
            Direction::Down(_) => { output.append(1.into()) },
            Direction::Left(_) => { output.append(2.into()) },
            Direction::Right(_) => { output.append(3.into()) },
        }
    }

    fn deserialize(ref serialized: Span<felt252>) -> Option<Direction> {
        let msg = *serialized.pop_front()?;
        if (msg == 0) { Option::Some(Direction::Up(())) }
        else if (msg == 1) { Option::Some(Direction::Down(())) }
        else if (msg == 2) { Option::Some(Direction::Left(())) }
        else if (msg == 3) { Option::Some(Direction::Right(())) }
        else {Option::None(()) }
    }
}