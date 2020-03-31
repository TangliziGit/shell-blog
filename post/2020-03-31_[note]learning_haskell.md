# Learning Haskell

## Chp. 3

### data

```haskell
data BookRecord = Book Int String
                | Books [(Int, String)]
                deriving (Show)
```

### type

```haskell
type newInt = Int
```

### enum

```haskell
data DnaElem = A | T | C | G
            deriving (Eq, Show)
```

### record

```haskell
data Customer = Customer {
    customerID      :: Int,
    customerName    :: String,
    customerAddress :: [String]
  } deriving (Show)

customer  = Customer 1 "peter" ["xxx", "yyy"]
customer2 = Customer {
    customerID      = 2
    customerName    = "tom",
    customerAddress = ["xxx"]
  }
```

### case

```haskell
fromMaybe wrapped def =
    case wrapped of
        Nothing     -> def
        Just value  -> value
```
