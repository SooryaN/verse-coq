Require Import String.
Require Import Strings.Ascii.
Require Import List.
Import ListNotations.


Definition Words := list string.

Definition Line : Set  := nat * Words.

Definition Doc  := list Line.

Definition line (ws : Words) : Line := (0,ws).
Definition lines := List.map line.

Definition indent n (l : Line)   : Line :=
  match l with
  | (m, ws) => (n + m, ws)
  end.

Definition nest  (n : nat): Doc -> Doc := List.map (indent n).


Fixpoint intercalate (punct : string) (ws : list string) : string :=
  match ws with
  | []        => ""
  | [x]       => x
  | (x :: xs) => (x ++ punct) ++ intercalate punct xs
  end.




Class DOC (doc : Set) := {
                  between  : string -> string -> doc -> doc;
                  sepBy    : string -> doc -> doc;
                  sepEndBy : string -> doc -> doc;
                  toString : doc -> string
                }.


Section Utils.
  Variable doc : Set.
  Variable cls : DOC doc.
  Definition comaSep := sepBy ",".
  Definition semiSep := sepBy ";".
  Definition semiSepEnd   := sepEndBy ";".
  Definition paren  := between "(" ")".
  Definition bracket := between "[" "]".
  Definition braces  := between "{" "}".
End Utils.

Arguments comaSep    [doc cls] _.
Arguments semiSep    [doc cls] _.
Arguments semiSepEnd [doc cls] _.
Arguments paren      [doc cls] _.
Arguments bracket    [doc cls] _.
Arguments braces     [doc cls] _.


(* Pretty print operations on lines. *)

Module PrettyWords.

   Fixpoint endBy (e : string) (ws : list string) : list string :=
    match ws with
    | []  => [e]
    | [x] => [(x ++ e)%string ]
    | (x::xs) => x :: endBy e xs
    end.

  Definition bet (b e : string) (ws : list string) : list string :=
    match ws with
    | []        => [(b ++ e)%string]
    | [x]       => [(b ++ x ++ e)%string]
    | (x :: xs) => (b ++ x)%string :: endBy e xs
    end.

  Fixpoint sep (s : string) (ws : list string) : list string :=
    match ws with
    | w1 :: wsp =>
      match wsp with
      | [] => ws
      | _  => (w1 ++ s)%string :: sep s wsp
      end
    | _               => ws
    end.

  Definition sepE (s : string) : list string  -> list string
    := List.map (fun x => (x ++ s)%string).

  Fixpoint unwords (ws : list string) : string :=
  match ws with
  | []  => ""
  | [x] => x
  | (x :: xs) => (x ++ " ") ++ unwords xs
  end.

End PrettyWords.


Instance words_pretty : DOC Words
  := { between  := PrettyWords.bet;
       sepBy    := PrettyWords.sep;
       sepEndBy := PrettyWords.sepE;
       toString := intercalate " "
     }.


Module PrettyDoc.

  Definition newline := String (ascii_of_nat 10) EmptyString.

  Fixpoint spaces (n : nat) : string :=
    match n with
    | 0    => ""
    | S m  => " " ++ spaces m
    end.

  Definition bet (b e : string) (doc : Doc) : Doc := [line [b]] ++ doc ++ [line [e]].


  Definition endLineBy s (ln : Line) : Line :=
    match ln with
    | (n,ws) => (n, PrettyWords.endBy s ws)
    end.
  Fixpoint sep (s : string) (doc : Doc) : Doc :=
    match doc with
    | ln :: docp =>
      match docp with
      | [] => doc
      | _  => endLineBy s ln :: sep s docp
               end
    | _  => doc
    end.

  Definition sepE (s : string) : Doc -> Doc
    := List.map (endLineBy s).


  Definition linetoStr (ln : Line) :=
    match ln with
    | (n,ws) => (spaces n ++ intercalate " " ws)%string
    end.


  Fixpoint unlines (doc : Doc) : string :=
    intercalate newline (List.map linetoStr doc).


End PrettyDoc.

Instance doc_pretty : DOC Doc
  := { between  := PrettyDoc.bet;
       sepBy    := PrettyDoc.sep;
       sepEndBy := PrettyDoc.sepE;
       toString := PrettyDoc.unlines
     }.