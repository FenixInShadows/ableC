grammar artifact;
-- Ideally, in the future, we won't have to write files like these.
-- This file exist only because we need to do the composition at compile time.

import edu:umn:cs:melt:ableC:concretesyntax as cst;
import edu:umn:cs:melt:ableC:drivers:parseAndPrint;

parser extendedParser :: cst:Root {
  edu:umn:cs:melt:ableC:concretesyntax;
  edu:umn:cs:melt:exts:ableC:tables;
  edu:umn:cs:melt:exts:ableC:regex;
  edu:umn:cs:melt:exts:ableC:gc;
  edu:umn:cs:melt:exts:ableC:adt;
  edu:umn:cs:melt:exts:ableC:matrix;
  edu:umn:cs:melt:exts:ableC:mex;
} 

function main
IOVal<Integer> ::= args::[String] io_in::IO
{
  return driver(args, io_in, extendedParser);
}

