function levenshtein(a, b) {
    var n = string_length(a);
    var m = string_length(b);
    var d = array_create(n + 1, undefined);
    
    for (var i = 0; i <= n; i++) {
        d[i] = array_create(m + 1, undefined);
        d[i][0] = i;
    }
    for (var j = 0; j <= m; j++) {
        d[0][j] = j;
    }
    
    for (var i = 1; i <= n; i++) {
        for (var j = 1; j <= m; j++) {
            var cost = (string_char_at(a, i) != string_char_at(b, j)) ? 1 : 0;
            d[i][j] = min(d[i - 1][j] + 1,       // Deletion
                          d[i][j - 1] + 1,       // Insertion
                          d[i - 1][j - 1] + cost); // Substitution
        }
    }
    return d[n][m];
}
