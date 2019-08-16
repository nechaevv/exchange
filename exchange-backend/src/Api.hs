{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
module Api where

import Control.Monad.IO.Class
import Data.Aeson
import Servant
import Servant.API

import qualified Users
import Users (User, userList, userWithName)
import Orders
import DB

instance ToJSON User

type HealthAPI = "health" :> Post '[PlainText] NoContent
type UsersAPI = "users" :> Get '[JSON] [User]
type OrdersAPI = "orders" :> Capture "userName" String :> Get '[JSON] [UserOrder]

healthHandler :: Handler NoContent
healthHandler = return NoContent

usersHandler :: ConnectionPool -> Handler [User]
usersHandler pool = liftDBIO pool userList

ordersHandler :: ConnectionPool -> String -> Handler [UserOrder]
ordersHandler pool userName = liftDBIO pool $ do
  user <- userWithName userName
  let uid = Users.userId <$> user
  ordersById uid
    where ordersById (Just id) = userOrdersList id
          ordersById Nothing = return []

type API = "api" :> (HealthAPI :<|> UsersAPI)

server :: ConnectionPool -> Server API
server pool = healthHandler :<|> usersHandler pool
