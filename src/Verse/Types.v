Require Import String.
Require Import Verse.Types.Internal.
Require Import Verse.Error.
Require Import Nat.

(** * Types in verse.

There are two kinds of types supported by verse [direct] and
[memory]. A value of a direct type can potentially be stored in one of
the machine registers. The supported direct types include the word
types [Word8], [Word16] , [Word32] and [Word64] and the vector types
[Vector128 w] and [Vector256 w] where [w] is any of the above word
types.  Verse supports arrays of these direct types but arrays are
memory types.


A user is only expected to use the types exposed from this
module. There is more to types and all its gory details are exposed
from the module [Verse.Types.Internal].

*)

(** Standard word types/scalars *)
Definition Byte   := word 0.
Definition Word8  := word 0.
Definition Word16 := word 1.
Definition Word32 := word 2.
Definition Word64 := word 3.
Definition Array  := array.

(* begin hide *)
Inductive BadVectorType : Prop := BadVectorTypeError.
Definition vector {k} m (t : type k) : type direct + {BadVectorType} :=
  match t with
  | word n => match compare n m with
              | LT => {- multiword (m - n) n -}
             (* | _  => error BadVectorTypeError *)
              end
  | _ => error BadVectorTypeError
  end.
(* end hide *)

Definition Vector128 (t : type direct) := recover (vector 4 t).
Definition Vector256 (t : type direct) := recover (vector 4 t).

Definition constant {k}(ty : type k):= typeDenote ty.

(* begin hide *)
Require Import PrettyPrint.


Definition constant_doc k (ty : type k)  : typeDenote ty -> Doc.
  refine( match ty with
          | word _         => fun w => text "0x" <> doc w
          | multiword _ _  => fun w => doc w
          | array _ _ _    => fun w => text ""
          end
        ); repeat simpl; apply vector_pretty_print.
Defined.

Global Instance constant_pretty k  (ty : type k) : PrettyPrint (constant ty)
  := { doc := constant_doc k ty }.
(* end hide *)