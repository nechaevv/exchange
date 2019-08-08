{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric  #-}
{-# LANGUAGE OverloadedStrings #-}
module Users where

import Data.UUID
import Control.Exception (bracket)
import Database.PostgreSQL.Simple
import Control.Monad (forM_)
import GHC.Generics (Generic)

data User = User {
  id :: UUID ,
  name :: String
} deriving (Generic, FromRow)

userList :: IO [User]
userList = bracket (connectPostgreSQL "postgresql://exchange:exchange@localhost/exchange") close $ \conn ->  
  query_ conn "select id, name from \"Users\""
