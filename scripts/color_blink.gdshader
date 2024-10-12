shader_type canvas_item;

uniform float blink_speed = 2.0;
uniform bool is_blinking = false;

void fragment() {
    // The base texture color
    vec4 base_color = vec4(1.0, 1.0, 1.0, 0.4);

    // If blinking is enabled, calculate the blink effect
    if (is_blinking) {
        // Get a sine wave based on the time to create the blinking effect
        float blink_factor = abs(sin(TIME * blink_speed));

        // Interpolate between red and the base color using the blink factor
        vec4 blink_color = mix(base_color, vec4(1.0, 0.0, 0.0, 0.7), blink_factor);

        COLOR = blink_color;
    } else {
        // If not blinking, show the base texture color
        COLOR = base_color;
    }
}
