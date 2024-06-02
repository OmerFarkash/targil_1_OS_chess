game_string=""

split_pgn () {

    echo "Metadata from PGN file:"
    
    # read the file line by line
    while IFS= read -r line
    do
        # if line does not start with '['
        if [[ $line =~ ^\[ ]]
        then
            # print the line
            echo "$line"
        else
            # add the line to the game string
            game_string+="$line "
        fi
    done
}

convert_to_uci () {
    python3 parse_moves.py "$game_string" > moves.txt
    game_string=$(<moves.txt)
    echo "$game_string"
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
}

main "$@"


