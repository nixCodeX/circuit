module EqOrdUtils

import public Decidable.Equality
import Utils

%default total

export
[EqVoid] Eq Void where
  _ == _ impossible

export
[OrdVoid] Ord Void using EqVoid where
  compare _ _ impossible

export
EqEither : (Eq a, Eq b) => Eq (Either a b)
EqEither = autoDer

export
[OrdEither] (Ord a, Ord b) => Ord (Either a b) where
  compare (Left x)  (Left y)  = compare x y
  compare (Right x) (Right y) = compare x y
  compare (Left x)  (Right y) = LT
  compare (Right x) (Left y)  = GT

export
EqPair : (Eq a, Eq b) => Eq (a, b)
EqPair = autoDer

export
OrdPair : (Ord a, Ord b) => Ord (a, b)
OrdPair = autoDer

export
[EqDPair] ((x : a) -> Eq (f x), DecEq a) => Eq (DPair a f) where
  (==) @{eqF} (MkDPair x1 y1) (MkDPair x2 y2) with (decEq x1 x2)
    (==) @{eqF} (MkDPair x y1) (MkDPair x y2) | Yes Refl = (==) @{eqF x} y1 y2
    (==) (MkDPair _ _) (MkDPair _ _) | No _ = False

EqFromOrd : Ord a -> Eq a
EqFromOrd _ = autoDer

[EqDPairFromOrd] ((x : a) -> Ord (f x), DecEq a) => Eq (DPair a f) where
  (==) @{ordF} (MkDPair x1 y1) (MkDPair x2 y2) with (decEq x1 x2)
    (==) @{ordF} (MkDPair x y1) (MkDPair x y2) | Yes Refl = (==) @{EqFromOrd $ ordF x} y1 y2
    (==) (MkDPair _ _) (MkDPair _ _) | No _ = False

export
[OrdDPair] (ordF : (x : a) -> Ord (f x), DecEq a, Ord a) => Ord (DPair a f) using EqDPairFromOrd where
  compare @{ordF} (MkDPair x1 y1) (MkDPair x2 y2) with (decEq x1 x2)
    compare @{ordF} (MkDPair x y1) (MkDPair x y2) | Yes Refl = compare @{ordF x} y1 y2
    compare (MkDPair x1 _) (MkDPair x2 _) | No _ = compare x1 x2

