// Slide-collapse-up: the reverse of shell_reveal_open.frag — the visible region shrinks back
// up toward the window's top edge as the close animation progresses.

vec4 close_color(vec3 coords_geo, vec3 size_geo) {
    vec3 coords_tex = niri_geo_to_tex * coords_geo;
    vec4 color = texture2D(niri_tex, coords_tex.st);

    float visible_height = 1.0 - niri_clamped_progress;
    if (coords_geo.y > visible_height) {
        color = vec4(0.0);
    }

    return color;
}
