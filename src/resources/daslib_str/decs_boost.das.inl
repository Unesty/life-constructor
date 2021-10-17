//
// AUTO-GENERATED FILE - DO NOT EDIT!!
//

"options indenting = 4\n"
"options no_unused_block_arguments = false\n"
"options no_unused_function_arguments = false\n"
"options no_aot\n"
"options multiple_contexts\n"
"\n"
"module decs_boost shared private\n"
"\n"
"require daslib/decs public\n"
"\n"
"require daslib/ast_boost\n"
"require daslib/templates_boost\n"
"require daslib/strings_boost\n"
"require daslib/ast_block_to_loop\n"
"\n"
"/*\n"
"from:\n"
"    query ( ) <| $ ( pos:float3&; vel:float3; col:uint=0x12345678 )\n"
"        pos += vel\n"
"to:\n"
"    for_each_archetype ( ERQ_HASH, @@ => [[EcsRequest req <- [[string \"pos\"; \"ve"
"l\"]] ]] ) <| $ ( arch )\n"
"        for pos, vel in get(arch,\"pos\",type<float3>), get_ro(arch,\"vel\",type<flo"
"at3>), get_default_ro(arch,\"col\",0x12345678)\n"
"            tag\n"
"*/\n"
"\n"
"[block_macro(name=\"REQUIRE\")]\n"
"class DecsReq : AstFunctionAnnotation {}\n"
"\n"
"[block_macro(name=\"REQUIRE_NOT\")]\n"
"class DecsReqN : AstFunctionAnnotation {}\n"
"\n"
"[structure_macro(name=\"decs_template\")]\n"
"class DecsTemplate : AstStructureAnnotation\n"
"    def override apply ( var st:StructurePtr; var group:ModuleGroup; args:Annota"
"tionArgumentList; var errors : das_string ) : bool\n"
"        let ppref = decs_prefix(args)\n"
"        let prefix = (ppref is yes) ? (ppref as yes) : \"{st.name}_\"\n"
"        var fnApply <- new [[Function() at=st.at, atDecl=st.at, name:=\"apply_dec"
"s_template\"]]\n"
"        fnApply.flags |= FunctionFlags generated\n"
"        fnApply.result <- new [[TypeDecl() baseType=Type tVoid, at=st.at]]\n"
"        fnApply.arguments |> emplace_new <| new [[Variable() at=st.at,\n"
"            name := \"cmp\",\n"
"            _type <- clone_type() <| typeinfo(ast_typedecl type<ComponentMap>)\n"
"        ]]\n"
"        fnApply.arguments |> emplace_new <| new [[Variable() at=st.at,\n"
"            name := \"src\",\n"
"            _type <- new [[TypeDecl() at=st.at,\n"
"                baseType=Type tStructure,\n"
"                structType = get_ptr(st)\n"
"            ]]\n"
"        ]]\n"
"        var fnErase <- new [[Function() at=st.at, atDecl=st.at, name:=\"remove_de"
"cs_template`{st.name}\"]]\n"
"        fnErase.flags |= FunctionFlags generated\n"
"        fnErase.result <- new [[TypeDecl() baseType=Type tVoid, at=st.at]]\n"
"        fnErase.arguments |> emplace_new <| new [[Variable() at=st.at,\n"
"            name := \"cmp\",\n"
"            _type <- clone_type() <| typeinfo(ast_typedecl type<ComponentMap>)\n"
"        ]]\n"
"\n"
"        var blkApply <- new [[ExprBlock() at=st.at]]\n"
"        var blkErase <- new [[ExprBlock() at=st.at]]\n"
"        for fld in st.fields\n"
"            var cset <- new [[ExprCall() at=fld.at, name:=\"decs::set\"]]\n"
"            cset.arguments |> emplace_new <| new [[ExprVar() at=fld.at, name:=\"c"
"mp\"]]\n"
"            cset.arguments |> emplace_new <| new [[ExprConstString() at=fld.at, "
"value:=\"{prefix}{fld.name}\"]]\n"
"            cset.arguments |> emplace_new <| new [[ExprField() at=fld.at,\n"
"                    value <- new [[ExprVar() at=fld.at, name:=\"src\"]],\n"
"                    name := fld.name\n"
"                ]]\n"
"            blkApply.list |> emplace(cset)\n"
"            var cremove <- new [[ExprCall() at=fld.at, name:=\"decs::remove\"]]\n"
"            cremove.arguments |> emplace_new <| new [[ExprVar() at=fld.at, name:"
"=\"cmp\"]]\n"
"            cremove.arguments |> emplace_new <| new [[ExprConstString() at=fld.a"
"t, value:=\"{prefix}{fld.name}\"]]\n"
"            blkErase.list |> emplace(cremove)\n"
"        fnApply.body <- blkApply\n"
"        fnErase.body <- blkErase\n"
"        if !(compiling_module() |> add_function(fnApply))\n"
"            panic(\"failed to add apply_decs_template, can't add function {fnAppl"
"y.name}\")\n"
"        if !(compiling_module() |> add_function(fnErase))\n"
"            panic(\"failed to add remove_decs_template, can't add function {fnEra"
"se.name}\")\n"
"        return true\n"
"\n"
"variant ItCheck\n"
"    yes : string\n"
"    no  : bool\n"
"\n"
"[macro_function]\n"
"def private decs_prefix ( arg:AnnotationArgumentList )\n"
"    var p = find_arg ( \"prefix\", arg)\n"
"    if p is tString\n"
"        return [[ItCheck yes=p as tString]]\n"
"    elif p is tBool\n"
"        return [[ItCheck yes=\"\"]]\n"
"    else\n"
"        return [[ItCheck no=true]]\n"
"\n"
"[macro_function]\n"
"def private is_decs_template ( v:VariablePtr )\n"
"    if v._type.baseType != Type tStructure\n"
"        return [[ItCheck no=true]]\n"
"    var p = v.annotation |> decs_prefix\n"
"    if p is no\n"
"        for ann in v._type.structType.annotations\n"
"            if eq(ann.annotation.name,\"decs_template\")\n"
"                p = ann.arguments |> decs_prefix\n"
"                return p is yes ? p : [[ItCheck yes=\"{v._type.structType.name}_\""
"]]\n"
"    return p\n"
"\n"
"[macro_function]\n"
"def build_req_from_args ( qblk:ExprBlock? )\n"
"    var req : EcsRequest\n"
"    for a in qblk.arguments\n"
"        if a.init==null\n"
"            let detp = a |> is_decs_template\n"
"            if detp is yes\n"
"                for f in a._type.structType.fields\n"
"                    if f.init == null\n"
"                        req.req |> push(\"{detp as yes}{f.name}\")\n"
"            else\n"
"                req.req |> push(string(a.name))\n"
"    for aa in qblk.annotations\n"
"        let isreq = eq(aa.annotation.name,\"REQUIRE\")\n"
"        let isreqn = eq(aa.annotation.name,\"REQUIRE_NOT\")\n"
"        if isreq || isreqn\n"
"            for ab in aa.arguments\n"
"                if ab.basicType==Type tBool && ab.bValue\n"
"                    (isreq ? req.req : req.reqn) |> push(string(ab.name))\n"
"    compile_request(req)\n"
"    return <- req\n"
"\n"
"[macro_function]\n"
"def getter_name ( a; const_parent:bool )\n"
"    var getter = \"get_ro\"\n"
"    if typeinfo(stripped_typename a)==\"ast::FieldDeclaration\"\n"
"        if a.init != null\n"
"            getter = \"get_default_ro\"\n"
"        elif !const_parent\n"
"            getter = \"get\"\n"
"    else\n"
"        if a.init != null\n"
"            if a._type.flags.ref || !a._type.flags.constant\n"
"                macro_error(compiling_program(),a.at,\"argument {a.name} has defa"
"ult value, it can't be & or var\")\n"
"                return \"\"\n"
"            getter = \"get_default_ro\"\n"
"        elif a._type.isRef && !a._type.isRefType\n"
"            if a._type.flags.constant\n"
"                macro_error(compiling_program(),a.at,\"argument {a.name} is both "
"& and constant\")\n"
"                return \"\"\n"
"            getter = \"get\"\n"
"    return getter\n"
"\n"
"[macro_function]\n"
"def private append_iterator ( arch_name:string; var qloop:smart_ptr<ExprFor>; a;"
" prefix:string; const_parent : bool = false )\n"
"    let qli = length(qloop.iterators)\n"
"    qloop.iterators |> resize( qli + 1 )\n"
"    qloop.iterators[qli] := \"{prefix}{a.name}\"\n"
"    qloop.iteratorsAt |> push(a.at)\n"
"    var ftype <- clone_type(a._type)\n"
"    ftype.flags &= ~ TypeDeclFlags constant\n"
"    ftype.flags &= ~ TypeDeclFlags ref\n"
"    var getter = getter_name(a,const_parent)\n"
"    if empty(getter)\n"
"        return false\n"
"    var cget <- new [[ExprCall() name:=getter, at=a.at]]\n"
"    cget.arguments |> emplace_new <| new [[ExprVar() at=a.at, name:=arch_name]]\n"
"    cget.arguments |> emplace_new <| new [[ExprConstString() at=a.at, value:=\"{p"
"refix}{a.name}\"]]\n"
"    if getter==\"get_default_ro\"\n"
"        cget.arguments |> emplace_new <| clone_expression(a.init)\n"
"    else\n"
"        cget.arguments |> emplace_new <| new [[ExprTypeDecl() at=a.at, typeexpr<"
"-ftype]]\n"
"    qloop.sources |> emplace(cget)\n"
"    return true\n"
"\n"
"[macro_function]\n"
"def private append_index_lookup ( arch_name:string; var qblock:smart_ptr<ExprBlo"
"ck>; a; prefix:string; const_parent : bool = false )\n"
"    var ftype <- clone_type(a._type)\n"
"    ftype.flags &= ~ TypeDeclFlags constant\n"
"    ftype.flags &= ~ TypeDeclFlags ref\n"
"    var getter = getter_name(a,const_parent)\n"
"    if empty(getter)\n"
"        return false\n"
"    var iget : ExpressionPtr\n"
"    if getter==\"get_default_ro\"\n"
"        unsafe\n"
"            iget <- clone_expression(a.init)\n"
"    else\n"
"        var cget <- new [[ExprCall() name:=getter, at=a.at]]\n"
"        cget.arguments |> emplace_new <| new [[ExprVar() at=a.at, name:=arch_nam"
"e]]\n"
"        cget.arguments |> emplace_new <| new [[ExprConstString() at=a.at, value:"
"=\"{prefix}{a.name}\"]]\n"
"        cget.arguments |> emplace_new <| new [[ExprTypeDecl() at=a.at, typeexpr<"
"-ftype]]\n"
"        iget <- new [[ExprAt() at=a.at,\n"
"                subexpr <- cget,\n"
"                index <- new [[ExprVar() at=a.at, name:=\"entity_index\"]]\n"
"            ]]\n"
"    var vlet <- new [[ExprLet() at=a.at, atInit=a.at]]\n"
"    vlet.variables |> emplace_new() <| new [[Variable() at = a.at,\n"
"        name := \"{prefix}{a.name}\",\n"
"        _type <- clone_type(a._type),\n"
"        init <- iget,\n"
"        flags = VariableFlags can_shadow\n"
"        ]]\n"
"    qblock.list |> emplace(vlet)\n"
"    return true\n"
"\n"
"enum private DecsQueryType\n"
"    query\n"
"    eid_query\n"
"    find_query\n"
"\n"
"[call_macro(name=\"query\")]\n"
"class DecsQueryMacro : AstCallMacro\n"
"    def override visit ( prog:ProgramPtr; mod:Module?; var expr:smart_ptr<ExprCa"
"llMacro> ) : ExpressionPtr\n"
"        let totalArgs = length(expr.arguments)\n"
"        if totalArgs!=1 && totalArgs!=2\n"
"            macro_error(prog,expr.at,\"expecting query($(block_with_arguments)) o"
"r query(eid,$(block_with_arguments))\")\n"
"            return [[ExpressionPtr]]\n"
"        let qt = totalArgs==2 ? DecsQueryType eid_query : DecsQueryType query\n"
"        let block_arg_index = totalArgs-1\n"
"        return self->implement(expr, block_arg_index, qt)\n"
"    def implement ( var expr:smart_ptr<ExprCallMacro>; block_arg_index:int; qt:D"
"ecsQueryType ) : ExpressionPtr\n"
"        for arg in expr.arguments\n"
"            if arg._type.isAutoOrAlias\n"
"                macro_error(compiling_program(),expr.at,\"argument types are not "
"fully inferred\")\n"
"                return [[ExpressionPtr]]\n"
"        if !(expr.arguments[block_arg_index] is ExprMakeBlock)\n"
"            macro_error(compiling_program(),expr.at,\"expecting $(block_with_argu"
"ments)\")\n"
"            return [[ExpressionPtr]]\n"
"        let mblk = expr.arguments[block_arg_index] as ExprMakeBlock\n"
"        let qblk = mblk._block as ExprBlock\n"
"        if length(qblk.arguments)==0\n"
"            macro_error(compiling_program(),expr.at,\"expecting query($(block_wit"
"h_arguments)), arguments are missing\")\n"
"            return [[ExpressionPtr]]\n"
"        let prefix = \"__{expr.at.line}_desc\"\n"
"        let arch_name = \"{prefix}_arch\"\n"
"        var req <- build_req_from_args(qblk)\n"
"        let vreq = verify_request(req)\n"
"        if !vreq.ok\n"
"            macro_error(compiling_program(),expr.at,\"incorrect query, {vreq.erro"
"r}\")\n"
"            return [[ExpressionPtr]]\n"
"        var qblock : ExpressionPtr\n"
"        unsafe\n"
"            if qt==DecsQueryType eid_query\n"
"                qblock <- quote() <|\n"
"                    for_eid_archetype (tag_eid, tag_req, tag_erq) <| $ ( tag_arc"
"h, entity_index )\n"
"                        tag_loop\n"
"            elif qt==DecsQueryType find_query\n"
"                qblock <- quote() <|\n"
"                    for_each_archetype_find (tag_req, tag_erq) <| $ ( tag_arch )"
"\n"
"                        tag_loop\n"
"                        return false\n"
"            elif qt==DecsQueryType query\n"
"                qblock <- quote() <|\n"
"                    for_each_archetype (tag_req, tag_erq) <| $ ( tag_arch )\n"
"                        tag_loop\n"
"            else\n"
"                macro_error(compiling_program(),expr.at,\"internal error. unsuppo"
"rted query type\")\n"
"                return [[ExpressionPtr]]\n"
"        qblock |> force_at(expr.at)\n"
"        // @@ => [[EcsQuery ...]]\n"
"        var erq_blk <- new [[ExprBlock() at=expr.at,\n"
"            returnType <- new [[TypeDecl() at=expr.at, baseType=Type autoinfer]]"
",\n"
"            blockFlags = ExprBlockFlags isClosure\n"
"        ]]\n"
"        erq_blk.list |> emplace_new <| new [[ExprReturn() at=expr.at,\n"
"            subexpr <- convert_to_expression(req, expr.at),\n"
"            returnFlags = ExprReturnFlags moveSemantics\n"
"        ]]\n"
"        var erq_fun <- new [[ExprMakeBlock() at=expr.at,\n"
"            mmFlags=ExprMakeBlockFlags isLocalFunction,\n"
"            _block <- erq_blk\n"
"        ]]\n"
"        var kaboom : array<tuple<string;string>>\n"
"        var qtop : ExpressionPtr\n"
"        if qt==DecsQueryType eid_query\n"
"            var qlbody <- new [[ExprBlock() at=qblk.at]]\n"
"            for a in qblk.arguments\n"
"                let detp = a |> is_decs_template\n"
"                if detp is yes\n"
"                    kaboom |> push <| [[auto string(a.name),detp as yes]]\n"
"                    for f in a._type.structType.fields\n"
"                        if !append_index_lookup(arch_name, qlbody, f, detp as ye"
"s, a._type.flags.constant)\n"
"                            return [[ExpressionPtr]]\n"
"                else\n"
"                    if !append_index_lookup(arch_name, qlbody, a, \"\")\n"
"                        return [[ExpressionPtr]]\n"
"\n"
"            for l in qblk.list\n"
"                qlbody.list |> emplace_new <| clone_expression(l)\n"
"            for fl in qblk.finalList\n"
"                qlbody.finalList |> emplace_new <| clone_expression(fl)\n"
"            convert_block_to_loop(qlbody, true, false)\n"
"            qtop <- qlbody\n"
"        else\n"
"            // for s1, s2 ...\n"
"            var qloop <- new [[ExprFor() at=qblk.at, visibility=qblk.at]]\n"
"            qloop.allowIteratorOptimization = true\n"
"            for a in qblk.arguments\n"
"                let detp = a |> is_decs_template\n"
"                if detp is yes\n"
"                    kaboom |> push <| [[auto string(a.name),detp as yes]]\n"
"                    for f in a._type.structType.fields\n"
"                        if !append_iterator(arch_name, qloop, f, detp as yes, a."
"_type.flags.constant)\n"
"                            return [[ExpressionPtr]]\n"
"                else\n"
"                    if !append_iterator(arch_name, qloop, a, \"\")\n"
"                        return [[ExpressionPtr]]\n"
"            var qlbody <- new [[ExprBlock() at=qblk.at]]\n"
"            for l in qblk.list\n"
"                qlbody.list |> emplace_new <| clone_expression(l)\n"
"            for fl in qblk.finalList\n"
"                qlbody.finalList |> emplace_new <| clone_expression(fl)\n"
"            if qt==DecsQueryType query\n"
"                convert_block_to_loop(qlbody, false, true )\n"
"            else\n"
"                convert_block_to_loop(qlbody, false, false )\n"
"            qloop.body <- qlbody\n"
"            qtop <- qloop\n"
"        apply_template(qtop) <| $ ( rules )\n"
"            for kb in kaboom\n"
"                rules |> kaboomVarField(kb._0,kb._1)\n"
"        apply_template(qblock) <| $ ( rules )\n"
"            if qt==DecsQueryType eid_query\n"
"                rules |> replaceVariable(\"tag_eid\") <| clone_expression(expr.arg"
"uments[0])\n"
"            rules |> replaceVariable(\"tag_erq\") <| erq_fun\n"
"            rules |> replaceBlockArgument(\"tag_arch\") <| arch_name\n"
"            rules |> replaceVariable(\"tag_req\") <| new [[ExprConstUInt() at=expr"
".at, value=req.hash]]\n"
"            rules |> replaceVariable(\"tag_loop\") <| qtop\n"
"        var qres <- move_unquote_block(qblock)\n"
"        assert(length(qres.list)==1 && length(qres.finalList)==0)\n"
"        var rqres <- qres.list[0]\n"
"        qres := null\n"
"        return <- rqres\n"
"\n"
"[call_macro(name=\"find_query\")]\n"
"class DecsFindQueryMacro : DecsQueryMacro\n"
"    def override visit ( prog:ProgramPtr; mod:Module?; var expr:smart_ptr<ExprCa"
"llMacro> ) : ExpressionPtr\n"
"        if length(expr.arguments)!=1\n"
"            macro_error(prog,expr.at,\"expecting find_query($(block_with_argument"
"s))\")\n"
"            return [[ExpressionPtr]]\n"
"        return self->implement(expr, 0, DecsQueryType find_query)\n"
"\n"
"[function_macro(name=\"decs\")]\n"
"class DecsEcsMacro : AstFunctionAnnotation\n"
"    def override apply ( var func:FunctionPtr; var group:ModuleGroup; args:Annot"
"ationArgumentList; var errors : das_string ) : bool\n"
"        let argPass = find_arg(\"stage\", args)\n"
"        if !(argPass is tString)\n"
"            errors := \"need to specify stage\"\n"
"            return false\n"
"        let passName = argPass as tString\n"
"        let passFuncName = \"decs`pass`{passName}\"\n"
"        var blk <- setup_call_list(passFuncName, func.at)\n"
"        if length(blk.list)==0\n"
"            var reg <- setup_call_list(\"register`decs`passes\", func.at, true)\n"
"            var regc <- new [[ExprCall() at=func.at, name:=\"decs::register_decs_"
"stage_call\"]]\n"
"            regc.arguments |> emplace_new <| new [[ExprConstString() at=func.at,"
" value:=passName]]\n"
"            regc.arguments |> emplace_new <| new [[ExprAddr() at=func.at, target"
":=passFuncName]]\n"
"            reg.list |> emplace(regc)\n"
"        blk.list |> emplace_new <| new [[ExprCall() at=func.at, name:=\"_::{func."
"name}\"]]\n"
"        var fblk <- new [[ExprBlock() at=func.body.at]]                 // new f"
"unction block\n"
"        var cqq <- make_call(func.at,\"query\")\n"
"        var cquery = cqq as ExprCallMacro\n"
"        var qblk <- new [[ExprBlock() at=func.body.at]]                 // insid"
"e the query block\n"
"        qblk.blockFlags |= ExprBlockFlags isClosure\n"
"        qblk.returnType <- new [[TypeDecl() baseType=Type tVoid, at=func.at]]\n"
"        var req, nreq : array<string>\n"
"        for arg in args\n"
"            if arg.basicType==Type tString\n"
"                if eq(arg.name,\"REQUIRE\")\n"
"                    req |> push(\"{arg.sValue}\")\n"
"                if eq(arg.name,\"REQUIRE_NOT\")\n"
"                    nreq |> push(\"{arg.sValue}\")\n"
"        if !req |> empty\n"
"            var decl <- new [[AnnotationDeclaration() ]]\n"
"            var ann = find_annotation(\"decs_boost\", \"REQUIRE\")\n"
"            unsafe\n"
"                decl.annotation := reinterpret<smart_ptr<Annotation>> ann\n"
"            for rq in req\n"
"                decl.arguments |> add_annotation_argument(rq, true)\n"
"            qblk.annotations |> emplace(decl)\n"
"        if !nreq |> empty\n"
"            var decl <- new [[AnnotationDeclaration() ]]\n"
"            var ann = find_annotation(\"decs_boost\", \"REQUIRE_NOT\")\n"
"            unsafe\n"
"                decl.annotation := reinterpret<smart_ptr<Annotation>> ann\n"
"            for rq in nreq\n"
"                decl.arguments |> add_annotation_argument(rq, true)\n"
"            qblk.annotations |> emplace(decl)\n"
"        var fnbody = func.body as ExprBlock\n"
"        for el in fnbody.list                                           // list "
"goes to inside query\n"
"            qblk.list |> emplace_new <| clone_expression(el)\n"
"        for ef in fnbody.finalList                                      // final"
"ly goes to new finally\n"
"            fblk.finalList |> emplace_new <| clone_expression(ef)\n"
"        for arg in func.arguments                                       // add f"
"unction arguments to query arguments\n"
"            qblk.arguments |> emplace_new <| new [[Variable() at=arg.at,\n"
"                name := arg.name,\n"
"                _type <- clone_type(arg._type),\n"
"                init <- clone_expression(arg.init)\n"
"            ]]\n"
"        func.arguments |> clear\n"
"        cquery.arguments |> emplace_new <| new [[ExprMakeBlock() _block <- qblk,"
" at=func.at]]\n"
"        fblk.list |> emplace(cqq)\n"
"        func.body := fblk\n"
"        return true\n"
