{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
module Api where

import Control.Monad.IO.Class
import Data.Aeson
import Servant
import Servant.API

import DB

import qualified Users
import qualified Orders
import qualified Tickers

instance ToJSON Users.User
instance ToJSON Tickers.Ticker
instance ToJSON Orders.UserOrder

type HealthAPI = "health" :> Post '[PlainText] NoContent
type UsersAPI = "users" :> Get '[JSON] [Users.User]
type TickersAPI = "tickers" :> Get '[JSON] [Tickers.Ticker]
type OrdersAPI = "orders" :> Capture "userName" String :> Get '[JSON] [Orders.UserOrder]

healthHandler :: Handler NoContent
healthHandler = return NoContent

usersHandler :: ConnectionPool -> Handler [Users.User]
usersHandler pool = liftDBIO pool Users.userList

tickersHandler :: ConnectionPool -> Handler [Tickers.Ticker]
tickersHandler pool = liftDBIO pool Tickers.tickerList

ordersHandler :: ConnectionPool -> String -> Handler [Orders.UserOrder]
ordersHandler pool userName = liftDBIO pool $ do
  user <- Users.userWithName userName
  let uid = Users.userId <$> user
  ordersById uid
    where ordersById (Just id) = Orders.userOrdersList id
          ordersById Nothing = return []

type API = "api" :> (HealthAPI :<|> UsersAPI :<|> TickersAPI :<|> OrdersAPI)

server :: ConnectionPool -> Server API
server pool = healthHandler :<|> usersHandler pool :<|> tickersHandler pool :<|> ordersHandler pool
