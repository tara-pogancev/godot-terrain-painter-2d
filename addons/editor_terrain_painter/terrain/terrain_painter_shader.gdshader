shader_type canvas_item;

uniform sampler2D mask0;
uniform sampler2D mask1;

void fragment() {
    vec4 c0 = texture(mask0, UV);
    vec4 c1 = texture(mask1, UV);
    COLOR = mix(c0, c1, c1.r); // example blending
}