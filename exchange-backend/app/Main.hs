{-# LANGUAGE OverloadedStrings #-}
module Main where

import Network.Wai.Handler.Warp
import WaiApp
import DB

main :: IO ()
main = do
  pool <- initConnectionPool "postgresql://exchange:exchange@localhost/exchange"
               1 -- stripes
               10 -- unused connections are kept open for a minute
               10 -- max. 10 connections open per stripe  
  run 8080 $ app pool
