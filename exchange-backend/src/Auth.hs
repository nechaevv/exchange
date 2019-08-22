{-# LANGUAGE OverloadedStrings #-}
module Auth where

import DB
import Data.UUID (UUID)
import Data.Time.Clock

newtype AuthContext = AuthContext { userId :: UUID }

data AuthConfig = AuthConfig {
  maxAuthTokenTime :: NominalDiffTime
}

findActiveAuthContext :: AuthConfig -> UUID -> DBIO (Maybe AuthContext)
findActiveAuthContext config token = foldWith "select \"userId\" from \"AuthTokens\" where \"token\"=? and issueTime > now() - ?"
  [token, maxAuthTokenTime config] Nothing (const $ return <$> (Just . AuthContext))
  
  