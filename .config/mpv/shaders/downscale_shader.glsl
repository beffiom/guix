// Downscale shader
// Author: [Author's Name]

// Define the output resolution
define OUTPUT_WIDTH 640
define OUTPUT_HEIGHT 360

// Define the input resolution
define INPUT_WIDTH 1920
define INPUT_HEIGHT 1080

// Define the downscale factor
define DOWNSCALE_FACTOR 2.0

// Define the output texture
uniform sampler2D input;

// Define the output texture coordinates
varying vec2 uv;

void main() {
  // Calculate the output texture coordinates
  uv = gl_TexCoord[0].st;

  // Downscale the input texture
  vec2 output_uv = uv * DOWNSCALE_FACTOR;

  // Sample the input texture at the downsampled coordinates
  vec4 output_color = texture2D(input, output_uv);

  // Output the downsampled color
  gl_FragColor = output_color;
}
