game_string=""
moves_amount=0
current_move=0
moves_done=0
declare -A board
declare -A boards
what_next="Press 'd' to move forward, 'a' to move back, 'w' to go to the start, 's' to go to the end, 'q' to quit: "
# Map the columns and rows
declare -A col_map=( ["a"]=0 ["b"]=1 ["c"]=2 ["d"]=3 ["e"]=4 ["f"]=5 ["g"]=6 ["h"]=7 )
declare -A row_map=( ["8"]=0 ["7"]=1 ["6"]=2 ["5"]=3 ["4"]=4 ["3"]=5 ["2"]=6 ["1"]=7 )

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
    game_string=$(echo "$game_string" | python3 parse_moves.py "$game_string")
    moves_amount=$(echo "$game_string" | wc -w)
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
    echo "Move $current_move/$moves_amount"
    local i=8
    # Print the chessboard with column labels
    echo "  a b c d e f g h"
    for row in {0..7}
    do
        echo -n "$((i-row)) "
        for col in {0..7}
        do
            echo -n "${boards[$current_move,$row,$col]} "
        done
        echo "$((i-row))"
    done
    echo "  a b c d e f g h"
    echo
}

# Function to handle a move
handle_move () {
    # extract the move from the game string
    move=${game_string%% *}
    # remove the move from the game string
    game_string=${game_string#* }
    
    # extract the move details
    from_col=${move:0:1}
    from_row=${move:1:1}
    to_col=${move:2:1}
    to_row=${move:3:1}
    
    # convert the move details to the board indexes
    from_col=${col_map[$from_col]}
    to_col=${col_map[$to_col]}
    from_row=${row_map[$from_row]}
    to_row=${row_map[$to_row]}

    # adapt the board state
    if [[ ${#move} == 5 ]]
    then
        # promotion
        promotion=${move:4:1}
        
        board[$to_row,$to_col]=$promotion
        board[$from_row,$from_col]="."
    else
        # on passant
        if [[ ${board[$from_row,$from_col]} == "p" ]] || [[ ${board[$from_row,$from_col]} == "P" ]]
        then
            if [[ ${board[$to_row,$to_col]} == "." ]] && [[ $to_col != $from_col ]]
            then
                board[$from_row,$to_col]="."
            fi
        fi
        # castling
        if [[ ${board[$from_row,$from_col]} == "k" ]] && [[ $from_row -eq 0 ]] && [[ $from_col -eq 4 ]]
        then
            if [[ $to_col -eq 6 ]]
            then
                board[0,5]="r"
                board[0,7]="."
            elif [[ $to_col -eq 2 ]]
            then
                board[0,3]="r"
                board[0,0]="."
            fi
        elif [[ ${board[$from_row,$from_col]} == "K" ]] && [[ $from_row -eq 7 ]] && [[ $from_col -eq 4 ]]
        then
            if [[ $to_col -eq 6 ]]
            then
                board[7,5]="R"
                board[7,7]="."
            elif [[ $to_col -eq 2 ]]
            then
                board[7,3]="R"
                board[7,0]="."
            fi
        fi

        # move the pieces
        board[$to_row,$to_col]=${board[$from_row,$from_col]}
        board[$from_row,$from_col]="."
    fi   
}

# Function to move to the next step
next_step () {
    # if the boards[current_move] is not set
    if [[ $1 == "0" ]] && [[ $current_move -gt $moves_done ]]
    then
        handle_move
        
        # copy the board state to the boards array[current_move]
        copy_board $current_move

        moves_done=$((moves_done+1))
        print_board

    elif [[ $1 == "0" ]]
    then
        # if the boards[current_move] is set - do nothing
        print_board          
    else
        # finish the game
        while [[ $current_move -le $moves_amount ]]
        do
            handle_move
            copy_board $current_move
            current_move=$((current_move+1))
        done
        moves_done=$((moves_amount))
        current_move=$((moves_amount))
        print_board
    fi
}


# Function to navigate the board
navigate_board () {
    while true
    do
        echo $what_next
        read -n 1 -s key
        read -n 1 -s enter
        if [[ $enter == "" ]]
        then
            case $key in
                d)
                    if (( current_move == moves_amount ))
                    then
                        echo "No more moves available."
                    else
                        current_move=$((current_move+1))
                        next_step "0"
                    fi
                    ;;
                a)
                    if (( current_move == 0 ))
                    then
                        print_board
                    else
                        current_move=$((current_move-1))
                        print_board
                    fi 
                    ;;
                w)
                    current_move=0
                    print_board
                    ;;
                s)
                    current_move=$((moves_done+1))
                    next_step "1"                
                    ;;
                q)
                    exit 0
                    ;;
                *)
                    echo "Invalid key pressed: $key"   
                    ;;
            esac
        fi
    done
    
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
    print_board
    navigate_board
}

main "$@"