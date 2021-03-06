--		Copyright 1996-2000 by Daniel R. Grayson

-- strings

separateRegexp = method()
separateRegexp(String,String) := (re,s) -> separateRegexp(re,0,s)
separateRegexp(String,ZZ,String) := (re,n,s) -> (
     offset := 0;
     while offset <= #s
     list (
	  m := regex(re,offset,s);
	  if m#?n
	  then first (substring(s,offset,m#n#0-offset), offset = m#n#0+m#n#1)
	  else first (substring(s,offset), offset = #s + 1)))

selectRegexp = method()
selectRegexp(String,String) := (re,s) -> selectRegexp(re,0,s)
selectRegexp(String,ZZ,String) := (re,n,s) -> (
     m := regex(re,s);
     if m#?n then substring(m#n#0,m#n#1,s) else error "regular expression didn't match")

-- nets

Net#{Standard,AfterPrint} = identity

toString MutableHashTable := s -> (
     concatenate ( toString class s, if parent s =!= Nothing then (" of ", toString parent s), "{...", toString(#s), "...}"))
toString Type := X -> (
     if hasAnAttribute X then (
	  if hasAttribute(X,PrintNames) then return getAttribute(X,PrintNames);
	  if hasAttribute(X,ReverseDictionary) then return toString getAttribute(X,ReverseDictionary);
	  );
     concatenate(toString class X, " of ", toString parent X, "{...", toString(#X), "...}"))
toString HashTable := s -> (
     concatenate (
	  "new ", toString class s,
	  if parent s =!= Nothing then (" of ", toString parent s),
	  " from {",
	  if # s > 0
	  then demark(", ", apply(pairs s, (k,v) -> toString k | " => " | toString v) )
	  else "",
	  "}"))
toString MutableList := s -> concatenate(toString class s,"{...",toString(#s),"...}")
toStringn := i -> if i === null then "" else toString i
toString BasicList := s -> concatenate(
     if class s =!= List then toString class s,
     "{", between(", ",apply(toList s,toStringn)), "}"
     )
toString Array := s -> concatenate ( "[", between(", ",toStringn \ toList s), "]" )
toString Sequence := s -> (
     if # s === 1 then concatenate("1 : (",toString s#0,")")
     else concatenate("(",between(",",toStringn \ s),")")
     )
net Command := toString Command := toExternalString Command := f -> (
     if hasAttribute(f,ReverseDictionary) then return toString getAttribute(f,ReverseDictionary) else "{*Command*}"
     )

toExternalString Function := f -> (
     if hasAttribute(f,ReverseDictionary) then return toString getAttribute(f,ReverseDictionary);
     t := locate f;
     if t === null then error "can't convert anonymous function to external string"
     else error("can't convert anonymous function (",t#0, ":", toString t#1| ":", toString t#2, "-", toString t#3| ":", toString t#4,") to external string")
     )

net Function := toString Function := f -> (
     if hasAttribute(f,ReverseDictionary) then return toString getAttribute(f,ReverseDictionary);
     t := locate f;
     if t === null then "{*Function*}" 
     else concatenate("{*Function[", t#0, ":", toString t#1| ":", toString (t#2+1), "-", toString t#3| ":", toString (t#4+1), "]*}")
     )

net FunctionBody := toString FunctionBody := f -> (
     t := locate f;
     if t === null then "{*FunctionBody*}" 
     else concatenate("{*FunctionBody[", t#0, ":", toString t#1| ":", toString (t#2+1), "-", toString t#3| ":", toString (t#4+1), "]*}")
     )

toExternalString Manipulator := f -> (
     if hasAttribute(f,ReverseDictionary) then return toString getAttribute(f,ReverseDictionary) else concatenate("new Manipulator from ",toExternalString toList f)
     )
toString Manipulator := f -> (
     if hasAttribute(f,ReverseDictionary) then return toString getAttribute(f,ReverseDictionary) else concatenate("new Manipulator from ",toString toList f)
     )
-----------------------------------------------------------------------------
toExternalString String := format

toString Net := x -> demark("\n",unstack x)
toExternalString Net := x -> concatenate(format toString x, "^", toString(height x - 1))

toExternalString MutableHashTable := s -> (
     if hasAttribute(s,ReverseDictionary) then return toString getAttribute(s,ReverseDictionary);
     error "anonymous mutable hash table cannot be converted to external string";
     )
toExternalString Type := s -> (
     if hasAttribute(s,ReverseDictionary) then return toString getAttribute(s,ReverseDictionary);
     error "anonymous type cannot be converted to external string";
     )
toExternalString HashTable := s -> (
     concatenate (
	  "new ", toExternalString class s,
	  if parent s =!= Nothing then (" of ", toExternalString parent s),
	  " from {",
	  if # s > 0
	  then demark(", ", apply(pairs s, (k,v) -> toExternalString k | " => " | toExternalString v) )
	  else "",
	  "}"))
toExternalString MutableList := s -> (
     error "anonymous mutable list cannot be converted to external string";
     -- concatenate("new ",toExternalString class s, " from {...", toString(#s), "...}" )
     )
mid := s -> (
     if #s === 1 then toExternalString s#0
     else between(",",apply(toSequence s,x -> if x === null then "" else toExternalString x))
     )
toExternalString BasicList := s -> concatenate(
     (if class s === List then "{" else ("new ", toString class s, " from {")), mid s, "}" )
toExternalString Array := s -> concatenate("[",mid s,"]")
toExternalString Sequence := s -> (
     if # s === 1 then concatenate("1:(",toExternalString s#0,")")
     else concatenate("(",mid s,")"))
-----------------------------------------------------------------------------
describe = method()
describe Thing := net

net Manipulator := toString
net Thing := toString
-----------------------------------------------------------------------------
net Symbol := toString
File << Symbol := File => (o,s) -> o << toString s		    -- provisional
File << Thing  := File => (o,s) -> o << toString s		    -- provisional
-----------------------------------------------------------------------------
net Option := z -> net z#0 | " => " | net z#1

Net == String := (n,s) -> (				    -- should install in engine
     height n === 1 and depth n === 0 and width n === length s and n#0 === s
     )
String == Net := (s,n) -> n == s

net String := x -> stack separate x			    -- was horizontalJoin
net RR := net Boolean := net File := net ZZ := net Database := toString
net000 := horizontalJoin ()
net Nothing := null -> "null" -- was net000

Net | Net := Net => horizontalJoin
Net || Net := Net => stack
String ^ ZZ := Net => (s,i) -> raise(horizontalJoin s,i)
Net ^ ZZ := Net => raise
String ^ Sequence := Net => (s,p) -> (
     (height,depth) -> (
	  tot := height + depth;
	  if tot <= 0 then (stack())^height
	  else (stack apply(tot,i->s))^(height-1)
	  )
     ) p

net Net := identity

comma := ", "

netn = i -> if i === null then net000 else net i

net Sequence := x -> horizontalJoin deepSplice (
     if #x === 0 then "()"
     else if #x === 1 then ("1 : (", net x#0, ")")
     else ("(", toSequence between(comma,apply(x,netn)), ")"))

net List := x -> horizontalJoin deepSplice (
     "{",
     toSequence between(comma,apply(x,netn)),
     "}")

VerticalList = new SelfInitializingType of List
VerticalList.synonym = "vertical list"
net VerticalList := x -> if #x === 0 then "{}" else (
     n := stack apply(x,net);
     h := height n;
     d := depth n;
     horizontalJoin("{"^(h,d), n, "}"^(h,d)))
net Array := x -> horizontalJoin deepSplice (
     "[",
     toSequence between(comma,apply(x,netn)),
     "]")
net BasicList := x -> horizontalJoin deepSplice (
      net class x, 
      "{",
      toSequence between(comma,apply(toList x,netn)),
      "}")
net MutableList := x -> (
     if #x > 0 
     then horizontalJoin ( net class x, "{...", toString(#x), "...}")
     else horizontalJoin ( net class x, "{}")
     )
net HashTable := x -> (
     horizontalJoin flatten ( 
     	  net class x,
	  "{", 
	  -- the first line prints the parts vertically, second: horizontally
 	  stack (horizontalJoin \ sort apply(pairs x,(k,v) -> (net k, " => ", net v))),
	  -- between(", ", apply(pairs x,(k,v) -> net k | "=>" | net v)), 
	  "}" 
     	  ))

net MutableHashTable := x -> (
     if hasAnAttribute x then (
	  if hasAttribute(x,PrintNet) then return getAttribute(x,PrintNet);
	  if hasAttribute(x,PrintNames) then return net getAttribute(x,PrintNames);
	  if hasAttribute(x,ReverseDictionary) then return toString getAttribute(x,ReverseDictionary);
	  );
     horizontalJoin ( net class x, if #x > 0 then ("{...", toString(#x), "...}") else "{}" ))
net Type := X -> (
     if hasAnAttribute X then (
	  if hasAttribute(X,PrintNet) then return getAttribute(X,PrintNet);
	  if hasAttribute(X,PrintNames) then return net getAttribute(X,PrintNames);
	  if hasAttribute(X,ReverseDictionary) then return toString getAttribute(X,ReverseDictionary);
	  );
     horizontalJoin ( net class X, if #X > 0 then ("{...", toString(#X), "...}") else "{}" ))

texMath Net := n -> concatenate (
     ///{\arraycolsep=0pt
\begin{matrix}
///,
     between(///\\
///, unstack n / characters / (i -> apply(i,c -> (///\tt ///,c))) / (s -> between("&",s))),
     ///
\end{matrix}}
///)

-----------------------------------------------------------------------------

netList = method(Options => {
	  Boxes => true,
	  BaseRow => 0,
	  HorizontalSpace => 0,
	  VerticalSpace => 0,
	  Alignment => Left				    -- Center, Left, or Right or list of those
	  })

maxN := x -> if #x === 0 then 0 else max x

alignmentFunctions := new HashTable from {
     Left => (wid,n) -> n | horizontalJoin(wid - width n : " "^(- depth n)),
     Right => (wid,n) -> horizontalJoin(wid - width n : " "^(- depth n)) | n,
     Center => centerString
     }

netList VisibleList := o -> (x) -> (
     x = apply(x, row -> if instance(row,List) then row else {row});
     (br,hs,vs,bx,algn) := (o.BaseRow,o.HorizontalSpace,o.VerticalSpace,o.Boxes,splice o.Alignment);
     if #x == 0 then return if bx then stack(2 : "++") else stack();
     if br < 0
     or br >= #x+1					    -- this allows the base row to be absent
     then error "netList: base row out of bounds";
     x = apply(x, row->apply(row, netn));
     n := maxN(length \ x);
     if n == 0 then return if bx then stack(2 : "++") else stack();
     x = apply(x, row -> if #row == n then row else join(row, n-#row : stack()));
     colwids := max \ transpose applyTable(x,width);
     if not instance(algn,List) then algn = n : algn ;
     algn = apply(algn, key -> alignmentFunctions#key);
     x = apply(x, row -> apply(n, i -> algn#i(colwids#i,row#i)));
     if bx then (
     	  if hs > 0 then (
	       colwids = apply(colwids, wid -> wid+2*hs);
	       hsep := spaces hs;                                 -- "spaces" puts characters on the baseline, what about an empty net of width hs?
	       x = apply(x, row -> apply(row, i -> horizontalJoin(hsep,i,hsep)));
	       );
	  x = apply(x, row -> mingle(#row+1:"|"^(max(height\row)+vs,max(depth\row)+vs), row));
	  )
     else if hs > 0 then (
	  hsep = spaces hs;                                 -- "spaces" puts characters on the baseline, what about an empty net of width hs?
	  x = apply(x,i -> between(hsep,i));
	  );
     x = apply(x, horizontalJoin);
     if bx then (
	  hbar := concatenate mingle(#colwids+1:"+",apply(colwids,wid -> wid:"-"));
	  x = mingle(#x+1:hbar,x);
	  br = 2*br + 1;
	  )
     else if vs > 0 then (
     	  x = between(stack(vs : ""),x);
	  br = 2*br;
	  );
     (stack x)^(
	  sum(0 .. br-1, i -> depth x#i)
	  +
	  sum(1 .. br, i -> try height x#i else 1)	    -- this allows the base row to be absent
	  ))

-- Local Variables:
-- compile-command: "make -C $M2BUILDDIR/Macaulay2/m2 "
-- End:
