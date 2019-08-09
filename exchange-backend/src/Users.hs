{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric  #-}
{-# LANGUAGE OverloadedStrings #-}
module Users where

import Data.Pool
import Data.UUID
import Control.Exception (bracket)
import Database.PostgreSQL.Simple
import GHC.Generics (Generic)

import DB

data User = User {
  id :: UUID ,
  name :: String
} deriving (Generic, FromRow)

userList :: ConnectionPool -> IO [User]
userList pool = withResource pool $ \conn ->  
  query_ conn "select id, name from \"Users\""
