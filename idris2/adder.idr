
import Circuit
import Data.Vect
import GUI
import IndexType

not : (input : Encodable) -> Bit' input -> Bit' input
not input = primitive "not" bitNot input

fullAdder' : Bit -> Bit -> Bit -> (Bit, Bit)
fullAdder' B0 B0 B0 = (B0, B0)
fullAdder' B0 B0 B1 = (B1, B0)
fullAdder' B0 B1 B0 = (B1, B0)
fullAdder' B0 B1 B1 = (B0, B1)
fullAdder' B1 B0 B0 = (B1, B0)
fullAdder' B1 B0 B1 = (B0, B1)
fullAdder' B1 B1 B0 = (B0, B1)
fullAdder' B1 B1 B1 = (B1, B1)

fullAdder : (input : Encodable) -> (Bit' input) -> (Bit' input) -> (Bit' input) -> (Bit' input, Bit' input)
fullAdder input = primitive "fullAdder" fullAdder' input

data IntBits : Nat -> Encodable -> Type where
  MkInt : Vect n (Bit' input) -> IntBits n input

IntBitsEnc : Nat -> Encodable
IntBitsEnc n = NewEnc ("Int " ++ show n) $ EncVect n Bit

{n : Nat} -> EncodingValue (Bit' input) (IntBits n input) where
  builderEncodable = IntBitsEnc n
  constructEncodingValue (MkInt x) = NewEncoding $ constructEncodingValue x
  deconstructEncodingValue (NewEncoding x) = MkInt $ deconstructEncodingValue x

rippleAdder
  :  (input : Encodable)
  -> IntBits n input
  -> IntBits n input
  -> Bit' input
  -> (IntBits n input, Bit' input)
rippleAdder input (MkInt []) (MkInt []) c = (MkInt [], c)
rippleAdder input (MkInt (x :: xs)) (MkInt (y :: ys)) c =
  let (z, c') = fullAdder input x y c in
      let (MkInt zs, c'') = rippleAdder input (MkInt xs) (MkInt ys) c' in
          (MkInt (z :: zs), c'')

testPure : (n : Nat) -> PrimType (IntBitsEnc n && IntBitsEnc n && Bit && UnitEnc) -> PrimType (IntBitsEnc n && Bit)
testPure n = simulate (IntBitsEnc n && IntBitsEnc n && Bit && UnitEnc) $ rippleAdder {n}

test : (n : Nat) -> IO ()
test n = guiSimulate "Ripple Adder" (IntBitsEnc n && IntBitsEnc n && Bit && UnitEnc) (rippleAdder {n})

main : IO ()
main = do
  test 4

