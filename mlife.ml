open Core.Std

let dimx = 10
let dimy = 10

type cell = Alive | Dead

let show_cell cell =
    let str = match cell with
        | Alive -> "*"
        | Dead -> "-"
    in printf "%s" str

let show_board board =
    Array.iter board ~f:(fun row ->
        Array.iter ~f:show_cell row;
        printf "\n"
    )

let wrap max x =
    (* returns result >= 0 and < max *)
    let result = x mod max in
    if result < 0 then max + result else result

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
    match board.(x).(y) with
        | Alive -> if count = 2 || count = 3 then Alive else Dead
        | Dead -> if count = 3 then Alive else Dead

let tick board =
    let new_board = Array.make_matrix ~dimx ~dimy Dead in
    for i = 0 to Array.length board - 1 do
        for j = 0 to Array.length board.(i) - 1 do
            new_board.(i).(j) <- new_state board (i, j)
        done
    done;
    new_board

let rec loop board count =
    show_board board;
    printf "\n";
    match count with
        | 1 -> ()
        | _ -> loop (tick board) (count - 1)


let read_file filename =
    let int_tuple = fun (x, y) ->
        (Int.of_string x, Int.of_string y) in
    In_channel.with_file filename ~f:(fun file ->
        In_channel.fold_lines file ~init:[] ~f:(fun coords line ->
            (String.lsplit2_exn line ~on:',' |> int_tuple) :: coords))

let main ticks =
    let board = Array.make_matrix ~dimx ~dimy Dead in
    List.iter (read_file "Life") ~f:(fun (x, y) -> board.(x).(y) <- Alive);
    loop board ticks

let spec =
    let open Command.Spec in
    empty
    +> anon ("ticks" %: int)

let command =
    Command.basic
        ~summary:"Run Conway's Game of Life"
        ~readme:(fun () -> "Enter the number of ticks you want to show. 0 to never end.")
        spec
        (fun ticks () -> main ticks)

let () = Command.run command
