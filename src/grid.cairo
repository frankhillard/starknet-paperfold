use array::ArrayTrait;
use array::SpanTrait;
use clone::Clone;
use debug::PrintTrait;

#[derive(Drop, Clone)]
struct Grid {
    length: u32,
    width: u32,
    grid: Array<felt252>
}

trait GridTrait<T> {
    fn new(length: u32, width: u32, start_symbol: felt252) -> Grid;
    fn try_from(data: Span<felt252>, width: u32, length: u32) -> Result<Grid, felt252>;
    fn from(data: Span<felt252>, width: u32, length: u32) -> Grid;
    fn get(ref self: T, x: u32, y: u32) -> @felt252;
    fn len(self: @T) -> u32;
    fn pop_line(ref self: T) -> (Span<felt252>, Grid);
    fn pop_lines(ref self: T, nb: u32) -> (Grid, Grid);
    fn fold_lines_up(ref self: T, index: u32) -> Grid;
}

fn copy_grid(grid: Span<felt252>, mut result: Array<felt252>, index: u32, stop: u32) -> Array<felt252> {
    if index < stop {
        result.append(grid.at(index).clone());
        copy_grid(grid, result, index + 1, stop)
    } else {
        result
    }
}


fn construct_grid(
        mut grid: Array<felt252>, index: u32, last_index: u32, symbol: felt252
    ) -> Array<felt252> {
        if index < last_index {
            grid.append(symbol);
            construct_grid(grid, index + 1, last_index, symbol + 1)
        } else {
            grid
        }
    }

fn split_by_line_rec(mut grid: Array<felt252>, nb: u32, mut res: Array<felt252>) -> (Array<felt252>, Array<felt252>) {
    if (nb == 0){
        (res, grid)
    } else {
        res.append(grid.pop_front().unwrap());
        split_by_line_rec(grid, nb - 1, res)
    }
}

fn concat_array_rec(mut base: Array<felt252>, mut other: Array<felt252>) {
    if (other.len() > 0){
        base.append(other.pop_front().unwrap());
        concat_array_rec(base, other);
    } else {
        return;
    }
}


fn reverse_cell_rec(cell: felt252, mut result: felt252) -> felt252 {
    let cell_256: u256 = cell.into();
    if (cell_256 > 0_u256){
        let rem = cell % 256;
        reverse_cell_rec(cell / 256, result * 256 + rem)
    } else {
        result
    }
}

fn reverse_cell(cell: felt252) -> felt252 {
    let cell_256: u256 = cell.into();
    if (cell_256 > 256_u256){
        let reversed = reverse_cell_rec(cell, 0);
        reversed
    } else {
        cell
    }
}
fn copy_one_line_rec(grid: Span<felt252>, mut result: Array<felt252>, index: u32, end: u32) -> Array<felt252>{
    if (index > end){
        result
    } else {
        let val = grid.get(index).unwrap().unbox();
        result.append(reverse_cell(val.clone()));
        copy_one_line_rec(grid, result, index + 1, end)
    }
}

fn reverse_lines_rec(grid: Span<felt252>, mut result: Array<felt252>, index: u32, length: u32) -> Result<Array<felt252>, felt252> {
    let result_updated = copy_one_line_rec(grid, result, index, index + length - 1);
    if (index == 0){
        Result::Ok(result_updated)
    } else {
        reverse_lines_rec(grid, result_updated, index - length, length)
    }
}

fn reverse_lines(grid: Span<felt252>, width: u32, length: u32) -> Array<felt252> {
    let mut arr : Array<felt252> = ArrayTrait::new();
    let index = width*length - length;
    let res = reverse_lines_rec(grid, arr, index, length);
    res.unwrap()
}

fn div_rec(lhs: felt252, rhs: felt252, cpt: u32) -> (u32, felt252) {
    let lhs_256: u256 = lhs.into();
    let rhs_256: u256 = rhs.into();
    if (lhs_256 < rhs_256){
        (cpt, lhs)
    } else {
        div_rec(lhs - rhs, rhs, cpt + 1)
    }
}

impl FeltRem of Rem<felt252>{
    fn rem(lhs: felt252, rhs: felt252) -> felt252 {
        let (div, rem) = div_rec(lhs, rhs, 0);
        rem
    }
}

impl FeltDiv of Div<felt252>{
    fn div(lhs: felt252, rhs: felt252) -> felt252 {
        let (div, rem) = div_rec(lhs, rhs, 0);
        div.into()
    }
}

