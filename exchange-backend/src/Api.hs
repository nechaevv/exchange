{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
module Api where

import Control.Monad.IO.Class
import Data.Aeson
import Servant
import Servant.API

import Users

instance ToJSON User

type HealthAPI = "health" :> Post '[PlainText] NoContent
type UsersAPI = "users" :> Get '[JSON] [User]

healthHandler :: Handler NoContent
healthHandler = return NoContent

usersHandler :: Handler [User]
usersHandler = liftIO userList

type API = "api" :> (HealthAPI :<|> UsersAPI)

server :: Server API
server = healthHandler :<|> usersHandler
