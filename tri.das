// 🪴🪴🪴🪴🪴🪴🪴🪴🪴🪴🪴🪴🪴🪴🪴🪴🪴🪴🪴🪴🪴🪴🪴🪴😇
require daslib/media
// options debugger            // uncomment for debug in VS Code
// require daslib/debug        // uncomment for debug in VS Code
require random

// 
//

// game stuff

enum GameState
    start
    juggling
    moving
    talking1
    talking2
    witing
    purring
    tank
    lptags
    tags

var gs: GameState = GameState start

var sussy_sh <- create_managed_sound("sounds/file_name.mp3")
var dance <- create_managed_sound("sounds/output.mp3")
var thank <- create_managed_sound("sounds/output (1).mp3")
var shursh <- create_managed_sound("sounds/shursh.mp3")
var click <- create_managed_sound("sounds/click.mp3")
var purr <- create_managed_sound("sounds/purr.mp3")
var psh: PlayingSoundHandle
var letsplay <- create_managed_sound("sounds/output (2).mp3")

var time = 0.
var frame = 0

var st: bool = true
var st2: bool = true
var prt: bool = true
var tnk: bool = true
var lpst: bool = true
var tst = true
var starttime = 3.
var juggletime = 9.
var movingtime: float
var talking2time: float = 30.
var ptime = 26.
var wtime: float
var jepos: array<float2>
var mt: float
var pcolor: array<uint>
var mpos: float2

def gaem()

    if gs == GameState start
        text_out(10., 10., "🔺▲🔻", 0xffffffff)
        if time > starttime
            gs = GameState juggling
    elif gs == GameState juggling
        var seed: int4 = int4(sin(time))
        
        coord2[0][1] = lerp(coord2[0][1], coord2[0][1]+(random_float(seed)*20. + 235. + coord2[0][0]/2.)/100., sin(time))
        seed *= seed
        coord2[1][0] = lerp(coord2[1][0], random_float(seed)+ 600., abs(sin((time-starttime)*1.5)))
        coord2[0][0] = lerp(300., 100., cos(time))
        if time > juggletime
            resize(jepos, 3)
            jepos := coord2
            print("{jepos}")
            gs = GameState moving
    elif gs == GameState moving
        mt = (time - juggletime)/ 10.
        coord2[0][0] = lerp(coord2[0][0], 640., mt)
        coord2[0][1] = lerp(coord2[0][1], 100., mt)
        coord2[1][0] = lerp(coord2[1][0], 200., mt)
        coord2[1][1] = lerp(coord2[1][1], 600., mt)
        coord2[2][0] = lerp(coord2[2][0], 1080., mt)
        coord2[2][1] = lerp(coord2[2][1], 600., mt)
        if mt > 1.
            gs = GameState talking1
            movingtime = time
            jepos := coord2
            print("j{jepos}\nc{coord2}")
    elif gs == GameState talking1
        // 🤬
        if st
            sussy_sh |> play_sound()
        st = false
        coord2[0][0] = jepos[0][0]
        coord2[0][1] = jepos[0][1] + sin(time*15.)*100.
        coord2[1][0] = jepos[1][0]
        coord2[1][1] = jepos[1][1] - sin(time*15.)*100.
        coord2[2][0] = jepos[2][0]
        coord2[2][1] = jepos[2][1] - sin(time*15.)*100.
        if time > movingtime + 2.8
            gs = GameState talking2
            pcolor := colors2
    elif gs == GameState talking2
        var seed: int4 = int4(sin(time))
        if st2
            dance |> play_sound()
        st2 = false
        coord2[0][0] = jepos[0][0] + cos(time*100.)*10./(time-movingtime - 2.8)
        coord2[0][1] = jepos[0][1] + sin(time*15.)*100.  + cos(time*90.)*10./(time-movingtime - 2.8)
        coord2[1][0] = jepos[1][0] + cos(time*260.)*10./(time-movingtime - 2.8)
        coord2[1][1] = jepos[1][1] - sin(time*15.)*100./(time-movingtime - 2.8)
        coord2[2][0] = jepos[2][0] + cos(time*187.)*10./(time-movingtime - 2.8)
        coord2[2][1] = jepos[2][1] - sin(time*15.)*100. + cos(time*165.)*10./(time-movingtime - 2.8)
        for a in range(3)
            seed = seed + int4(a)
            colors2[a] = colors2[a]+uint(random_int(seed))*0x222222
        if time > talking2time
            gs = GameState witing
            colors2 := pcolor
    elif gs == GameState witing
        coord2[0][0] = jepos[0][0]
        coord2[0][1] = jepos[0][1]
        coord2[1][0] = jepos[1][0]
        coord2[1][1] = jepos[1][1]
        coord2[2][0] = jepos[2][0]
        coord2[2][1] = jepos[2][1]
        if get_mouse_button(MB_LEFT)
            if tri_intersect(coord2[0][0], coord2[0][1], coord2[1][0], coord2[1][1], coord2[2][0], coord2[2][1], mpos )
                gs = GameState purring
                wtime = time
    elif gs == GameState purring
        if prt
            psh = purr |> play_sound()
        prt = false
        coord2[0][0] = jepos[0][0]
        coord2[0][1] = jepos[0][1]
        coord2[1][0] = jepos[1][0]
        coord2[1][1] = jepos[1][1]
        coord2[2][0] = jepos[2][0]
        coord2[2][1] = jepos[2][1]
        if get_mouse_button(MB_LEFT)
            if tri_intersect(coord2[0][0], coord2[0][1], coord2[1][0], coord2[1][1], coord2[2][0], coord2[2][1], mpos )
                coord2[0][0] = jepos[0][0] + mpos[0]/10.
                coord2[0][1] = jepos[0][1]
                coord2[1][0] = jepos[1][0]
                coord2[1][1] = jepos[1][1] + mpos[0]/10.
                coord2[2][0] = coord2[2][0]
                coord2[2][1] = coord2[2][1] + mpos[0]/10.
        if is_playing(psh) == false
            gs = GameState tank
            ptime = time
    elif gs == GameState tank
        if tnk
            thank |> play_sound()
        tnk = false
        mt = (time - ptime)/ 100.
        coord2[0][0] = lerp(coord2[0][0], 640., mt)
        coord2[0][1] = lerp(coord2[0][1], 100., mt)
        coord2[1][0] = lerp(coord2[1][0], 200., mt)
        coord2[1][1] = lerp(coord2[1][1], 600., mt)
        coord2[2][0] = lerp(coord2[2][0], 1080., mt)
        coord2[2][1] = lerp(coord2[2][1], 600., mt)
        if time > ptime + 5.
            gs = GameState lptags
            ptime = time
    elif gs == GameState lptags
        if lpst
            letsplay |> play_sound()
        lpst = false
        coord2[0][0] = coord2[0][0] + sin(sin(time))
        coord2[0][1] = coord2[0][1] + cos(cos(time))
        if time > ptime + 2.
            gs = GameState tags
            ptime = time