fn pow_rec(base:u32, exp: u32, res: u32) -> u32 {
    if (exp == 0){
        res
    } else {

        pow_rec(base, exp - 1, res * base)
    }
}

fn concat_felt(top: felt252, base: felt252) -> felt252 {
    let (div, rem) = div_rec(base, 256, 0);
    let offset = pow_rec(256_u32, div + 1, 1);
    top * offset.into() + base
}

fn fold_line_rec(tofold: Span<felt252>, base: Span<felt252>, length: u32, index: u32, mut arr: Array<felt252>) -> Array<felt252> {
    if (tofold.len() > index && base.len() > index) {
        let a:felt252 = tofold.at(index).clone();
        let b:felt252 = base.at(index).clone();
        let d = concat_felt(a, b);
        arr.append(d);
        fold_line_rec(tofold, base, length, index + 1, arr)
    } else if (tofold.len() > index) {
        let a:felt252 = tofold.at(index).clone();
        arr.append(a);
        fold_line_rec(tofold, base, length, index + 1, arr)
    } else if (base.len() > index) {
        let b:felt252 = base.at(index).clone();
        arr.append(b);
        fold_line_rec(tofold, base, length, index + 1, arr)
    } else {
        arr
    }
}


fn fold_lines(tofold: Span<felt252>, base: Span<felt252>, length: u32) -> Array<felt252> {
    let mut arr : Array<felt252> = ArrayTrait::new();
    let result = fold_line_rec(tofold, base, length, 0_u32, arr);
    result
}

fn max(lhs: u32, rhs: u32) -> u32 {
    if (lhs > rhs){
        lhs
    } else {
        rhs
    }
}

// impl TCopyClone<T, impl TCopy: Copy<T>> of Clone<Array<felt252>> {
//     fn clone(self: @Array<felt252>) -> Array<felt252> {
//         let mut res: Array<felt252> = ArrayTrait::new();
//         let temp = self.//..pop_front().unwrap();
//         res.append(self.pop_front().unwrap().clone());
//         res
//     }
// }

impl GridTraitGridImpl of GridTrait<Grid> {
    fn new(length: u32, width: u32, start_symbol: felt252) -> Grid {
        let mut lst: Array<felt252> = ArrayTrait::new();
        let mut initial_grid = construct_grid(lst, 0, length * width, start_symbol);
        Grid {
            length: length,
            width: width,
            grid: initial_grid
        }
    }

    fn try_from(data: Span<felt252>, width: u32, length: u32) -> Result<Grid, felt252> {
        if (data.len() != length * width){
            Result::Err("Invalid number of cells")
        } else {
            let mut arr = ArrayTrait::new();
            let grid = copy_grid(data, arr, 0, length * width);
            Result::Ok(Grid {
                length: length,
                width: width,
                grid: grid
            })
        } 
    }

    fn from(data: Span<felt252>, width: u32, length: u32) -> Grid {
        let mut arr = ArrayTrait::new();
        let grid = copy_grid(data, arr, 0, length * width);
        Grid {
            length: length,
            width: width,
            grid: grid
        }
    }

    fn get(ref self: Grid, x: u32, y: u32) -> @felt252 {
        self.grid.get(x + y * self.length).unwrap().unbox()
    }

    fn len(self: @Grid) -> u32 {
        self.grid.len()
    }

    fn pop_line(ref self: Grid) -> (Span<felt252>, Grid) {
        let mut temp : Array<felt252> = ArrayTrait::new();
        let (poped, rest) = split_by_line_rec(self.grid.clone(), self.length, temp.clone());
            (temp.span(), Grid {
            length: self.length,
            width: self.width - 1,
            grid: rest
        })

    }

    fn pop_lines(ref self: Grid, nb: u32) -> (Grid, Grid) {
        let mut poped : Array<felt252> = ArrayTrait::new();
        let (poped, rest) = split_by_line_rec(self.grid.clone(), nb * self.length, poped);
        (Grid {
            length: self.length,
            width: nb,
            grid: poped
        }, Grid {
            length: self.length,
            width: self.width - nb,
            grid: rest
        })
    }

    fn fold_lines_up(ref self: Grid, index: u32) -> Grid {
        let (tofold, base):(Grid, Grid) = self.pop_lines(index);
        let new_width: u32 = max(base.width, tofold.width);
        let tofold_reversed = reverse_lines(tofold.grid.span(), tofold.width, tofold.length);
        let folded = fold_lines(tofold_reversed.span(), base.grid.span(), tofold.length);
        Grid {
            length: self.length,
            width: new_width,
            grid: folded
        }
    }


}
