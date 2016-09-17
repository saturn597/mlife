About
============
A simple command-line program based on [John Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life).

Written in OCaml, in order to try out the language.

Finite board size
============
A "correct" implementation of Life would allow for an infinite number of cells, extending forever in all directions.

This program only allows a finite number of cells. To cope with this, we "wrap" the board, so that cells at one edge are considered adjacent to those on the opposite edge.

Arguments
============
All arguments are optional.

**-d Density**:  Density of live cells in randomly generated initial state. Ignored if using **-f**. Defaults to 100.

**-f File**: File specifying the board's initial state. If no file is given, the initial state is generated manually.

**-h Height**: The height of the board (measured in "cells"). Defaults to 10.

**-w Width**: The width of the board (measured in "cells"). Defaults to 10.

**-help**: Output help text.

Random generation of initial state
============
To generate a random board state, this program starts with a board containing only "dead" cells.

We then choose some number of cells, n, and bring them to life.

The value of n is determined by the "density". Specifically, if a board contains "total" cells, then the number of cells chosen to be brought to life will be (density / 100) * total.

However, a cell can be chosen more than once, and bringing an already live cell to life has no effect. Thus, the total number of live cells in a randomly generated initial state may be less than n.

Files
============
Instead of allowing the board's initial state to be randomized, you can create a file and pass its path to the program with the **-f** argument.

Initial state files should contain a line-separated list of cells. These cells will be "alive" in the board's initial state. 

Cells are specified by giving their x and y coordinates, separated by a comma (and only a comma, no spaces).

So to specify that the cell at (7, 6) should be alive, your file would contain the line:

`7,6`

In general, for each line that doesn't follow this pattern, the program will issue a warning to standard output. The program will still try to proceed, processing any subsequent lines. 

Lines beginning with `*` will be ignored, with no warning. This can be used to leave comments in the file.

Negative coordinates aren't allowed. The "x" coordinate can range from 0 to the board width minus 1. The "y" coordinate can range from 0 to the board height minus 1.

If any of the coordinates is less than 0, or exceeds the dimensions of the board, the program will crash. Thus, one use for `*` comments is to specify the intended board size to be used for the file.
