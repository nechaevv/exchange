module DB where

import Data.ByteString (ByteString)
import Data.Pool
import Database.PostgreSQL.Simple

type ConnectionString = ByteString
type ConnectionPool = Pool Connection

initConnectionPool :: ConnectionString -> IO ConnectionPool
initConnectionPool connStr =
  createPool (connectPostgreSQL connStr)
             close
             2 -- stripes
             60 -- unused connections are kept open for a minute
             10 -- max. 10 connections open per stripe
