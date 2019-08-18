{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric  #-}
{-# LANGUAGE OverloadedStrings #-}
module Users where

import GHC.Generics (Generic)
import Data.UUID (UUID)
import DB

type UserId = UUID

data User = User {
  userId :: UserId ,
  name :: String
} deriving (Generic, FromRow)

userList :: DBIO [User]
userList = query "select id, name from \"Users\""

userWithName :: String -> DBIO (Maybe User)
userWithName name = foldWith "select id, name from \"Users\" where name=?" 
  [name] Nothing (const $ return <$> Just)