// end of game stuff

var mesh: Mesh
// var
//     coord: array<float2>
//     indexes: array<int>
//     uv: array<float2>
//     colors: array<uint>
//     image: Image



// def init_sky()
//     sky_gradient <- create_image(2, 2, [{uint[] make_color(0.1, 0.2, 0.4);  make_color(0.25, 0.2, 0.5);
//                                                 make_color(0.0, 0.15, 0.0); make_color(0.0, 0.22, 0.0)}])
//     sky_gradient |> set_image_smooth(true)



// 'initialize' runs once when game starts and every hot-reload
[export]
def initialize
    print("\n 🔺 \n")
    set_window_title("🔺")
    // init_sky()
    push(coord2, float2(300.,500.))
    push(coord2, float2(200.,600.))
    push(coord2, float2(400.,600.))
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
    push(colors2, 0xffffff50)
    push(colors2, 0xffffff77)
    push(colors2, make_color(1., 0.2, 0.2))
    push(colors2, make_color(1., 0.2, 0.2))
    set_pixel(image2, 0,0,make_color(0.5, 0.2, 0.2))
    // mesh <- create_mesh_triangles(coord2, uv2, colors2, indexes2)
    random_seed(3)
    return

// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    time += dt
    frame++
    mpos = get_mouse_position()
    gaem()
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
    // sky_gradient |> draw_image(0.0, 0.0, make_color(1.0),
    //     float2(get_screen_width(), get_screen_height() * 4 / 5))

    // draw_image(image2, 10.0, 400.0, make_color(10.0), float2(304.,456.))
    draw_triangle_strip(image2, coord2, uv2, colors2)
    // draw_mesh(mesh, get_mouse_position()[0], get_mouse_position()[1], 0., 1.)
    return

def mod(x: float; y: float)
    return  x - y * floor(x / y)

def tri_area(x1: float; y1: float; x2: float; y2: float; x3: float; y3: float): float
    return abs((x1*(y2-y3) + x2*(y3-y1)+ x3*(y1-y2))/2.0)

def tri_intersect(x1: float; y1: float; x2: float; y2: float; x3: float; y3: float; pos: float2)
    var A = tri_area (x1, y1, x2, y2, x3, y3)
    var A1 = tri_area (pos[0], pos[1], x2, y2, x3, y3)
    var A2 = tri_area (x1, y1, pos[0], pos[1], x3, y3)
    var A3 = tri_area (x1, y1, x2, y2, pos[0], pos[1])
    return abs(A-A1-A2-A3) < 10e-10
