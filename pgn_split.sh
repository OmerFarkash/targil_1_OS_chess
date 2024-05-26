# Omer farkash
# I.D 211466362


# Verify the existence of the source PGN file.
verify_PNG () {
    if [ ! -f "$1" ]
    then
        echo "Error: The source PGN file does not exist."
        exit 1
    fi
}


# look for the diractory or create a new one
verify_diractory () {
    if [ ! -d "$1" ]
    then
        dest_dir="$1"
        echo "Created directory '$dest_dir'."
        mkdir -p "$dest_dir"
    fi
}


# Split multiple chess games from the source PGN file into individual files.
Split_files () {
    file_src="$1"
    dir_dst="$2"
    file_count=0
    output_file=""
    file_basename="${file_src%.*}"

    # Read the input file line by line
    while IFS= read -r line
    do
        # new game
        if [[ $line =~ '[Event ' ]]
        then
            # Increment file counter
            file_count=$((file_count + 1))
            # Create a new file for the new event
            output_file="$dir_dst/${file_basename}_$file_count.pgn"
            echo "Saved game to $output_file";
        fi

        # Write the line to the current file
        if [[ -n $output_file ]]
        then
            echo "$line" >> "$output_file"
        fi
        
    done < "$file_src"
        
    echo "All games have been split and saved to '$dir_dst'"
}


# Main function
Main () {
    # Check the number of arguments
    if test "$#" -ne 2;
    then
        echo "Usage: $0 <source_pgn_file> <destination_directory>"
        exit 1   
    fi

    verify_PNG "$1"
    verify_diractory "$2"
    Split_files "$1" "$2"
}

Main "$@"