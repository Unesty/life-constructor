// City Life RPG
require daslib/media
// options debugger            // uncomment for debug in VS Code
// require daslib/debug        // uncomment for debug in VS Code
require option
require objects

//
//

var
    // ents: array<Ent>
    uis: array<UIElement>
    // texts: array<TextCmp>
    characters: array<Character> // structs use arrays of int to connect to structs of other type
    tileexts: array<TileExt> // so these arrays must be updated for each struct
    items: array<Item> // so don't remove or add something too much and no too much structs
    actions: array<Action> // or how else can we solve this?
    nobjects: array<NaturalObject>
    translated_coord: array<float2>
    map_offset: float2
    map_offset_speed: float = 1./640.
    map_scale: float2 = float2(1)
    map_scale_speed: float = 0.1
    coord: array<float2>
    // indexes: array<int> // useless because dasbox doesn't use vertex indexes
    uv: array<float2>
    colors: array<uint>
    image: Image <- create_image(1, 1, [{uint[] 0xffffffff}])
    

struct DateTime
    year: int
    month: int
    day: int
    weekday: int
    hour: int
    minute: int
    // smaller not needed

struct Transform2dCmp
    pos: float2
    rot: float
    scale: float2 = float2(1)
    // gc_dummy : lambda           // this is here so that GC can find real representation of data

let D_Transform2d <- [[Transform2dCmp pos = float2(0, 0), rot = 0., scale = float2(1, 1)]]

// transforming mesh
def translate(arg_coord: array<float2>; pos: float2; scale: float2): array<float2>
    var _coord: array<float2>
    for c in range(length(arg_coord))
        push(_coord, (arg_coord[c] + pos)*scale)
    return <- _coord

struct MeshDataCmp
    enabled: bool = true
    coord: array<float2>
    coordOff: int // where coords are saved in mesh
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
    print("D_MeshData.coord: {D_MeshData.coord}\n")

def init_background()
    sky_gradient <- create_image(2, 2, [{uint[] make_color(0.3, 0.5, 0.1);  make_color(0.3, 0.5, 0.1);
                                                make_color(0.0, 0.22, 0.1); make_color(0.0, 0.22, 0.1)}])
    sky_gradient |> set_image_smooth(true)

def tri_area(x1: float; y1: float; x2: float; y2: float; x3: float; y3: float): float
    return abs((x1*(y2-y3) + x2*(y3-y1)+ x3*(y1-y2))/2.0)

def tri_intersect(x1: float; y1: float; x2: float; y2: float; x3: float; y3: float; pos: float2)
    var A = tri_area (x1, y1, x2, y2, x3, y3)
    var A1 = tri_area (pos[0], pos[1], x2, y2, x3, y3)
    var A2 = tri_area (x1, y1, pos[0], pos[1], x3, y3)
    var A3 = tri_area (x1, y1, x2, y2, pos[0], pos[1])
    return abs(A-A1-A2-A3) < 10e-10

def mesh_intersect(points: array<float2>; pos: float2)
    // here check if point is inside mesh
    var i: int = 0
    while i < length(points) - 2
        if tri_intersect(points[i][0], points[i][1], points[i+1][0], points[i+1][1], points[i+2][0], points[i+2][1], pos)
            return true
        i++
    return false



