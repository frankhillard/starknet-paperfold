#[cfg(test)]
mod tests {
    use core::option::OptionTrait;
    use core::array::ArrayTrait;
    use snforge_std::{ declare, ContractClassTrait, start_prank, stop_prank, PrintTrait };
    use core::traits::PanicDestruct;
    use starknet::ContractAddress;

    use paperfold::direction::Direction;
    use paperfold::paper::{PaperTraitDispatcher, PaperTraitDispatcherTrait};
    use test::test_utils::assert_eq;
    // use core::option::OptionTrait;
    // use array::ArrayTrait;
    // use traits::Into;
    // use traits::TryInto;

    #[test]
    #[available_gas(1000000)]
    fn success_fold_1_down() {
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

        dispatcher.fold(Direction::Down(()), 1);
        
        let mut grid = dispatcher.get_paper();

        assert_eq(grid.at(0), @('I'.into()) , 'Wrong cell 0 init value');
        assert_eq(grid.at(1), @('J'.into()) , 'Wrong cell 1 init value');
        assert_eq(grid.at(2), @('K'.into()) , 'Wrong cell 2 init value');
        assert_eq(grid.at(3), @('L'.into()) , 'Wrong cell 3 init value');
        assert_eq(grid.at(4), @('EA'.into()) , 'Wrong cell 4 init value');
        assert_eq(grid.at(5), @('FB'.into()) , 'Wrong cell 5 init value');
        assert_eq(grid.at(6), @('GC'.into()) , 'Wrong cell 6 init value');
        assert_eq(grid.at(7), @('HD'.into()) , 'Wrong cell 7 init value');     
    }
}