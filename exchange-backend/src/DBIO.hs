{-# LANGUAGE GADTs #-}
module DBIO where

import Control.Monad
import Control.Monad.IO.Class
import Data.ByteString (ByteString)
import Data.Pool
import Database.PostgreSQL.Simple
import GHC.Base

type DBOp a = Connection -> IO a

data DBIO a where
  Pure :: DBOp a -> DBIO a
  Wrapped :: IO (DBIO a) -> DBIO a
  Joined :: (b -> c -> a) -> DBIO b -> (b -> DBIO c) -> DBIO a

instance Functor DBIO where
  fmap fn (Pure dbop) = Pure $ fmap fn . dbop
  fmap fn (Wrapped io) = Wrapped $ fmap fn <$> io
  fmap fn (Joined biFn b c) = Joined joinFn b c
    where joinFn = ((.).(.)) fn biFn


instance Applicative DBIO where
  pure m = Pure $ \_ -> return m
  liftA2 biFn b c = Joined biFn b (const c)

instance Monad DBIO where
  (>>=) = Joined (const id)

instance MonadIO DBIO where
  liftIO m = Pure $ const m

runDBIO :: DBIO a -> Connection -> IO a
runDBIO (Pure a) conn = a conn
runDBIO (Wrapped fa) conn = fa >>= \a -> runDBIO a conn 
runDBIO (Joined biFn fa fb) conn = liftA2 biFn ioa iob
  where ioa = runDBIO fa conn
        iob = ioa >>= \a -> runDBIO (fb a) conn