def create_mesh()
    // var _coord: array<float2>
    // var _texcoord: array<float2>
    // var _colors: array<uint>
    // var _indices: array<int>

    // add character, map meshes or use other function?
    for i in range(length(characters))
        if characters[i].MeshData.enabled
            characters[i].MeshData.coordOff = length(coord)
            push(coord, characters[i].MeshData.coord)
            push(uv, characters[i].MeshData.uv)
            push(colors, characters[i].MeshData.colors)
    
    // here creating tiles
    print("map: {map}\n")
    map_coordOff = length(coord)
    for i in range(length(map))
        print("tiles\n")
        // generate border and quad with texture
        // for that we get vector from each corner 
        // pointing to the center of quad
        // it's length is border length
        // then create quad for each edge of tile
        // then create inner quad
        // then create uv for inner quad by getting
        // top-left corner as 0
        // and length from it to others
        var tile_coords = generate_tile_geometry([[float2[4] map[i].corners[0];
        map[i].corners[1];
        map[i].corners[2];
        map[i].corners[3]]])
        print("\ntc: {tile_coords}\n")
        for c in range(16)
            push(coord, tile_coords[c])

        var innerquad_uv: float2[4]

        // TODO: compute inner quad uv

        for c in range(11)
            push(uv, float2(10.,10.))
            push(colors, 0x777777ff)
        for c in range(4)
            // push(coord, innerquad[c])
            push(uv, innerquad_uv[c])
            push(colors, 0x333333)
        push(uv, innerquad_uv[3])
        push(colors, 0x333333)
    print("coord {coord}\n")
    if length(uv) != length(coord)
        panic("uv {length(uv)} and coord {length(coord)} length aren't equal\n")
    elif length(colors) != length(coord)
        panic("colors and coord length aren't equal\n")
    // mesh <- create_mesh_triangles(_coord, _texcoord, _colors, _indices)
    // print("why it doen't generate anything? {create_mesh_triangles(_coord, _texcoord, _colors, _indices)}\n")
    for i in range(length(uis))
        print("uis\n")
        if uis[i].MeshData.enabled
            uis[i].MeshData.coordOff = length(coord)
            // for _i in range(length(ents[i].MeshData.coord))
            print("uis\n")
            push(coord, uis[i].MeshData.coord)
            push(uv, uis[i].MeshData.uv)
            push(colors, uis[i].MeshData.colors)

def generate_tile_geometry(quad: float2[4] const): float2[16]
    var _coord: float2[16]
    var innerquad: float2[4]
    var center: float2 = (quad[0]+quad[1]+quad[2]+quad[3])*0.25
    for c in range(4)
        innerquad[c] = quad[c] + normalize(center - quad[c]) * option.tile_bordersize
    _coord[0] = quad[0] // start loose edge
    _coord[1] = quad[0]
    _coord[2] = innerquad[1]
    _coord[3] = quad[1]
    _coord[4] = innerquad[2]
    _coord[5] = quad[2]
    _coord[6] = quad[3]
    _coord[7] = quad[0]
    _coord[8] = innerquad[3]
    _coord[9] = innerquad[1]
    _coord[10] = innerquad[0] // loose edge between quads
    _coord[11] = innerquad[0]
    _coord[12] = innerquad[1]
    _coord[13] = innerquad[3]
    _coord[14] = innerquad[2] // end loose edge
    _coord[15] = innerquad[2]
    return _coord


enum BtnStates
    idle
    pressed

struct ButtonCmp
    enabled = true
    state = BtnStates idle
    on_press = @@btn_test

let D_Button <- [[ButtonCmp state = BtnStates idle, on_press = @@btn_test]]

def add_button(): void
    var len = length(uis)
    resize(uis, len+1)
    uis[len].Button <- [[ButtonCmp state = BtnStates idle, on_press = @@btn_test]]


// we could also put fuction pointers inside button struct
// but components aren't supposed to have functions
// so instead of pointers there are function names
// def set_btnstate(state: BtnStates)
    // but this solution would be complex

def btn_test(e: int)
    print("{uis[e].id}\n")

def press(pos: float2)
    var i = 0
    while i < length(uis)
        if(uis[i].Button.enabled)
            if(mesh_intersect(uis[i].MeshData.coord,pos))
                invoke(uis[i].Button.on_press, i)
        i++

// text component
// it will be used to keep data needed by text render system
struct TextCmp
    // id: int
    active: bool = true
    text: string = "default text"
    color: uint = 0x000000FF
    pos: float2 = float2(50,30)

var D_Text <- [[TextCmp active = true, text = "default text", color = 0x000000FF]]

// def draw_texts()
//     for i in range(length(texts))
//         if texts[i].active
//             text_out(texts[i].pos[0], texts[i].pos[1], texts[i].text, texts[i].color)

def draw_character_stats(id: int)
    if id < length(characters)
        text_out(10., 10., "name {characters[id].name}", 0xffffffff)
        text_out(10., 30., "age {characters[id].age}", 0xffffffff)
        text_out(10., 50., "gender {characters[id].gender}", 0xffffffff)
        text_out(10., 70., "abilities {characters[id].abilities}", 0xffffffff)
        text_out(10., 90., "skills {characters[id].skills}", 0xffffffff)
        text_out(10., 110., "needs {characters[id].needs}", 0xffffffff)
        text_out(10., 130., "action points {characters[id].action_points}", 0xffffffff)
        text_out(10., 150., "move points {characters[id].move_points}", 0xffffffff)
        
