require daslib/media
options debugger            // uncomment for debug in VS Code
require daslib/debug        // uncomment for debug in VS Code


// 
//

var
    ents: array<Ent>
    mesh: Mesh
// or 
    coord: array<float2>
    indexes: array<int>
    uv: array<float2>
    colors: array<uint>
    image: Image <- create_image(1, 1)

struct Transform2dCmp
    id: int const = 2
    pos: float2
    rot: float
    scale: float2
    // gc_dummy : lambda           // this is here so that GC can find real representation of data

let D_Transform2d <- [[Transform2dCmp id = 2, pos = float2(0, 0), rot = 0., scale = float2(1, 1)]]

struct MeshDataCmp
    id: int = 1
    coord: array<float2>
    coordOff: int
    indexes: array<int>
    uv: array<float2>
    colors: array<uint>
    // gc_dummy : lambda           // this is here so that GC can find real representation of data

var D_MeshData: MeshDataCmp <- [[MeshDataCmp]]
def init_d_meshdata()
    var f = 0.0
    var i = 0
    while i < 4
        // var ux = floor(f/6.0) + mod(f, 2.0)
        // var uy = mod(floor(f/2.) + floor(f/3.), 2.)
        var ux = floor(f/2.)
        var uy = mod(floor(f), 2.)
        var x = ux * float(get_screen_width()) * .1 + float(get_screen_width()) * .01
        var y = uy * float(get_screen_height()) *.1 + float(get_screen_width()) * .01
        push(D_MeshData.coord, float2(x,y))
        push(D_MeshData.uv, float2(x,y))
        push(D_MeshData.colors, 0xff00ff66)
        i++
        f++
    i = 0
    var tri = 0
    while i < 3 * 3 + 1 * 3 * 3 
        push(D_MeshData.indexes, i)
        i++
        tri = i/9
    print("{D_MeshData.coord}\n")

def init_sky()
    sky_gradient <- create_image(2, 2, [{uint[] make_color(0.1, 0.2, 0.4);  make_color(0.25, 0.2, 0.5);
                                                make_color(0.0, 0.15, 0.0); make_color(0.0, 0.22, 0.0)}])
    sky_gradient |> set_image_smooth(true)


def mesh_intersect(points: array<float2>; pos: float2)
    var inside = false
    // here check if point is inside mesh
    
    return inside

def create_mesh()
    var _coord: array<float2>
    var _texcoord: array<float2>
    var _colors: array<uint>
    var _indices: array<int>
    for i in range(length(ents))
        if((ents[i].cmpIds & ents[i].MeshData.id) == 1)
            // for _i in range(length(ents[i].MeshData.coord))
            print("sf\n")
            push(coord, ents[i].MeshData.coord)
            push(uv, ents[i].MeshData.uv)
            push(colors, ents[i].MeshData.colors)
    
    print("coord {coord}\n")
    // mesh <- create_mesh_triangles(_coord, _texcoord, _colors, _indices)
    // print("why it doen't generate anything? {create_mesh_triangles(_coord, _texcoord, _colors, _indices)}\n")

enum BtnStates
    idle
    pressed

struct ButtonCmp
    id: int const = 3
    state = BtnStates idle
    on_press = @@btn_test

let D_Button <- [[ButtonCmp id = 3, state = BtnStates idle, on_press = @@btn_test]]

// we could also put fuction pointers inside button struct
// but components aren't supposed to have functions
// so instead of pointers there are function names
// def set_btnstate(state: BtnStates)
    // but this solution would be complex

def btn_test(e: int)
    print("{ents[e].id}\n")

def init_cmp
    init_d_meshdata()
    init_sky()

// text component
// it will be used to keep data needed by text render system
struct TextCmp
    id: int const = 4
    text: string = "default text"
    color: uint = 0x000000FF

var D_Text <- [[TextCmp id = 4, text = "default text"]]

def draw_texts()
    for i in range(length(ents))
        if(((ents[i].cmpIds & D_Text.id) == 1) && ((ents[i].cmpIds & D_Transform2d.id) == 1))
            text_out(ents[i].Transform2d.pos[0], ents[i].Transform2d.pos[1], ents[i].Text.text, ents[i].Text.color)

// character stuff

// range from 0 to 10
struct Skills
    conversation: uint8
    cooking: uint8
    walking: uint8
    driving: uint8
    // TODO

// range from 0 to 10
struct Needs
    food: uint8
    water: uint8
    sleep: uint8
    hygiene: uint8
    health: uint8
    sex: uint8
    occupation: uint8
    vigor: uint8
    fitness: uint8

// item can also be entity
// here item is used from inventory
struct Item
    name: string
    pic: Image
    // TODO
enum Gender
    genderless
    hermafrodite
    man
    woman

// This may be the separate components of each stat,
// but for now it's easier to have all of them in one place.
// All characters always have all of the stats anyway.
struct CharacterStatsCmp
    id: int const = 5
    name: string
    age: int
    gender: Gender
    skills: Skills
    needs: Needs
    inventory: array<Item>
    actions_remain: uint8


var character1 <- [[Ent ]] 

struct Ent
    id: int
    cmpIds: int
    MeshData: MeshDataCmp <- [[MeshDataCmp]]
    Transform2d: Transform2dCmp <- [[Transform2dCmp id = 2]]
    Button: ButtonCmp <- [[ButtonCmp id = 3]]
    Text: TextCmp&
    CharacterStats: CharacterStatsCmp



def press(pos: float2)
    var i = 0
    while i < length(ents)
        if((ents[i].cmpIds & ents[i].Button.id) == 3)
            if(mesh_intersect(ents[i].MeshData.coord,pos))
                invoke(ents[i].Button.on_press, i)
        i++




// 'initialize' runs once when game starts and every hot-reload
[export]
def initialize
    set_window_title("Calendar")
    init_cmp()
    var elen = length(ents)
    resize(ents, elen+1)
    ents[elen] <- [[Ent id = elen]]
    // ents[elen].Button.id = 3
    ents[elen].Button := D_Button
    ents[elen].Button.on_press = @@btn_test
    ents[elen].cmpIds |= D_Button.id
    // print("ents[elen].Button.id: {D_Button.id}\n")
    ents[elen].MeshData := D_MeshData
    ents[elen].cmpIds |= D_MeshData.id
    ents[elen].Text = D_Text?
    ents[elen].cmpIds |= D_Text.id
    // print("{ents[elen].Button.id}\n")
    print("{typeinfo(sizeof ents[elen])}\n")
    print("{elen}\n")
    elen++
    
    resize(ents, elen+1)
    ents[elen] <- [[Ent id = elen]]
    elen++
    
    resize(ents, elen+1)
    ents[elen] <- character1
    //create_mesh called after init of ents
    create_mesh()
    // print("mesh {mesh}\n")
    print("uv {uv}")
    set_pixel(image2, 0,0,make_color(0.1, 0.2, 0.4))


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
    image2: Image <- create_image(100, 100)
    sky_gradient: Image <- create_image(128, 128)

// this function will be called every frame after 'act',
// you can draw anything in this function
[export]
def draw
    sky_gradient |> draw_image(0.0, 0.0, make_color(1.0),
        float2(get_screen_width(), get_screen_height() * 4 / 5))
    press(get_mouse_position())
    //draw_mesh(mesh, get_mouse_position()[0], get_mouse_position()[1], 0., 1.)
    draw_triangle_strip(image, coord, uv, colors)
    // draw_triangle_strip(image2, coord2, uv2, colors2)
    return

def mod(x: float; y: float)
    return  x - y * floor(x / y)