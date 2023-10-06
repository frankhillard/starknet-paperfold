mod direction;
mod grid;
mod paper;
mod tests;

#[cfg(test)]
mod lib_tests {
    use core::clone::Clone;
    use super::grid::{Grid, GridTraitGridImpl};
    use test::test_utils::assert_eq;
    use debug::PrintTrait;

    #[test]
    #[available_gas(1000000)]
    fn success_initial_grid() {
        let length: u32 = 4;
        let width: u32 = 3;
        let mut grid: Grid = GridTraitGridImpl::new(length, width);

        assert_eq(grid.get(0_u32, 0_u32), @('A'.into()) , 'Wrong cell 0 init value');
        assert_eq(grid.get(1_u32, 0_u32), @('B'.into()) , 'Wrong cell 1 init value');
        assert_eq(grid.get(2_u32, 0_u32), @('C'.into()) , 'Wrong cell 2 init value');
        assert_eq(grid.get(3_u32, 0_u32), @('D'.into()) , 'Wrong cell 3 init value');
        assert_eq(grid.get(0_u32, 1_u32), @('E'.into()) , 'Wrong cell 4 init value');
        assert_eq(grid.get(1_u32, 1_u32), @('F'.into()) , 'Wrong cell 5 init value');
        assert_eq(grid.get(2_u32, 1_u32), @('G'.into()) , 'Wrong cell 6 init value');
        assert_eq(grid.get(3_u32, 1_u32), @('H'.into()) , 'Wrong cell 7 init value');
        assert_eq(grid.get(0_u32, 2_u32), @('I'.into()) , 'Wrong cell 8 init value');
        assert_eq(grid.get(1_u32, 2_u32), @('J'.into()) , 'Wrong cell 9 init value');
        assert_eq(grid.get(2_u32, 2_u32), @('K'.into()) , 'Wrong cell 10 init value');
        assert_eq(grid.get(3_u32, 2_u32), @('L'.into()) , 'Wrong cell 11 init value');

        let actual_size: u32 = grid.len();
        let expected_size = length * width;
        assert_eq(@actual_size, @expected_size , 'Wrong size');
    }

    #[test]
    #[available_gas(1000000)]
    fn success_fold_two_lines() {
        let length: u32 = 4;
        let width: u32 = 3;
        let mut grid: Grid = GridTraitGridImpl::new(length, width);
        let mut result = grid.fold_lines_up(2_u32);

        assert_eq(result.get(0_u32, 0_u32), @('EI'.into()) , 'Wrong cell 0 init value');
        assert_eq(result.get(1_u32, 0_u32), @('FJ'.into()) , 'Wrong cell 1 init value');
        assert_eq(result.get(2_u32, 0_u32), @('GK'.into()) , 'Wrong cell 2 init value');
        assert_eq(result.get(3_u32, 0_u32), @('HL'.into()) , 'Wrong cell 3 init value');
        assert_eq(result.get(0_u32, 1_u32), @('A'.into()) , 'Wrong cell 4 init value');
        assert_eq(result.get(1_u32, 1_u32), @('B'.into()) , 'Wrong cell 5 init value');
        assert_eq(result.get(2_u32, 1_u32), @('C'.into()) , 'Wrong cell 6 init value');
        assert_eq(result.get(3_u32, 1_u32), @('D'.into()) , 'Wrong cell 7 init value');
    }

    #[test]
    #[available_gas(10000000)]
    fn success_fold_two_times_2_1() {
        let length: u32 = 4;
        let width: u32 = 3;
        let mut grid: Grid = GridTraitGridImpl::new(length, width);
        let mut temp = grid.fold_lines_up(2_u32);
        let mut result = temp.fold_lines_up(1_u32);

        assert_eq(result.get(0_u32, 0_u32), @('IEA'.into()) , 'Wrong cell 0 init value');
        assert_eq(result.get(1_u32, 0_u32), @('JFB'.into()) , 'Wrong cell 1 init value');
        assert_eq(result.get(2_u32, 0_u32), @('KGC'.into()) , 'Wrong cell 2 init value');
        assert_eq(result.get(3_u32, 0_u32), @('LHD'.into()) , 'Wrong cell 3 init value');
    }

    #[test]
    #[available_gas(10000000)]
    fn success_fold_two_times_1_1() {
        let length: u32 = 4;
        let width: u32 = 3;
        let mut grid: Grid = GridTraitGridImpl::new(length, width);
        let mut temp = grid.fold_lines_up(1_u32);
        let mut result = temp.fold_lines_up(1_u32);

        assert_eq(result.get(0_u32, 0_u32), @('EAI'.into()) , 'Wrong cell 0 init value');
        assert_eq(result.get(1_u32, 0_u32), @('FBJ'.into()) , 'Wrong cell 1 init value');
        assert_eq(result.get(2_u32, 0_u32), @('GCK'.into()) , 'Wrong cell 2 init value');
        assert_eq(result.get(3_u32, 0_u32), @('HDL'.into()) , 'Wrong cell 3 init value');
    }


    #[test]
    #[available_gas(1000000)]
    fn success_fold_two_lines_once() {
        let length: u32 = 3;
        let width: u32 = 3;
        let mut grid: Grid = GridTraitGridImpl::new(length, width);
        let mut result = grid.fold_lines_up(2_u32);

        assert_eq(result.get(0_u32, 0_u32), @('DG'.into()) , 'Wrong cell 0 init value');
        assert_eq(result.get(1_u32, 0_u32), @('EH'.into()) , 'Wrong cell 1 init value');
        assert_eq(result.get(2_u32, 0_u32), @('FI'.into()) , 'Wrong cell 2 init value');
        assert_eq(result.get(0_u32, 1_u32), @('A'.into()) , 'Wrong cell 4 init value');
        assert_eq(result.get(1_u32, 1_u32), @('B'.into()) , 'Wrong cell 5 init value');
        assert_eq(result.get(2_u32, 1_u32), @('C'.into()) , 'Wrong cell 6 init value');
    }
}