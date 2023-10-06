use array::ArrayTrait;
// use starknet::ContractAddress;
use paperfold::direction::Direction;
// use paperfold::grid::Grid;

#[starknet::interface]
trait PaperTrait<T> {
    /// @dev Function that emulates a single folding step
    fn fold(ref self: T, direction: Direction, index: u8);
    /// @dev Function that unfold completly the paper
    fn reset(ref self: T);
    /// @dev Function that retrieves the paper
    fn get_paper(self: @T) -> Array::<felt252>;
    // fn get_paper_grid(self: @T) -> Grid;
}

#[starknet::contract]
mod Paper {
    // use starknet::get_caller_address;
    // use starknet::get_block_timestamp;
    // use starknet::ContractAddress;
    use core::traits::TryInto;
use core::result::ResultTrait;
    use core::traits::Into;
    use core::clone::Clone;
    use array::ArrayTrait;
    use paperfold::grid::{Grid, GridTrait};

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
            let total_elements = self.length.read() * self.width.read();
            let mut values = ArrayTrait::new();
            let arr: Array<felt252> = self.copy_paper_array(values, 0_u8, total_elements);
            let length: u32 = self.length.read().into();
            let width: u32 = self.width.read().into();
            let data: Span<felt252> = arr.span();
            
            let mut grid: Grid = GridTrait::<Grid>::from(data, width, length);
            match direction {
                super::Direction::Up(_) => {
                    let new_grid = grid.fold_lines_up(index.into());
                    let new_w: u8 = new_grid.width.try_into().unwrap();
                    let new_l: u8 = new_grid.length.try_into().unwrap();
                    self.write_grid_to_storage(new_grid.grid.span(), 0_u8, new_l * new_w);
                },
                super::Direction::Down(_) => {},
                super::Direction::Left(_) => {},
                super::Direction::Right(_) => {},
            }

            // WHY RESULT IS NOT ALLOWED ??
            // let grid_result: Result<Grid, felt252> = GridTrait::<Grid>::try_from(data, width, length);
            // match grid_result {
            //     Result::Ok(mut grid) => {
            //         match direction {
            //             super::Direction::Up(_) => {
            //                 let new_grid = grid.fold_lines_up(index.into());
            //                 self.write_grid_to_storage(new_grid.grid.span(), 0_u8, total_elements);
            //             },
            //             super::Direction::Down(_) => {},
            //             super::Direction::Left(_) => {},
            //             super::Direction::Right(_) => {},
            //         }
            //     },
            //     Result::Err(err) =>{
            //     }
            // }
        }

        fn reset(ref self: ContractState) {
            let total_elements = self.length.read() * self.width.read();
            let start_symbol: felt252 = 'A'.into();
            // self.construct_paper(0_u8, total_elements, start_symbol);

            let length: u32 = self.length.read().into();
            let width: u32 = self.width.read().into();
            let grid_result: Grid = GridTrait::<Grid>::new(width, length, start_symbol);
            self.write_grid_to_storage(grid_result.grid.span(), 0_u8, total_elements);
        }

        fn get_paper(self: @ContractState) -> Array::<felt252> {
            let total_elements = self.length.read() * self.width.read();
            let mut values = ArrayTrait::new();
            self.copy_paper_array(values, 0_u8, total_elements)
        }

        // fn get_paper_grid(self: @ContractState) -> paperfold::grid::Grid {
        //     let total_elements = self.length.read() * self.width.read();
        //     let mut values = ArrayTrait::new();
        //     let arr: Array<felt252> = self.copy_paper_array(values, 0_u8, total_elements);
        //     let length: u32 = self.length.read().into();
        //     let width: u32 = self.width.read().into();
        //     let data: Span<felt252> = arr.span();
        //     let grid: Grid = GridTrait::<Grid>::from(data, width, length);
        //     grid
        // }

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

        fn write_grid_to_storage(ref self: ContractState, values: Span<felt252>, index: u8, last_index: u8)  {
            if index < last_index {
                self.paper.write(index, values.at(index.into()).clone());
                self.write_grid_to_storage(values, index + 1, last_index);
            } else {
                return ();
            }
        }

    }

}
