{-# LANGUAGE DataKinds  #-}
module DB where

import Data.ByteString (ByteString)
import Data.Pool
import Database.PostgreSQL.Simple

import Control.Monad.Free
import Control.Monad.Trans.Class (MonadTrans)
import Control.Monad.Trans.State (StateT)
import Servant (Handler)
import Control.Monad.IO.Class (liftIO)

type ConnectionString = ByteString
type ConnectionPool = Pool Connection

initConnectionPool :: ConnectionString -> IO ConnectionPool
initConnectionPool connStr =
  createPool (connectPostgreSQL connStr)
             close
             1 -- stripes
             10 -- unused connections are kept open for a minute
             10 -- max. 10 connections open per stripe

type DBOp a = Connection -> IO a
type DBIO a = Free IO (DBOp a)

dbio :: DBOp a -> DBIO a
dbio = Pure

runDBIO :: ConnectionPool -> DBIO a -> IO a
runDBIO pool dbio = withResource pool $ \conn -> exec conn dbio
  where exec :: Connection -> DBIO a -> IO a
        exec conn (Pure a) = a conn
        exec conn (Free fa) = fa >>= \a -> exec conn a

liftDBIO :: ConnectionPool -> DBIO a -> Handler a
liftDBIO pool dbio = liftIO $ runDBIO pool dbio