def init_cmp
    init_d_meshdata()
    init_background()

// character stuff

// range from 0 to 10
struct Skills
    conversation: int
    cooking: int
    walking: int
    driving: int
    // TODO

struct Abilities
    strength: int = 10
    agility: int = 10
    talking: int = 10
    short_term_memory: int = 10
    work_term_memory: int = 10
    long_term_memory: int = 10
    creativity: int = 10
    focus: int = 10
    willpower: int = 10
    endurance: int = 10

// range from 0 to 10
struct Needs
    food: int
    water: int
    sleep: int
    hygiene: int
    health: int
    sex: int
    occupation: int
    vigor: int
    fitness: int

// This may be the separate components of each stat,
// but for now it's easier to have all of them in one place.
// All characters always have all of the stats anyway.
struct Character
    id: int = 5
    name: string
    age: float = 5.0
    gender: Gender
    skills: Skills
    abilities: Abilities
    needs: Needs
    inventory: array<int>
    tid: int // map tile below character
    action_points: int = 1
    move_points: int
    actions: array<int> // array of action ids in action array because we need to store them in db and send over net
    MeshData: MeshDataCmp <- D_MeshData
    // rect
    // texture maybe?
    // animation states maybe?
    // functions maybe?
    Transform2d: Transform2dCmp <- Transform2dCmp()

def nothing()
    print("\nERROR: nothing invoked\n")
    return
def te_nothing(gteid: int; tid: int; teid: int)
    print("\nERROR: nothing invoked\n")
    return

// is it needed?
// actions are what is performed using items
// but items can have their actions too
// For example when player throws dice
// functions need to know player character
// pointer or id in array of characters
// that id may be changed when characters removed
// so pointer is more reliable.
// So when player throws dice, function
// generates pseudorandom number from turn,
// map seed and character pointer.
// But pointers are unsafe, so in case of id,
// we need to update all character ids
// after each character add, remove,
// and that id must be saved in character struct.
// Random number will be used to give
// character moves. Items could also give
// moves. These moves could be used on this turn.
// So in one turn character could perform
// defined in game rules struct number of actions,
// and move by number of tiles from character struct,
// and number of social action from game rules struct and
// character social skill.
// So we need separate actions for do, move, social.
// But social part will be very complex, so don't implement it.
// So dice function would need user id.
// Hug function doesn't need item, but need 2 or more characters.
// Give Item function need 2 character and item of first character
// to copy to second and remove from first.
// Slip function needs tile and character.
// All these functions may be connected to cards, but how?
// Cards don't perform them, they are arbitrary items for these actions.
// But they are still used, but optionally.
// Multiple docs may be used in one action,
// so calling actions from items not an option,
// but for reliability items could add functions to action queue.
// So these are actions, but item functions are performed by items themself.
def empty_item_function(item: Item)
    return

def print_chara_name(action: Action)
    text_out(10., 10., characters[action.characters[0]].name, 0xffffffff)

// item can also be entity
// here item is used from inventory
struct Item
    id: int // will be used to save in database
    name: string
    pic: Image
    userid: int // id of character in characters array
    // item functions use Items and Characters and Tiles as inputs
    // so 
    begin_turn: int
    end_turn: int
    use: int
    // on_drop: int
    // on_pick: int
    // on_break: int
    dropped: bool = true

// these items can only be used by tile, currently unused
struct TileItem
    name: string
    pic: Image
    begin_turn: int
    end_turn: int
    use: int

struct ItemModifier
    // modifiers modify properties of item
    // which propeeries can item have?
    // for example jackhammer can have electric power
    // while card can't
    name: string

// item prefabs

def urandom(arg: int[3]): int
    // saw waves, not very random, better than nothing
    return abs((((((arg[0]*arg[1]*arg[2]*47 % 97 % 68 % 52) / 5) + 3) % 34 * 7) % 11  % 7 % 6)+1)

