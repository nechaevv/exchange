module DB (
  DBIO,
  ConnectionPool,
  PG.FromRow,
  PG.ToRow,
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
import Data.Pool
import Data.Time.Clock (NominalDiffTime)
import qualified Database.PostgreSQL.Simple as PG
import Control.Monad.Trans.Reader (ask, ReaderT, runReaderT)
import Control.Monad (liftM)
import Data.Int (Int64)

type ConnectionString = ByteString
type ConnectionPool = Pool PG.Connection
type DBIO = ReaderT PG.Connection IO

initConnectionPool :: ConnectionString -> Int -> NominalDiffTime -> Int -> IO ConnectionPool
initConnectionPool connStr = createPool (PG.connectPostgreSQL connStr) PG.close

liftDBIO :: MonadIO m => ConnectionPool -> DBIO a -> m a
liftDBIO pool dbio = liftIO $ withResource pool $ runReaderT dbio

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
  
