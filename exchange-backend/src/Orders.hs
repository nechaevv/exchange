{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric  #-}
{-# LANGUAGE OverloadedStrings #-}

module Orders where

import Data.UUID
import Data.Time
import Database.PostgreSQL.Simple
import DBIO
import GHC.Generics (Generic)
import Tickers
import Users

type OrderId = Int

data UserOrder = UserOrder {
  orderId :: OrderId,
  tickerId :: TickerId,
  userId :: UserId,
  orderType :: String,
  limitPrice :: Maybe Rational,
  stopPrice :: Maybe Rational,
  amount :: Rational,
  isActive :: Bool,
  orderTime :: LocalTime
} deriving(Generic, FromRow)

userOrdersList :: UserId -> DBIO[UserOrder]
userOrdersList userId = return $ \conn -> query conn
  "select id, \"tickerId\", \"userId\", \"orderType\", \"limitPrice\", \"stopPrice\",\
             \\"amount\", \"isActive\", \"orderTime\" from \"Orders\"\
             \where \"userId\"=?" [userId]