def throw_dice(action: Action)
    // check if dice exists in action
    // then this item will be used
    // and that action will be added to game analytics
    // if items[action.items[0]].id == D_dice.id
    characters[action.characters[0]].move_points = urandom([[int[3] action.characters[0]; D_mapgen.seed; gp.turn.number]])
var D_dice <- [[Item id = 6, name = "dice"]]

// struct Deck
//     name: string //saved in table
//     max_size: int
//     cards: array<int>
// decks add complexity

    // TODO
enum Gender
    genderless
    hermafrodite
    man
    woman

struct Action
    items: array<int> // copies or ids? ids are easier to understand
    characters: array<int>
    tiles: array<int> // for case when tile changes other tile
    proc = @@print_chara_name
// Do not add or remove or add premade actions on runtime, or it will break database.
// We could use table to avoid that issue, let's look into that later.
var action_prefabs <- [[
    Action[2] [[Action proc = @@print_chara_name]]; [[Action proc = @@print_chara_name]]
]]

// UI stuff

struct UIElement
    id: int
    MeshData: MeshDataCmp <- [[MeshDataCmp]]
    Transform2d: Transform2dCmp <- [[Transform2dCmp]]
    Button: ButtonCmp <- [[ButtonCmp]]
    // Text: TextCmp&

// this not needed
// def draw_uis()
    // text_out(10, 10, "{gp.turn.time}", 0xff00ff65)
    // for uie in uis
        // why?
    

// map stuff

var map_coordOff: int // where tiles coords are saved in mesh, tile extensions are separate

struct NaturalObject
    MeshData: MeshDataCmp <- [[MeshDataCmp]]
    //animation = @@

def bend_pines()
// update coords of each tree to make it move on wind
    return

// tiles

struct Tile
    tid: int // id in map array
    connections: int[4]
    corners: float2[4]
    // coordOff of tiles is calculated from map because tiles have 12 vertices and they are packed together
    characters: array<int>
    exts: array<int> // why not ids? Ah, because of functions we need ids!

// tile specials
struct TileExt
    tid: int // id of tile in map array
    teid: int // id of ext in exts
    image: Image
    // tile can have many extensions
    // and extensions can create combinations
    // how to make deck an array of int?
    // because Items have variables, so they must be saved too
    // serialization exists for such cases
    // Then I need to (de)convert structures to graph somehow.
    // 
    // decks: table<string; Deck> // using decks to create tile functions is interesting, but complex
    step_schedule: array<int> // 0 item will be used on each turn and moved to end
    turn_schedule: array<int> //
    containing_items: array<int>
    on_step = @@te_default_proc // proc to call each on character step in
    turn = @@te_default_proc // proc to call each turn

def play_top_card_on_turn(gteid: int; tid: int; teid: int)
    // do action from top card, then move it to bottom of deck
    var _prevcard = tileexts[map[tid].exts[teid]].turn_schedule[0] // accessing by id is quite complex here
    var _proc = actions[items[tileexts[map[tid].exts[teid]].turn_schedule[0]].use].proc
    // characters, items data must be updated in move action
    invoke(_proc,actions[items[tileexts[map[tid].exts[teid]].turn_schedule[0]].use])
    // check if item didn't move or exhaust
    if tileexts[map[tid].exts[teid]].turn_schedule[0] == _prevcard
        push(tileexts[map[tid].exts[teid]].turn_schedule, tileexts[map[tid].exts[teid]].turn_schedule[0])
        erase(tileexts[map[tid].exts[teid]].turn_schedule, 0)

def play_top_card_on_step(gteid: int; tid: int; teid: int /*why no pointers? there are, but idk*/)
    // do action from top card, then move it to bottom of deck
    var _prevcard = tileexts[map[tid].exts[teid]].step_schedule[0]
    var _proc = actions[items[tileexts[map[tid].exts[teid]].step_schedule[0]].use].proc
    // characters, items data must be updated in move action
    invoke(_proc,actions[items[tileexts[map[tid].exts[teid]].step_schedule[0]].use])
    // check if item didn't move or exhaust
    if tileexts[map[tid].exts[teid]].turn_schedule[0] == _prevcard
        push(tileexts[map[tid].exts[teid]].step_schedule, tileexts[map[tid].exts[teid]].step_schedule[0])
        erase(tileexts[map[tid].exts[teid]].step_schedule, 0)

