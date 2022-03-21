require daslib/media
// options debugger            // uncomment for debug in VS Code
// require daslib/debug        // uncomment for debug in VS Code
require fio

enum h_types
    raw
    int_
    and_
    or_
    not_
    nand_

// How this DB gonna be used?
// To save:
//  map of tiles witlh their corners, connections, specials with icon and card decks
//  characters with tile on map, items in inventory, other places, relations with items, ..., spritesheet, the rest is in GDD
//  item types: document, tool, food, cloth, transport, material, other
//  document types: card, card modifier, deck, money, license, rule?
//  ... and so on. All of that is mostly connections and. Wait. Items execute procedures.
// So these procedures must be JIT, or be interpreted. Performance doesn't matter, they run just once.
// They must know all information from database. For example, dice need to know character tile and
// need math for pseudorandom generaion, or random int source. This can be solver by function calls.
// 
var
    db_ids: array<nodeid> // not uint because daScript always use int for numbers in code:
                        // var n: uint = 0
                        //                 ^
                        // 35:16 - 35:16
                        // 30113: local variable n initialization type mismatch, uint -const = int const
    textik: string = "no text"
    tmp_data: array<int>

typedef nodeid = int
enum header
    _null // pointer to id
    _1// _null_type = null //not needed in daScript
    _2// what else than types? some metadata, node size, ...
    _3// we will need to call functions from database
    _4// and to open other files to get raw data from them
    _5// TODO data types
    _6
    _7
    _8
    _9
    _10
    _11
    _12
    _13 // rename reserved nodes when they become neede
    _14
    _15
    _rawname
    _17
    _18
    _19
    _20
    _21
    _22
    _23
    _24
    _25
    _26
    _27
    _28
    _29
    _30
    _31
    _u32 // pointer to unsigned 32 bit raw int
    _uX // first connection is u32 bit size, second is data pointer
    _34// 7 nodes reserved for other int types
    _35
    _36
    _37
    _38
    _39
    _40
    _string // connections go to raw data start u32 length and string after it.
    _42
    _43
    _44
    _45
    _file1 // raw data file. for now, it's just 1 file
    _46
    _47
    

var raw_data: array<string> // actually not raw data yet

def add_raw_file(fileName: string)
    fopen(fileName, "rw") <| $ ( f )
        fread(f) <| $ ( data )
            var file_length = length(data)
            if file_length == 0
                panic("Error: either no {fileName} file or the file is empty\n")
            push(raw_data, data)

// sadly it didn't read binary, so using text for now
def read_db()
    if is_file_exists("game.graph")
        print("map file found\n")
    else
        print("Error: no map file\n")
        return
    var file_text: string
    fopen("game.graph", "rb") <| $(f)
        file_text = fread(f)
        print("file content: {file_text}\n")
        print("t len {length(file_text)}\n")

        // var data: array<uint8>
        // fmap(f) <| $(raw)
            // data := raw
        // unsafe
            // db_ids[0] = cast<uint&>data[0]
        
        // fread(f) <| $(tmp_data: array<uint8>)
            // db_ids <- tmp_data
        
        //parsing numbers from text
        var r = 10
        var n: int = 0
        for c in file_text
            // no switch case in daScript lol
            if c == '0'
                n = 0 + n * r
            elif c == '1'
                n = 1 + n * r
            elif c == '2'
                n = 2 + n * r
            elif c == '3'
                n = 3 + n * r
            elif c == '4'
                n = 4 + n * r
            elif c == '5'
                n = 5 + n * r
            elif c == '6'
                n = 6 + n * r
            elif c == '7'
                n = 7 + n * r
            elif c == '8'
                n = 8 + n * r
            elif c == '9'
                n = 9 + n * r
            elif c == ' ' || c == '\n'
                push(db_ids, n)
                r = 1
                n = 0
                continue
            else
                continue
            if n*100 < 0 || n > 214748364
                push(db_ids, n)
                n = 0
                continue
            if n < 0
                print("\ndatabase parsing error: number is less than 0\n")
        if n != 0
            push(db_ids, n)
            n = 0
        print("db ids: {db_ids}\n")
        

[export]
def initialize
    set_window_title("TEST database")
    read_db()
    return

[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    return

[export]
def draw
    var sw = get_screen_width()
    var sh = get_screen_height()
    text_out(sw/100, sh/10, textik, 0xFFFFFFFF)
    return

def mod(x: float; y: float)
    return  x - y * floor(x / y)