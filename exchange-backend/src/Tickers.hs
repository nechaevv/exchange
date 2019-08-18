{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric  #-}
{-# LANGUAGE OverloadedStrings #-}
module Tickers where

import GHC.Generics (Generic)
import Data.UUID (UUID)
import DB

type TickerId = UUID

data Ticker = Ticker {
  tickerId :: TickerId,
  symbol :: String,
  name :: String
} deriving (Generic, FromRow)

tickerList :: DBIO[Ticker]
tickerList = query "select id, symbol, name from \"Tickers\""
