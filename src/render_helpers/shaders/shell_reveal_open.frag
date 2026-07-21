// Slide-expand-down: reveals the window from a growing top-anchored clip line, the
// compositor-native equivalent of Nucleus's shell panel reveal (previously done client-side).
// See docs/wiki/examples/open_custom_shader.frag for the uniform contract this relies on.

vec4 open_color(vec3 coords_geo, vec3 size_geo) {
    vec3 coords_tex = niri_geo_to_tex * coords_geo;
    vec4 color = texture2D(niri_tex, coords_tex.st);

    // coords_geo.y is 0 at the top edge of the window geometry and 1 at the bottom (see the
    // custom-shader docs: 0..1 spans the window geometry). Hide everything below the growing
    // clip line so the window appears to expand downward from its top edge.
    if (coords_geo.y > niri_clamped_progress) {
        color = vec4(0.0);
    }

    return color;
}
