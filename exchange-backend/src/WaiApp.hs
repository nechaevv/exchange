module WaiApp
    ( app
    ) where

import Network.Wai (Application)
import Data.Data (Proxy)
import Servant
import Api
import DBIO

api :: Proxy API
api = Proxy

app :: ConnectionPool -> Application
app pool = serve api $ server pool
