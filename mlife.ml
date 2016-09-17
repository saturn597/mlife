open Core.Std

type cell = Alive | Dead

let get_dims board =
    (Array.length board, Array.length board.(0))

let wrap max x =
    (* returns result >= 0 and < max *)
    let result = x mod max in
    if result < 0 then max + result else result

let show_cell cell =
    let str = match cell with
        | Alive -> "*"
        | Dead -> "-"
    in printf "%s" str

let show_board board =
    let (dimx, dimy) = get_dims board in
    for y = 0 to dimy - 1 do
        for x = 0 to dimx - 1 do
            show_cell board.(x).(y)
        done;
        printf "\n"
    done

let count_alive board (x, y) =
    let (dimx, dimy) = get_dims board in
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
    let (dimx, dimy) = get_dims board in
    let new_board = Array.make_matrix ~dimx ~dimy Dead in
    for i = 0 to Array.length board - 1 do
        for j = 0 to Array.length board.(i) - 1 do
            new_board.(i).(j) <- new_state board (i, j)
        done
    done;
    new_board

let read_file filename =
    let int_tuple = fun (x, y) ->
        (Int.of_string x, Int.of_string y) in
    In_channel.with_file filename ~f:(fun file ->
        In_channel.fold_lines file ~init:[] ~f:(fun coords line ->
            if line.[0] = '*' then coords else
                match String.lsplit2 line ~on:',' with
                    | None -> printf "Warning: Error parsing board description. \
                    Skipping line: %s\n" line; coords
                    | Some t -> (int_tuple t) :: coords))

let rec loop board ticks_left =
    show_board board;
    printf "\n";
    match ticks_left with
        | 1 -> ()
        | _ -> loop (tick board) (ticks_left - 1)

let make_list count ~f =
    let rec r count ~f acc =
        match count with
            | 0 -> acc
            | _ -> r (count - 1) ~f ((f ()) :: acc)
        in
    r count ~f []

let main ticks width height density filename () =
    Random.self_init ();

    let ticks = match ticks with
        | None -> 3
        | Some t -> t
    in

    let dimx = match width with
        | None -> 10
        | Some w -> w
    in

    let dimy = match height with
        | None -> 10
        | Some h -> h
    in

    let num_generated =
        let cells = dimx * dimy in
        match density with
            | None -> cells
            | Some d -> (float cells) *. d /. 100.0 |> Float.iround_exn
    in

    let live_cells = match filename with
        | None -> make_list num_generated ~f:(fun () -> (Random.int dimx, Random.int dimy))
        | Some f -> read_file f
    in

    let board = Array.make_matrix ~dimx ~dimy Dead in
    List.iter live_cells  ~f:(fun (x, y) -> board.(x).(y) <- Alive);
    loop board ticks

let spec =
    let open Command.Spec in
    empty
    +> flag "-t" (optional int) ~doc:"Number of ticks to show. 0 to never end."
    +> flag "-w" (optional int) ~doc:"Width of the board."
    +> flag "-h" (optional int) ~doc:"Height of the board."
    +> flag "-d" (optional float) ~doc:"Density of live cells in randomly \
        generated initial state."
    +> flag "-f" (optional file)  ~doc:"File specifying the board's initial \
        state. If no file is given, the initial state is generated randomly."

let command =
    Command.basic
        ~summary:"A program simulating John Conway's \"Game of Life\"."
        spec
        main

let () = Command.run command
