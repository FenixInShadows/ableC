grammar edu:umn:cs:melt:exts:ableC:vector:abstractsyntax;

imports silver:langutil;
imports silver:langutil:pp with implode as ppImplode;

imports edu:umn:cs:melt:ableC:abstractsyntax hiding vectorType;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:ableC:abstractsyntax:env;
imports edu:umn:cs:melt:ableC:abstractsyntax:overload;
--imports edu:umn:cs:melt:ableC:abstractsyntax:debug;

imports edu:umn:cs:melt:exts:ableC:string;

global builtin::Location = builtinLoc("vector");

-- Vector initialization
abstract production initVector
top::Expr ::= sub::TypeName size::Expr
{
  forwards to
    stmtExpr(
      seqStmt(
        declStmt( 
          variableDecls(
            [], [],
            vectorTypeExpr(sub),
            consDeclarator( 
              declarator(
                name("_vec", location=builtin),
                baseTypeExpr(),
                [], 
                justInitializer(
                  exprInitializer(
                    directCallExpr(
                      name("GC_malloc", location=builtin),
                      consExpr(
                        unaryExprOrTypeTraitExpr(
                          sizeofOp(location=builtin),
                          typeNameExpr(
                            typeName(
                              injectGlobalDeclsTypeExpr(
                                vectorTypedefGlobalDecls(sub.typerep),
                                directTypeExpr(
                                  tagType(
                                    [],
                                    refIdTagType(
                                      structSEU(),
                                      "_vector_" ++ sub.typerep.mangledName ++ "_s",
                                      "edu:umn:cs:melt:exts:ableC:vector:_vector_" ++ sub.typerep.mangledName ++ "_s")))),
                              baseTypeExpr())),
                          location=builtin),
                        nilExpr()),
                      location=builtin)))) , 
              nilDeclarator()))),
        exprStmt(
          directCallExpr(
            name("_init_vector", location=builtin),
            consExpr(
              mkAddressOf(
                memberExpr(
                  declRefExpr(name("_vec", location=builtin), location=builtin),
                  true,
                  name("_info", location=builtin),
                  location=builtin),
                builtin),
              consExpr(
                explicitCastExpr(
                  typeName(
                    directTypeExpr(builtinType([], voidType())),
                    pointerTypeExpr([], pointerTypeExpr([], baseTypeExpr()))),
                  mkAddressOf(
                    memberExpr(
                      declRefExpr(name("_vec", location=builtin), location=builtin),
                      true,
                      name("_contents", location=builtin),
                      location=builtin),
                    builtin),
                  location=builtin),
                consExpr(
                  unaryExprOrTypeTraitExpr(
                    sizeofOp(location=builtin),
                    typeNameExpr(sub),
                    location=top.location),
                  consExpr(size, nilExpr())))),
          location=top.location))),
      declRefExpr(name("_vec", location=builtin), location=builtin),
      location=top.location);
}

abstract production constructVector
top::Expr ::= sub::TypeName e::Exprs
{
  e.argumentPosition = 0;
  forwards to 
    stmtExpr(
      seqStmt(
        mkDecl(
          "_vec",
          vectorType([], sub.typerep),
          initVector(sub, mkIntConst(e.count, builtin), location=builtin),
          builtin),
        e.vectorInitTrans),
      declRefExpr(name("_vec", location=builtin), location=top.location),
      location=top.location);
}

synthesized attribute vectorInitTrans::Stmt occurs on Exprs;

aspect production consExpr
top::Exprs ::= h::Expr t::Exprs
{
  top.vectorInitTrans =
    seqStmt(
      exprStmt(
        binaryOpExpr(
          arraySubscriptExpr(
            declRefExpr(name("_vec", location=builtin), location=builtin),
            mkIntConst(top.argumentPosition, builtin),
            location=builtin),
          assignOp(eqOp(location=builtin), location=builtin),
          h,
          location=builtin)),
      t.vectorInitTrans);
}

aspect production nilExpr
top::Exprs ::= 
{
  top.vectorInitTrans = nullStmt();
}

-- Vector append
abstract production appendVector
top::Expr ::= e1::Expr e2::Expr
{
  top.typerep = e1.typerep;
  forwards to
    directCallExpr(
      name("_append_vectors", location=builtin),
      consExpr(
        e1,
        consExpr(
          e2,
          nilExpr())),
      location=top.location);
}

abstract production appendAssignVector
top::Expr ::= e1::Expr e2::Expr
{
  top.typerep = e1.typerep;
  forwards to
    directCallExpr(
      name("_append_update_vector", location=builtin),
      consExpr(
        e1,
        consExpr(
          e2,
          nilExpr())),
      location=top.location);
}

