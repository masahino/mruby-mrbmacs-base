{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wall #-}

module Main (main, Greeter(..)) where

-- Line comment.
{- Block comment with nested {- comment -}. -}

class Named a where
  displayName :: a -> String

data Greeter = Greeter
  { name  :: String
  , count :: Int
  } deriving (Eq, Show)

instance Named Greeter where
  displayName value = name value ++ " #" ++ show (count value)

greet :: Greeter -> String
greet value
  | count value > 0 = "hello " <> displayName value
  | otherwise       = "empty"

main :: IO ()
main = do
  let preview = Greeter "mrbmacs" 17
  putStrLn (greet preview)
