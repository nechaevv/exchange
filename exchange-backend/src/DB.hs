module DB (
  DBIO,
  ConnectionString,
  ConnectionPool,
  DBPoolConfig,
  PG.FromRow,
  PG.ToRow,
  PGF.FromField,
  initConnectionPool, 
  liftDBIO,
  query,
  queryWith,
  fold,
  foldWith,
  execute,
  executeWith,
  executeMany,
  transactionally
) where

import Control.Monad.IO.Class
import Data.ByteString (ByteString)
import qualified Data.Pool
import Data.Time.Clock (NominalDiffTime)
import qualified Database.PostgreSQL.Simple as PG
--import qualified Database.PostgreSQL.Simple.Types as PGT
import qualified Database.PostgreSQL.Simple.FromField as PGF
import Control.Monad.Trans.Reader (ask, ReaderT, runReaderT)
import Control.Monad (liftM)
import Data.Int (Int64)

type ConnectionString = ByteString
type ConnectionPool = Data.Pool.Pool PG.Connection
type DBIO = ReaderT PG.Connection IO

data DBPoolConfig = DBPoolConfig {
  connectionString :: ConnectionString,
  numStripes :: Int,
  idleTime :: NominalDiffTime,
  maxResources :: Int
}

initConnectionPool :: DBPoolConfig -> IO ConnectionPool
initConnectionPool config = Data.Pool.createPool (PG.connectPostgreSQL (connectionString config)) PG.close
  (numStripes config) (idleTime config) (maxResources config)
  

liftDBIO :: MonadIO m => ConnectionPool -> DBIO a -> m a
liftDBIO pool dbio = liftIO $ Data.Pool.withResource pool $ runReaderT dbio

withConnection :: (PG.Connection -> IO a) -> DBIO a
withConnection dbOp = ask >>= \conn -> liftIO $ dbOp conn

queryWith :: (PG.ToRow q, PG.FromRow r) => PG.Query -> q -> DBIO [r]
queryWith queryString queryParam = withConnection $ \conn ->
  PG.query conn queryString queryParam

query :: (PG.FromRow r) => PG.Query -> DBIO [r]
query queryString = withConnection $ \conn ->
  PG.query_ conn queryString

foldWith :: (PG.ToRow q, PG.FromRow row) => PG.Query -> q -> a -> (a -> row -> IO a) -> DBIO a
foldWith queryString queryParam a foldFn = withConnection $ \conn ->
  PG.fold conn queryString queryParam a foldFn

fold :: (PG.FromRow row) => PG.Query -> a -> (a -> row -> IO a) -> DBIO a
fold queryString a foldFn = withConnection $ \conn ->
  PG.fold_ conn queryString a foldFn

execute :: PG.Query -> DBIO Int64
execute queryString = withConnection $ \conn ->
  PG.execute_ conn queryString

executeWith :: (PG.ToRow q) => PG.Query -> q -> DBIO Int64
executeWith queryString queryParam = withConnection $ \conn ->
  PG.execute conn queryString queryParam

executeMany :: (PG.ToRow q) => PG.Query -> [q] -> DBIO Int64
executeMany queryString queryParams = withConnection $ \conn ->
  PG.executeMany conn queryString queryParams

transactionally :: DBIO a -> DBIO a
transactionally dbio = withConnection $ \conn ->
  PG.withTransaction conn $ runReaderT dbio conn
  
