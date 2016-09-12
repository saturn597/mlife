open Core.Std

type cell = Alive | Dead

let dimx = 10
let dimy = 10

let board = Array.make_matrix ~dimx ~dimy Dead 

let show_cell cell = 
    let str = match cell with
        | Alive -> "*"
        | Dead -> "-" 
    in printf "%s" str

let show_board board =
    Array.iteri board ~f:(fun i row -> 
        printf "%i: " i;
        Array.iter ~f:show_cell row;
        printf "\n"
    )

let wrap max x = 
    (* returns result >= 0 and < max *)
    let result = x mod max in
    if x < 0 then (max + result) mod max else result

let count_alive board (x, y) =
    let my_wrap (x, y) = (wrap dimx x, wrap dimy y) in
    let adjacent_coords = List.map ~f:my_wrap [
        (x - 1, y - 1); (x, y - 1); (x + 1, y - 1);
        (x - 1, y);                 (x + 1, y); 
        (x - 1, y + 1); (x, y + 1); (x + 1, y + 1)
    ] in
    let get_cells (x, y) = board.(x).(y) in
    let adjacent_cells = List.map ~f:get_cells adjacent_coords in
    let counter a b = if b = Alive then a + 1 else a in
    List.fold ~f:counter ~init:0 adjacent_cells

let new_state board (x, y) = 
    let count = count_alive board (x, y) in
    if (x, y) = (6, 4) then printf "%i" count else ();
    match board.(x).(y) with
        | Alive -> if count = 2 || count = 3 then Alive else Dead
        | Dead -> if count = 3 then Alive else Dead


let matrix_copy m = 
    let new_array = Array.copy m in
    for i = 0 to Array.length m - 1 do
       new_array.(i) <- Array.copy m.(i) 
    done;
    new_array

let tick board = 
    let old_board = matrix_copy board in
    for i = 0 to Array.length board - 1 do
        for j = 0 to Array.length board.(i) - 1 do
            board.(i).(j) <- new_state old_board (i, j)
        done
    done
        
let main = 
    board.(6).(4) <- Alive;
    board.(6).(5) <- Alive;
    board.(6).(6) <- Alive;
    board.(5).(6) <- Alive;
    board.(4).(5) <- Alive;
    printf "%i\n" (count_alive board (6, 4));
    for x = 0 to 100 do
        show_board board;
        tick board;
        printf "\n";
    done

let () = main
