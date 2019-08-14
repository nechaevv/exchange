{-# LANGUAGE DataKinds  #-}
module DBIO(
  DBIO,
  DBOp,
  runDBIO,
  liftDBIO,
  ConnectionPool,
  initConnectionPool,
  queryList,
  queryListParam
) where

import Control.Monad
import Control.Monad.IO.Class
import Data.ByteString (ByteString)
import Data.Pool
import Database.PostgreSQL.Simple

type ConnectionPool = Pool Connection
type DBOp a = Connection -> IO a

data DBIO a = Pure DBOp a | Wrapped (IO (DBIO a))

instance MonadIO DBIO where
  liftIO m = Pure $ const m

instance Functor DBIO where
  fmap fn (Pure dbop) = Pure dbop <$> fn
  fmap fn Wrapped io = fn <$> io

instance Applicative DBIO where
  pure m = Pure $ const m
--  (<*>) fn Pure dbop = Pure $ fn <$> 

-- instance Monad DBIO where
  

runDBIO :: ConnectionPool -> DBIO a -> IO a
runDBIO pool dbio = withResource pool $ \conn -> exec conn dbio
  where exec :: Connection -> DBIO a -> IO a
        exec conn (Pure a) = a conn
        exec conn (Free fa) = fa >>= \a -> exec conn a

liftDBIO :: MonadIO m => ConnectionPool -> DBIO a -> m a
liftDBIO pool dbio = liftIO $ runDBIO pool dbio

type ConnectionString = ByteString

initConnectionPool :: ConnectionString -> IO ConnectionPool
initConnectionPool connStr =
  createPool (connectPostgreSQL connStr)
             close
             1 -- stripes
             10 -- unused connections are kept open for a minute
             10 -- max. 10 connections open per stripe

--flip3 :: (a -> b -> c -> d) -> b -> c -> a -> d
--flip3 fn = flip fn

queryListParam :: (ToRow q, FromRow r) => Query -> q -> DBOp [r]
queryListParam qt q conn = Database.PostgreSQL.Simple.query conn qt q

queryList :: (FromRow r) => Query -> DBOp [r]
queryList qt conn = Database.PostgreSQL.Simple.query_ conn qt