def te_default_proc(gteid: int; tid: int; teid: int)
    if length(tileexts[map[tid].exts[teid]].turn_schedule) != 0
        play_top_card_on_turn(gteid, tid, teid)
    if length(tileexts[map[tid].exts[teid]].step_schedule) != 0
        play_top_card_on_step(gteid, tid, teid)
    print(" tid")

def te_start(gteid: int; tid: int; teid: int)
    // get data from game init struct
    // or use random values for characters
    spawn_character(0)
    print("\nGame started\n")
    tileexts[gteid].turn = @@te_nothing
var start_tileext: TileExt <- [[TileExt image <- create_image("images/start_300-500x300.gif"), turn = @@te_start]]



var start_tile: Tile <- [[Tile corners = [[float2[4] float2(0.,0.); float2(20.,0.); float2( 20.,20.); float2(0.,20.)]]]]

// road signs are TileExt
// struct TrafficSign

// buildings are TileExt

var house: TileExt

var map: array<Tile>

struct Mapgen
    seed = 123
    proc = @@default_map_generator
var D_mapgen = Mapgen()
def default_map_generator()
    // print("\nTODO: generate map\n")
    var teid = 0
    resize(tileexts, teid+1)
    tileexts[teid] := start_tileext
    var tid = 0
    resize(map, tid+1)
    map[tid] := start_tile
    push(map[tid].exts, teid)
    tid++
    
    // var sz = length(map)
    // 

    // d_mg_add_tile(_tile)

def d_mg_add_tile(ontile: int)
    var tid = length(map)
    resize(map, tid+1)
    map[tid].tid = tid
    map[tid].connections[0]
    // get side
    // set common vertices
    for i in range(4)
        // set remaining vertices
        map[tid].corners[i]
    // add exts for buildings, or for road event
    // map[tid].exts = tid
    



// gameplay stuff

struct GameInit
    characters: array<Character>
    actions_per_turn: int
    // moves_per_turn
    // max_moves_per_turn
    time_scale: float
    // 

var ginit: GameInit

def game_init()
    // create characters
    var cnt = 3
    for c in range(cnt)
        var _chara <- Character()
        _chara.id = c
        
        push_clone(ginit.characters, _chara)
    // set global values

struct FinishStats
    turn: int
    id: int

struct GameResults
    finishers: array<FinishStats>
    

enum TurnState
    start // run functions on start of turn
    starting // waiting for these functions
    running // players can play on this state
    end // run functions on end of turn
    ending // waiting for all end routines, like data to save/load

struct GameTurn
    timeout: float = 1.0
    starting_timeout: float = 0.1 
    time: float
    number: int = 0
    state: TurnState = TurnState start

struct GamePlay
    turn = GameTurn()
    selected_character: int
    time_scale: float = 10000.
var gp = GamePlay()


def turn_end()
    // perform characters actions
    for chara in characters
        // each character has an array of possible actions
        // and array of actions to perform at the end of turn
        // one turn - one action
        // so we let each character to act, but not during game_turn()
        // so here we run action from chara action array,
        // then remove it
        if chara.action_points > 0 && length(chara.actions) > 0
            var _a <- actions[chara.actions[0]]
            print("{_a}")
            chara.action_points--
        chara.age += 0.000000003168809 * gp.time_scale

    // perform map actions
    for gteid in range(length(tileexts))
        print("{tileexts}")
        let tid = tileexts[gteid].tid
        let teid = tileexts[gteid].teid
        if tileexts[map[tid].exts[teid]].turn != null && tileexts[map[tid].exts[teid]].turn != @@te_nothing
            invoke(tileexts[map[tid].exts[teid]].turn, gteid, tid, teid)
    // perform game actions
    
def turn_start()
    for chara in characters
        chara.action_points = 1
    print("\n{urandom([[int[3] 1; D_mapgen.seed; gp.turn.number]])}\n")
    // print("characters: {characters}\n")


// TODO: we need to get options for game
def create_game()
    // init gameplay stuff, generate map
    default_map_generator()
    
    // create characters
