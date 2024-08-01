function get_char_map(map){
    // Split the map by commas to separate different ranges/characters
    var parts = string_split(map, ",");
    
    // Initialize an array to hold the ranges
    var ranges = [];
    
    // Iterate through each part
    for(var i = 0; i < array_length(parts); i++){
        var part = parts[i];
        
        if(string_length(part) == 1){
            // If the part is a single character, just add its ord value as a single-element range
            array_push(ranges, [ord(part), ord(part)]);
        } else {
            // Split by hyphen to get the range limits
            var sub_parts = string_split(part, "-");
            var start_char = string_char_at(sub_parts[0], 1);
            var end_char = string_char_at(sub_parts[1], 1);
            array_push(ranges, [ord(start_char), ord(end_char)]);
        }
    }
    
    return ranges;
}
