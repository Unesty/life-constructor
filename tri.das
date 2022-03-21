require daslib/media
options debugger            // uncomment for debug in VS Code
require daslib/debug        // uncomment for debug in VS Code


// 
//


var mesh: Mesh
// var
//     coord: array<float2>
//     indexes: array<int>
//     uv: array<float2>
//     colors: array<uint>
//     image: Image



def init_sky()
    sky_gradient <- create_image(2, 2, [{uint[] make_color(0.1, 0.2, 0.4);  make_color(0.25, 0.2, 0.5);
                                                make_color(0.0, 0.15, 0.0); make_color(0.0, 0.22, 0.0)}])
    sky_gradient |> set_image_smooth(true)



// 'initialize' runs once when game starts and every hot-reload
[export]
def initialize
    set_window_title("TEST verts")
    init_sky()
    push(coord2, float2(50.,500.))
    push(coord2, float2(92.6749,600.))
    push(coord2, float2(85.7335,600.))
    //[[ 92.6749,600; 92.6749,600; 85.7335,600; 77.734,561; 74.1133,561; 98.6749,600; 98.6749,600; 82.5871,600; 92.2536,542; 84.0597,542]]
    push(indexes2, 0) // those are nonesense. draw_mesh just ignores indexes
    push(indexes2, 0)
    push(indexes2, 0)
    push(indexes2, 0)
    push(indexes2, 0)
    push(indexes2, 0)
    push(indexes2, 0)
    push(indexes2, 0)
    push(indexes2, 0)
    push(indexes2, 0)
    push(indexes2, 0)
    push(indexes2, 0)
    push(indexes2, 0)
    push(indexes2, 0)
    push(indexes2, 0)
    push(indexes2, 0)
    push(indexes2, 0)
    push(indexes2, 0)
    push(uv2, float2(0., 0.))
    push(uv2, float2(0., 0.))
    push(uv2, float2(0., 0.))
    push(uv2, float2(0., 0.))
    push(colors2, 0x00ffff50)
    push(colors2, 0xffffff77)
    push(colors2, make_color(0.1, 0.2, 0.9))
    push(colors2, make_color(0.9, 0.2, 1.0))
    set_pixel(image2, 0,0,make_color(0.1, 0.9, 0.4))
    mesh <- create_mesh_triangles(coord2, uv2, colors2, indexes2)
    return

// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    return

// temporary solution 
var
    coord2: array<float2>
    indexes2: array<int>
    uv2: array<float2>
    colors2: array<uint>
    image2: Image <- create_image(1, 1)
    sky_gradient: Image <- create_image(128, 128)

// this function will be called every frame after 'act',
// you can draw anything in this function
[export]
def draw
    sky_gradient |> draw_image(0.0, 0.0, make_color(1.0),
        float2(get_screen_width(), get_screen_height() * 4 / 5))

    // draw_image(image2, 10.0, 400.0, make_color(10.0), float2(304.,456.))
    // draw_triangle_strip(image2, coord2, uv2, colors2)
    draw_mesh(mesh, get_mouse_position()[0], get_mouse_position()[1], 0., 1.)
    return

def mod(x: float; y: float)
    return  x - y * floor(x / y)