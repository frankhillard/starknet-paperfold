use array::ArrayTrait;
use starknet::ContractAddress;

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


#[starknet::interface]
trait PaperTrait<T> {
    /// @dev Function that emulates a single folding step
    fn fold(ref self: T, direction: Direction, index: u8);
    /// @dev Function that unfold completly the paper
    fn reset(ref self: T);
    /// @dev Function that retrieves the paper
    fn get_paper(self: @T) -> Array::<felt252>;
}

#[starknet::contract]
mod Paper {
    // use starknet::get_caller_address;
    // use starknet::get_block_timestamp;
    // use starknet::ContractAddress;
    use array::ArrayTrait;

    // Storage variable used to store the anchored value
    #[storage]
    struct Storage {
        length: u8, // Length of the paper
        width: u8, // Width of the paper
        paper: LegacyMap<u8, felt252>, // paper
    }

    // Function used to initialize the contract
    #[constructor]
    fn constructor(ref self: ContractState, length: u8, width: u8) {
        self.length.write(length);
        self.width.write(width);
        let total_elements = self.length.read() * self.width.read();
        let start_symbol: felt252 = 'A'.into();
        self.construct_paper(0_u8, total_elements, start_symbol);
    }


    #[external(v0)]
    impl PaperImpl of super::PaperTrait<ContractState> {
        fn fold(ref self: ContractState, direction: super::Direction, index: u8) {
            // match direction {
            //     super::Direction::Up(_) => {

            //     },
            // }
        }
        fn reset(ref self: ContractState) {
            let total_elements = self.length.read() * self.width.read();
            let start_symbol: felt252 = 'A'.into();
            self.construct_paper(0_u8, total_elements, start_symbol);
        }

        fn get_paper(self: @ContractState) -> Array::<felt252> {
            let total_elements = self.length.read() * self.width.read();
            let mut values = ArrayTrait::new();
            self.copy_paper_array(values, 0_u8, total_elements)
        }
    }

    /// @dev Internal Functions implementation for the Paper contract
    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        /// @dev Construct an array with all cells
        fn copy_paper_array(
            self: @ContractState, mut values: Array::<felt252>, index: u8, last_index: u8
        ) -> Array::<felt252> {
            if index < last_index {
                let cell = self.paper.read(index);
                values.append(cell);
                self.copy_paper_array(values, index + 1, last_index)
            } else {
                values
            }
        }

        fn construct_paper(
            ref self: ContractState, index: u8, last_index: u8, symbol: felt252
        )  {
            if index < last_index {
                let cell = self.paper.write(index, symbol);
                self.construct_paper(index + 1, last_index, symbol + 1)
            } else {
                return ();
            }
        }

    }

}
