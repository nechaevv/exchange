module WaiApp
    ( app
    ) where

import Network.Wai (Application)
import Data.Data (Proxy)
import Servant
import Api

apiProxy :: Proxy Api
apiProxy = Proxy

app :: Application
app = serve apiProxy server
