module Config where

import DB (DBPoolConfig)

data Config = Config {
  db :: DBPoolConfig
}