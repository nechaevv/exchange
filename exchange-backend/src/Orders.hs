{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric  #-}
{-# LANGUAGE OverloadedStrings #-}

module Orders where

import Data.UUID
import Data.Time
import DB
import GHC.Generics (Generic)
import Tickers
import Users
import Data.Scientific (Scientific)

type OrderId = Int

data UserOrder = UserOrder {
  orderId :: OrderId,
  tickerId :: TickerId,
  userId :: UserId,
  orderType :: String,
  limitPrice :: Maybe Scientific,
  stopPrice :: Maybe Scientific,
  amount :: Scientific,
  isActive :: Bool,
  orderTime :: LocalTime
} deriving(Generic, FromRow)

userOrdersList :: UserId -> DBIO[UserOrder]
userOrdersList userId = queryWith
  "select id, \"tickerId\", \"userId\", \"type\"::text, \"limitPrice\", \"stopPrice\",\
             \\"amount\", \"isActive\", \"orderTime\" from \"Orders\"\
             \where \"userId\"=?" [userId]
