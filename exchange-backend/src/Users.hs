{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric  #-}
{-# LANGUAGE OverloadedStrings #-}
module Users where

import GHC.Generics (Generic)
import Data.UUID (UUID)
import Database.PostgreSQL.Simple
import DB

type UserId = UUID

data User = User {
  userId :: UserId ,
  name :: String
} deriving (Generic, FromRow)

userList :: DBIO [User]
userList = queryList "select id, name from \"Users\""

maybeHead :: [a] -> Maybe a
maybeHead (x:_) = Just x
maybeHead [] = Nothing

userWithName :: String -> DBIO (Maybe User)
userWithName name = maybeHead <$> queryUsers
  where queryUsers :: DBIO [User]
        queryUsers = queryListParam "select id, name from \"Users\" where name=?" [name]