use array::ArrayTrait;
// use starknet::ContractAddress;
use paperfold::direction::Direction;

#[starknet::interface]
trait PaperTrait<T> {
    /// @dev Function that emulates a single folding step
    fn fold(ref self: T, direction: Direction, index: u8);
    /// @dev Function that unfold completly the paper
    fn reset(ref self: T);
    /// @dev Function that retrieves the paper
    fn get_paper(self: @T) -> Array::<felt252>;
    // fn get_paper_grid(self: @T) -> Array::<Array::<felt252>>;
}

#[starknet::contract]
mod Paper {
    // use starknet::get_caller_address;
    // use starknet::get_block_timestamp;
    // use starknet::ContractAddress;
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
                    self.write_grid_to_storage(new_grid.grid.span(), 0_u8, total_elements - self.length.read());
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
        //     let grid: paperfold::grid::Grid = paperfold::grid::GridTraitGridImpl::new(self.length.read().into(), self.width.read().into());
        //     let mut values: Array::<Array::<felt252>> = ArrayTrait::new();
        //     self.build_n_columns(values, 0, self.length.read())
        //     self.fill_grid(values, 0, total_elements)
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

        // fn build_n_columns(
        //     self: @ContractState, mut values: Array::<Array::<felt252>>, index: u8, nb: u8) -> Array::<Array::<felt252>> {
        //     if index < nb {
        //         let mut one_column = ArrayTrait::new();
        //         values.append(one_column);
        //         self.build_n_columns(values, index + 1, nb)
        //     } else {
        //         values
        //     }
        // }

        // fn fill_grid(
        //     ref self: ContractState, mut values: Array::<Array::<felt252>>, index: u8, nb: u8) -> Array::<Array::<felt252>> {
        //     if index < nb {
        //         let data = self.paper.read(index);
        //         let column = index / self.width.read(); 
        //         let line = index % self.width.read();
        //         values.append(one_column);
        //         self.build_n_columns(values, index + 1, nb)
        //     } else {
        //         values
        //     }
        // }

    }


    fn reverse(str: @felt252) -> @felt252 {
        let raw: felt252 = str.clone();
        @raw
    }

    fn merge_cell_onto(mut res: Array::<felt252>, top: Array::<felt252>, bot: Array::<felt252>, index: u32, nb: u32) -> Array::<felt252> {
        if (index < nb) {
            let elt: @felt252 = top.at(index);
            let rev_elt = reverse(elt);
            let base: @felt252 = bot.at(index);
            let merged = rev_elt.clone() + base.clone();
            res.append(merged);
            merge_cell_onto(res, top, bot, index + 1, nb)
        } else {
            res
        }
    }

    fn merge_onto(top: Array::<felt252>, bot: Array::<felt252>) -> Array::<felt252> {
        let size = top.len();
        assert(bot.len() == size, 'columns size missmatch');
        let mut result = ArrayTrait::new();
        let final = merge_cell_onto(result, top, bot, 0, size);
        final
    }


}