def spawn_character(tid: int)
    var _chara <- [[Character name = "Void"]]
    _chara.id = length(characters)
    _chara.skills.conversation = 10
    var _dice := D_dice
    var isz = length(items)
    var csz = length(characters)
    // TODO: spawn item proc to add action to actions
    var _action <- [[Action]]
    push(_action.characters, csz)
    push(_action.items, isz)
    var asz = length(actions)
    _action.proc = @@throw_dice
    push_clone(actions, _action)
    _dice.use = asz
    push_clone(items, _dice)
    push(_chara.inventory, isz)
    _chara.tid = tid
    // add character to mesh
    _chara.MeshData.coordOff = length(coord)
    // generate geometry
    let corners = 6
    let _color = 0x000000ff + 0xff000000 * uint(urandom([[int[3] _chara.id; _chara.id; _chara.id]]))
    // for v in range(corners)
    _chara.MeshData := D_MeshData // TODO generate playing chip
    for i in _chara.MeshData.coord
        push(coord, i)
    for i in _chara.MeshData.uv
        push(uv, i)
    for i in _chara.MeshData.colors
        push(colors, (i+_color)/2u)
    resize(characters, csz+1)
    characters[csz] := _chara
    push(map[0].characters, csz)
    print("spawned {_chara.name}")

// 'initialize' runs once when game starts and every hot-reload
[export]
def initialize
    print("options: {option}\n")
    apply_options()

    create_game()

    //create_mesh called after init of objects
    create_mesh()

    init_cmp()
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
    
    if get_mouse_button(MB_RIGHT)
        map_scale += float2(get_mouse_scroll_delta()*map_scale_speed)
        map_offset += get_mouse_velocity()*map_offset_speed
        translated_coord <- translate(coord, map_offset, map_scale)
    if get_mouse_button(MB_LEFT)
        press(get_mouse_position())

    // gp.turn.time += dt
    // if gp.turn.time > gp.turn.timeout
    //     print("{gp.turn.timeout}")
    //     gp.turn.time = 0.0
    //     turn_end()
    if gp.turn.state == TurnState start
        print("{gp.turn.number}")
        turn_start()
        // if not all routines finished
        // gp.turn.state = TurnState starting
        // else
        gp.turn.state = TurnState running
    // elif gp.turn.state == TurnState starting
        // check if all start routines finished
    elif gp.turn.state == TurnState running
        //
        gp.turn.time += dt
        if gp.turn.time > gp.turn.timeout
            gp.turn.state = TurnState end
            // print("{gp.turn.timeout}")
            gp.turn.time = 0.0
            turn_end()
    elif gp.turn.state == TurnState end
        // if not all end routines finished
            // gp.turn.state = TurnState ending
        // else
        gp.turn.number++
        gp.turn.state = TurnState start
    // elif gp.turn.state == TurnState ending


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
    //draw_mesh(mesh, get_mouse_position()[0], get_mouse_position()[1], 0., 1.)
    draw_triangle_strip(image, translated_coord, uv, colors)
    // draw_triangle_strip(image2, coord2, uv2, colors2)
    // draw_texts() // case-specific draw instead, which is slow, but easy
    draw_character_stats(gp.selected_character)
    return

def mod(x: float; y: float): float
    return  x - y * floor(x / y)

def mod(x: int; y: int; steps: int): int
    return x - y * int(floor(float(x*steps) / float(y*steps)))

def line_line_intersection(p1: float2; p2: float2; p3: float2; p4: float2): float2
    var d = (p2[0] - p1[0]) * (p4[1] - p3[1]) - (p2[1] - p1[1]) * (p4[0] - p3[0])
    if d <= 0.00000000000000001 && d >= -0.00000000000000001
        return float2(0.) //false
    var u = ((p3[0] - p1[0]) * (p4[1] - p3[1]) - (p3[1] - p1[1]) * (p4[0] - p3[0])) / d
    var v = ((p3[0] - p1[0]) * (p2[1] - p1[1]) - (p3[1] - p1[1]) * (p2[0] - p1[0])) / d
    if u < 0.0f || u > 1.0f || v < 0.0f || v > 1.0f
        return float2(0.) //false;
    return float2(p1[0] + u * (p2[0] - p1[0]), p1[1] + u * (p2[1] - p1[1]))
