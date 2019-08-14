{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric  #-}
{-# LANGUAGE OverloadedStrings #-}
module Users where

import GHC.Generics (Generic)
import Data.UUID
import Database.PostgreSQL.Simple

import DBIO

type UserId = UUID

data User = User {
  userId :: UserId ,
  name :: String
} deriving (Generic, FromRow)

userList :: DBIO [User]
userList = return queryList "select id, name from \"Users\""

maybeHead :: [a] -> Maybe a
maybeHead (x:_) = Just x
maybeHead [] = Nothing

userWithName :: String -> DBIO (Maybe User)
userWithName name = return $ maybeHead <$> queryUsers
  where queryUsers :: DBOp [User]
        queryUsers = queryListParam "select id, name from \"Users\" where name=?" [name]