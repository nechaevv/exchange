module Main where

import Network.Wai.Handler.Warp
import WaiApp

main :: IO ()
main = run 8080 app
