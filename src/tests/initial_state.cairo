#[cfg(test)]
mod tests {
    use core::option::OptionTrait;
    use core::array::ArrayTrait;
    use snforge_std::{ declare, ContractClassTrait, start_prank, stop_prank, PrintTrait };
    use core::traits::PanicDestruct;
    use starknet::ContractAddress;

    use paperfold::paper::{PaperTraitDispatcher, PaperTraitDispatcherTrait};
    use test::test_utils::assert_eq;
    // use core::option::OptionTrait;
    // use array::ArrayTrait;
    // use traits::Into;
    // use traits::TryInto;

    #[test]
    #[available_gas(1000000)]
    fn success_initial_state() {
        let length = 4;
        let width = 3;

        // Prepare deployment parameters
        let mut calldata_array = ArrayTrait::new();
        calldata_array.append(length);
        calldata_array.append(width);

        // First declare and deploy a contract
        let contract = declare('Paper');
        let contract_address = contract.deploy(@calldata_array).unwrap();
        
        // Create a Dispatcher object that will allow interacting with the deployed contract
        let dispatcher = PaperTraitDispatcher { contract_address: contract_address };

        let mut grid = dispatcher.get_paper();
        assert_eq(grid.at(0), @('A'.into()) , 'Wrong cell 1 init value');
        assert_eq(grid.at(1), @('B'.into()) , 'Wrong cell 1 init value');
        assert_eq(grid.at(2), @('C'.into()) , 'Wrong cell 2 init value');
        assert_eq(grid.at(3), @('D'.into()) , 'Wrong cell 3 init value');
        assert_eq(grid.at(4), @('E'.into()) , 'Wrong cell 4 init value');
        assert_eq(grid.at(5), @('F'.into()) , 'Wrong cell 5 init value');
        assert_eq(grid.at(6), @('G'.into()) , 'Wrong cell 6 init value');
        assert_eq(grid.at(7), @('H'.into()) , 'Wrong cell 7 init value');
        assert_eq(grid.at(8), @('I'.into()) , 'Wrong cell 8 init value');
        assert_eq(grid.at(9), @('J'.into()) , 'Wrong cell 9 init value');
        assert_eq(grid.at(10), @('K'.into()) , 'Wrong cell 10 init value');
        assert_eq(grid.at(11), @('L'.into()) , 'Wrong cell 11 init value');

        let actual_size: felt252 = grid.len().into();
        let expected_size = length * width;
        assert_eq(@actual_size, @expected_size , 'Wrong size');
    }
}