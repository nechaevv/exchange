module WaiApp
    ( app
    ) where

import Network.Wai (Application)
import Data.Data (Proxy)
import Servant
import Api

api :: Proxy API
api = Proxy

app :: Application
app = serve api server
