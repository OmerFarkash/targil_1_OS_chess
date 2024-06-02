game_string=""
declare -A board
declare -A boards

split_pgn () {

    echo "Metadata from PGN file:"
    
    # read the file line by line
    while IFS= read -r line
    do
        # if line does not start with '['
        if [[ $line == \[* ]]
        then
            # print the line
            echo "$line"
        else
            # add the line to the game string
            game_string+="$line "
        fi
    done < "$1"
    echo ""
}

convert_to_uci () {
    python3 parse_moves.py "$game_string" > moves.txt
    game_string=$(<moves.txt)
    rm moves.txt
}

initialize_board () {
    board=(
        [0,0]="r" [0,1]="n" [0,2]="b" [0,3]="q" [0,4]="k" [0,5]="b" [0,6]="n" [0,7]="r"
        [1,0]="p" [1,1]="p" [1,2]="p" [1,3]="p" [1,4]="p" [1,5]="p" [1,6]="p" [1,7]="p"
        [2,0]="." [2,1]="." [2,2]="." [2,3]="." [2,4]="." [2,5]="." [2,6]="." [2,7]="."
        [3,0]="." [3,1]="." [3,2]="." [3,3]="." [3,4]="." [3,5]="." [3,6]="." [3,7]="."
        [4,0]="." [4,1]="." [4,2]="." [4,3]="." [4,4]="." [4,5]="." [4,6]="." [4,7]="."
        [5,0]="." [5,1]="." [5,2]="." [5,3]="." [5,4]="." [5,5]="." [5,6]="." [5,7]="."
        [6,0]="P" [6,1]="P" [6,2]="P" [6,3]="P" [6,4]="P" [6,5]="P" [6,6]="P" [6,7]="P"
        [7,0]="R" [7,1]="N" [7,2]="B" [7,3]="Q" [7,4]="K" [7,5]="B" [7,6]="N" [7,7]="R"
    )
}

# Function to copy the current board state
copy_board () {
    index=$1
    for row in {0..7}
    do
        for col in {0..7}
        do
            boards[$index,$row,$col]="${board[$row,$col]}"
        done
    done    
}

# Function to print a specific board state
print_board () {
    local index=$1
    # Print the chessboard with column labels
    echo "  a b c d e f g h"
    for row in {7..0}; do
        echo -n "$((row+1)) "
        for col in {0..7}; do
            echo -n "${boards[$index,$row,$col]} "
        done
        echo "$((row+1))"
    done
    echo "  a b c d e f g h"
}

# Main
main () {
    # Check the number of arguments
    if test "$#" -ne 1;
    then
        echo "Usage: $0 <source_pgn_file>"
        exit 1
    fi
    
    if [ ! -f "$1" ]
    then
        echo "File does not exist: $1"
        exit 1
    fi

    # Split the PGN file
    split_pgn "$1"
    #convert_to_uci
    convert_to_uci

    # Initialize the board
    initialize_board
    copy_board 0
    print_board 0
}

main "$@"


