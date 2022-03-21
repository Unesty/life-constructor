require daslib/media

struct Window
    title = "City Life RPG"
    resolution: int2 = int2(640, 480)
    antialiasing: int = 4
    vsync: bool = true

struct Options
    tile_bordersize: float = 5.
    window = Window()

var option = Options()

def apply_options()
    set_window_title(option.window.title)
    set_resolution(option.window.resolution[0], option.window.resolution[1])
    set_vsync_enabled(option.window.vsync)
    set_antialiasing(option.window.antialiasing)