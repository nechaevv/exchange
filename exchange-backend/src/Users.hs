{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric  #-}
{-# LANGUAGE OverloadedStrings #-}

module Users where

import Data.Pool
import Data.UUID
import Control.Exception (bracket)
import Database.PostgreSQL.Simple
import GHC.Generics (Generic)
import Control.Monad

import DB

data User = User {
  id :: UUID ,
  name :: String
} deriving (Generic, FromRow)

userList :: DBIO [User]
userList = dbio $ \conn -> query_ conn "select id, name from \"Users\""
