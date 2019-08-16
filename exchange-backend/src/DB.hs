module DB (
  DBIO,
  ConnectionPool,
  initConnectionPool, 
  liftDBIO,
  queryList,
  queryListParam
) where

import Control.Monad.IO.Class
import Data.ByteString (ByteString)
import Data.Pool
import Database.PostgreSQL.Simple
import DBIO

type ConnectionString = ByteString
type ConnectionPool = Pool Connection

initConnectionPool :: ConnectionString -> IO ConnectionPool
initConnectionPool connStr =
  createPool (connectPostgreSQL connStr)
             close
             1 -- stripes
             10 -- unused connections are kept open for a minute
             10 -- max. 10 connections open per stripe

queryListParam :: (ToRow q, FromRow r) => Query -> q -> DBIO [r]
queryListParam qt q = Pure $ \conn -> Database.PostgreSQL.Simple.query conn qt q

queryList :: (FromRow r) => Query -> DBIO [r]
queryList qt = Pure $ \conn -> Database.PostgreSQL.Simple.query_ conn qt

liftDBIO :: MonadIO m => ConnectionPool -> DBIO a -> m a
liftDBIO pool dbio = liftIO $ withResource pool $ runDBIO dbio
