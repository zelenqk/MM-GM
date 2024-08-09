function filter_by_similarity(array, input) {
    var n = array_length(array);
    
    // Create an array to store entries that are similar
    var filtered_array = array_create(0, undefined);
    
    // Convert input to lowercase for case-insensitive comparison
    input = string_lower(input);
    
    // Check each entry for similarity
    for (var i = 0; i < n; i++) {
        var entry_name = string_lower(array[i].name); // Convert to lowercase
        if (string_pos(input, entry_name) > 0) {
            // Add entry to filtered array if input is a substring of entry_name
            array_push(filtered_array, array[i]);
        }
    }
    
    return filtered_array;
}
