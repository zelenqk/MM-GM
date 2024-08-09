varying vec2 v_vTexcoord;

uniform vec2 texSize;

void main()
{
    // Define Sobel operator matrices
    mat3 sobelx = mat3(
         1.0,  2.0,  1.0,
         0.0,  0.0,  0.0,
        -1.0, -2.0, -1.0
    );
    mat3 sobely = mat3(
         1.0,  0.0,  -1.0,
         2.0,  0.0,  -2.0,
         1.0,  0.0,  -1.0
    );
    mat3 magnitudes;

    // Increase the size of the Sobel filter to make the outline thicker
    float scale = 3.0; // Adjust this value to make the outline thicker or thinner

    // Compute edge magnitudes using Sobel operator
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            vec2 coords = vec2(v_vTexcoord.x + (float(i) - 1.0) * scale / texSize.x, v_vTexcoord.y + (float(j) - 1.0) * scale / texSize.y);
            // Ensure coordinates are within texture bounds
            coords = clamp(coords, vec2(0.0), vec2(1.0));
            magnitudes[i][j] = length(texture2D(gm_BaseTexture, coords).rgb);
        }
    }

    // Compute gradients
    float x = dot(sobelx[0], magnitudes[0]) + dot(sobelx[1], magnitudes[1]) + dot(sobelx[2], magnitudes[2]);
    float y = dot(sobely[0], magnitudes[0]) + dot(sobely[1], magnitudes[1]) + dot(sobely[2], magnitudes[2]);

    // Compute final edge strength
    float edgeMagnitude = sqrt(x * x + y * y);
    float edgeStrength = (edgeMagnitude > 0.1) ? 1.0 : 0.0; // Apply a threshold to detect significant edges

    // Sample the alpha channel from the texture
    float alpha = texture2D(gm_BaseTexture, v_vTexcoord).a;

    // Output the color based on alpha and edge detection
    if (alpha == 0.0) {
        // If the background is transparent, draw the outline
        gl_FragColor = vec4(vec3(1.0, 0.647, 0.0), edgeStrength); // Hardcoded orange color with edge strength
    } else {
        // If not background (opaque area), draw fully transparent
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0); // Fully transparent
    }
}
