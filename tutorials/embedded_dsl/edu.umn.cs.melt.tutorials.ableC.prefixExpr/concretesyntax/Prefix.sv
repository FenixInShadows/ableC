grammar edu:umn:cs:melt:tutorials:ableC:prefixExpr:concretesyntax;

imports edu:umn:cs:melt:ableC:concretesyntax;
imports edu:umn:cs:melt:ableC:concretesyntax:construction;
imports edu:umn:cs:melt:ableC:abstractsyntax;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;

imports silver:langutil only ast; 

imports edu:umn:cs:melt:tutorials:ableC:prefixExpr:abstractsyntax;

marking terminal PrefixExpr_t 'prefix' lexer classes {Ckeyword};

concrete production prefixExpr_c
top::AssignExpr_c ::= 'prefix' '(' pe::PrefixExpr_c ')'
{
  top.ast = prefixExpr(pe.ast, location=top.location);
}

nonterminal PrefixExpr_c with ast<PrefixExpr>, location;

concrete productions top::PrefixExpr_c
| '+' pe1::PrefixExpr_c pe2::PrefixExpr_c
  { top.ast = addPrefixExpr(pe1.ast, pe2.ast, location=top.location); }
| '-' pe1::PrefixExpr_c pe2::PrefixExpr_c
  { top.ast = subPrefixExpr(pe1.ast, pe2.ast, location=top.location); }
| '*' pe1::PrefixExpr_c pe2::PrefixExpr_c
  { top.ast = mulPrefixExpr(pe1.ast, pe2.ast, location=top.location); }
| '/' pe1::PrefixExpr_c pe2::PrefixExpr_c
  { top.ast = divPrefixExpr(pe1.ast, pe2.ast, location=top.location); }
| c::Constant_c
  { top.ast = exprPrefixExpr(c.ast, location=top.location); }
| id::Identifier_t
  { top.ast = exprPrefixExpr(declRefExpr(fromId(id), location=top.location), location=top.location); }
| '(' e::Expr_c  ')'
  { top.ast = exprPrefixExpr(e.ast, location=top.location); }