abstract production eqVector
top::Expr ::= e1::Expr e2::Expr
{
  local subType1::Type = 
    case e1.typerep of
      vectorType(_, t) -> t
    | _ -> error("eqVector on non-vector")
    end;

  local subType2::Type = 
    case e1.typerep of
      vectorType(_, t) -> t
    | _ -> error("eqVector on non-vector")
    end;

  local param1Name::Name = name("elem1", location=builtin);
  local param2Name::Name = name("elem2", location=builtin);
  local fnName::Name = name("eq_fn", location=builtin);

  local fnDecl::FunctionDecl =
    functionDecl(
      [],
      [],
      directTypeExpr(builtinType([], boolType())),
      functionTypeExprWithArgs(
        baseTypeExpr(),
        consParameters(
          parameterDecl(
            [],
            directTypeExpr(builtinType([], voidType())),
            pointerTypeExpr([], baseTypeExpr()),
            justName(param1Name),
            []),
          consParameters(
            parameterDecl(
              [],
              directTypeExpr(builtinType([], voidType())),
              pointerTypeExpr([], baseTypeExpr()),
              justName(param2Name),
              []),
            nilParameters())),
        false),
      fnName,
      [],
      nilDecl(),
      returnStmt(
        justExpr(
          binaryOpExpr(
            unaryOpExpr(
              dereferenceOp(location=builtin),
              explicitCastExpr(
                typeName(
                  directTypeExpr(subType1),
                  pointerTypeExpr([], baseTypeExpr())),
                declRefExpr(
                  param1Name,
                  location=builtin),
                location=builtin),
              location=builtin),
            compareOp(equalsOp(location=builtin), location=builtin),
            unaryOpExpr(
              dereferenceOp(location=builtin),
              explicitCastExpr(
                typeName(
                  directTypeExpr(subType2),
                  pointerTypeExpr([], baseTypeExpr())),
                declRefExpr(
                  param1Name,
                  location=builtin),
                location=builtin),
              location=builtin),
            location=builtin))));
  
  forwards to
    stmtExpr(
      declStmt(functionDeclaration(fnDecl)),
      directCallExpr(
        name("_equal_vectors", location=builtin),
        consExpr(
          e1,
          consExpr(
            e2,
            consExpr(
              declRefExpr(
                fnName,
                location=builtin),
            nilExpr()))),
        location=top.location),
      location=top.location);
}

abstract production subscriptVector
top::Expr ::= e1::Expr e2::Expr
{
  forwards to
    unaryOpExpr(
      dereferenceOp(location=builtin),
        explicitCastExpr(
          case e1.typerep of
            vectorType(_, s) -> typeName(directTypeExpr(s), pointerTypeExpr([], baseTypeExpr()))
          | _ -> error("subscriptVector where lhs is non-vector")
          end,
          directCallExpr(
            name("_index_vector", location=builtin),
            consExpr(e1, consExpr(e2, nilExpr())),
            location=top.location),
          location=top.location),
      location=top.location);
}

abstract production subscriptAssignVector
top::Expr ::= lhs::Expr index::Expr op::AssignOp rhs::Expr
{
  forwards to
    case op of
      eqOp() -> 
        directCallExpr(
          name("_update_index_vector", location=builtin),
          consExpr(
            lhs,
            consExpr(
              index,
              consExpr(
                stmtExpr(
                  basicVarDeclStmt(rhs.typerep, name("_item", location=builtin), rhs),
                  unaryOpExpr(
                    addressOfOp(location=builtin),
                    declRefExpr(
                      name("_item", location=builtin),
                      location=builtin),
                    location=builtin),
                  location=builtin),
                consExpr(
                  unaryExprOrTypeTraitExpr(
                    sizeofOp(location=builtin),
                    typeNameExpr(typeName(directTypeExpr(rhs.typerep), baseTypeExpr())),
                    location=builtin),
                  nilExpr())))),
          location=top.location)
    | _ ->
        stmtExpr(
          exprStmt(
            directCallExpr(
              name("_check_index_vector", location=builtin),
              consExpr(lhs, consExpr(index, nilExpr())),
              location=top.location)),
            binaryOpExpr(
              unaryOpExpr(
                dereferenceOp(location=builtin),
                explicitCastExpr(
                  case lhs.typerep of
                    vectorType(_, s) -> typeName(directTypeExpr(s), pointerTypeExpr([], baseTypeExpr()))
                  | _ -> error("subscriptAssignVector where lhs is non-vector")
                  end,
                  arraySubscriptExpr(
                    memberExpr(lhs, true, name("contents", location=builtin), location=builtin),
                    index,
                    location=builtin),
                  location=builtin),
                location=builtin),
              assignOp(op, location=builtin),
              rhs,
              location=builtin),
          location=top.location)
    end;
}

abstract production showVector
top::Expr ::= e::Expr
{
  local subType::Type = 
    case e.typerep of
      vectorType(_, t) -> t
    | _ -> error("showVector on non-vector")
    end;

  local paramName::Name = name("elem", location=builtin);
  local fnName::Name = name("to_string_fn", location=builtin);

  local fnDecl::FunctionDecl =
    functionDecl(
      [],
      [],
      stringTypeExpr(),
      functionTypeExprWithArgs(
        baseTypeExpr(),
        consParameters(
          parameterDecl(
            [],
            directTypeExpr(builtinType([], voidType())),
            pointerTypeExpr([], baseTypeExpr()),
            justName(paramName),
            []),
          nilParameters()),
        false),
      fnName,
      [],
      nilDecl(),
      returnStmt(
        justExpr(
          showExpr(
            unaryOpExpr(
              dereferenceOp(location=builtin),
              explicitCastExpr(
                typeName(
                  directTypeExpr(subType),
                  pointerTypeExpr([], baseTypeExpr())),
                declRefExpr(
                  paramName,
                  location=builtin),
                location=builtin),
              location=builtin),
            location=builtin))));
  
  forwards to
    stmtExpr(
      declStmt(functionDeclaration(fnDecl)),
      directCallExpr(
        name("_showVector", location=builtin),
        consExpr(
          e,
          consExpr(
            declRefExpr(
              fnName,
              location=builtin),
            nilExpr())),
        location=top.location),
      location=top.location);
}