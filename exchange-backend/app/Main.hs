{-# LANGUAGE OverloadedStrings #-}
module Main where

import Network.Wai.Handler.Warp
import WaiApp
import DBIO

main :: IO ()
main = do
  pool <- initConnectionPool "postgresql://exchange:exchange@localhost/exchange"
  run 8080 $ app pool
