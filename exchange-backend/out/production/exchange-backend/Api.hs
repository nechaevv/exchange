{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
module Api where

import Servant
import Servant.API

type HealthApi = "health" :> Post '[PlainText] NoContent

healthHandler :: Handler NoContent
healthHandler = return NoContent

type Api = "api" :> HealthApi

server :: Server Api
server = healthHandler
