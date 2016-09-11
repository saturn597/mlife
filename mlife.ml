open Core.Std

type cell = Alive | Dead

let board = Array.make_matrix ~dimx:10 ~dimy:10 Dead 

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

let main = 
    board.(6).(7) <- Alive;
    show_board board

let () = main
