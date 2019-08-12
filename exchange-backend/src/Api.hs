{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
module Api where

import Control.Monad.IO.Class
import Data.Aeson
import Servant
import Servant.API

import Users
import DB

instance ToJSON User

type HealthAPI = "health" :> Post '[PlainText] NoContent
type UsersAPI = "users" :> Get '[JSON] [User]

healthHandler :: Handler NoContent
healthHandler = return NoContent

usersHandler :: ConnectionPool -> Handler [User]
usersHandler pool = liftDBIO pool userList

type API = "api" :> (HealthAPI :<|> UsersAPI)

server :: ConnectionPool -> Server API
server pool = healthHandler :<|> usersHandler pool
