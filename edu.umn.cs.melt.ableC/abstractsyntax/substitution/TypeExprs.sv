grammar edu:umn:cs:melt:ableC:abstractsyntax:substitution;

-- TODO: TypeExprs with qualifiers lists should get .sustituted mapped over them - propagate doesn't do this by default

aspect production typeName
top::TypeName ::= bty::BaseTypeExpr  mty::TypeModifierExpr
{
  propagate substituted;
}

aspect production errorTypeExpr
top::BaseTypeExpr ::= msg::[Message]
{
  propagate substituted;
}
aspect production warnTypeExpr
top::BaseTypeExpr ::= msg::[Message]  ty::BaseTypeExpr
{
  propagate substituted;
}
aspect production typeModifierTypeExpr
top::BaseTypeExpr ::= bty::BaseTypeExpr  mty::TypeModifierExpr
{
  propagate substituted;
}
aspect production builtinTypeExpr
top::BaseTypeExpr ::= q::Qualifiers  result::BuiltinType
{
  propagate substituted;
}
aspect production tagReferenceTypeExpr
top::BaseTypeExpr ::= q::Qualifiers  kwd::StructOrEnumOrUnion  name::Name
{
  propagate substituted;
}
aspect production structTypeExpr
top::BaseTypeExpr ::= q::Qualifiers  def::StructDecl
{
  propagate substituted;
}
aspect production unionTypeExpr
top::BaseTypeExpr ::= q::Qualifiers  def::UnionDecl
{
  propagate substituted;
}
aspect production enumTypeExpr
top::BaseTypeExpr ::= q::Qualifiers  def::EnumDecl
{
  propagate substituted;
}
aspect production typedefTypeExpr
top::BaseTypeExpr ::= q::Qualifiers  name::Name
{
  local substitutions::Substitutions = top.substitutions;
  substitutions.nameIn = name.name;
  top.substituted =
    case substitutions.typedefSub of
      just(sub) -> sub
    | nothing() -> typedefTypeExpr(q, name.substituted)
    end;
}
aspect production atomicTypeExpr
top::BaseTypeExpr ::= q::Qualifiers  wrapped::TypeName
{
  propagate substituted;
}
aspect production vaListTypeExpr
top::BaseTypeExpr ::=
{
  propagate substituted;
}
aspect production typeofTypeExpr
top::BaseTypeExpr ::= q::Qualifiers  e::ExprOrTypeName
{
  propagate substituted;
}

aspect production baseTypeExpr
top::TypeModifierExpr ::=
{
  propagate substituted;
}
aspect production pointerTypeExpr
top::TypeModifierExpr ::= q::Qualifiers  target::TypeModifierExpr
{
  propagate substituted;
}
aspect production arrayTypeExprWithExpr
top::TypeModifierExpr ::= element::TypeModifierExpr  indexQualifiers::Qualifiers  sizeModifier::ArraySizeModifier  size::Expr
{
  propagate substituted;
}
aspect production arrayTypeExprWithoutExpr
top::TypeModifierExpr ::= element::TypeModifierExpr  indexQualifiers::Qualifiers  sizeModifier::ArraySizeModifier
{
  propagate substituted;
}

aspect production functionTypeExprWithArgs
top::TypeModifierExpr ::= result::TypeModifierExpr  args::Parameters  variadic::Boolean
{
  propagate substituted;
}
aspect production functionTypeExprWithoutArgs
top::TypeModifierExpr ::= result::TypeModifierExpr  ids::[Name]
{
  top.substituted =
    functionTypeExprWithoutArgs(
      result.substituted,
      map(subName(unfoldSubstitution(top.substitutions), _), ids));
}
aspect production parenTypeExpr
top::TypeModifierExpr ::= wrapped::TypeModifierExpr
{
  propagate substituted;
}

aspect production consTypeName
top::TypeNames ::= h::TypeName t::TypeNames
{
  propagate substituted;
}
aspect production nilTypeName
top::TypeNames ::= 
{
  propagate substituted;
}

aspect production hackUnusedType
top::BaseTypeExpr ::=
{
  -- substituted doesn't depend on env
  top.substituted = error("hack");
}

