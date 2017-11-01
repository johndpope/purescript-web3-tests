module Utils where

import Prelude

import Control.Error.Util (note)
import Control.Monad.Aff (Aff, liftEff')
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Exception (EXCEPTION, throw)
import Control.Monad.Eff.Unsafe (unsafeCoerceEff)
import Control.Monad.Except (runExcept)
import Data.Argonaut (decodeJson)
import Data.Argonaut.Parser (jsonParser)
import Data.Argonaut.Prisms (_Object, _String)
import Data.Either (either)
import Data.EitherR (fmapL)
import Data.Foreign (renderForeignError)
import Data.Foreign.Class (decode, encode)
import Data.Lens ((^?))
import Data.Lens.Index (ix)
import Data.Maybe (maybe)
import Data.Symbol (class IsSymbol, SProxy, reflectSymbol)
import Network.Ethereum.Web3.Api (net_version)
import Network.Ethereum.Web3.Provider (class IsAsyncProvider, HttpProvider, Provider, getAsyncProvider, httpProvider, runWeb3MA)
import Network.Ethereum.Web3.Types (Address, ETH, Web3MA(..))
import Node.Encoding (Encoding(UTF8))
import Node.FS.Aff (FS, readTextFile)
import Node.Process (PROCESS, lookupEnv)


makeProvider :: forall eff . Eff (eth :: ETH, exception :: EXCEPTION | eff) Provider
makeProvider = unsafeCoerceEff $ do
  murl <- lookupEnv "NODE_URL"
  url <- maybe (throw "Must provide node url") pure murl
  httpProvider url

data HttpProvider'

instance providerHttp :: IsAsyncProvider HttpProvider' where
  getAsyncProvider = Web3MA <<< liftEff' $ makeProvider

newtype Contract (name :: Symbol) =
  Contract { address :: Address
           }

getDeployedContract :: forall eff name .
                       IsSymbol name
                    => SProxy name
                    -> Aff (fs :: FS, eth :: ETH, exception :: EXCEPTION | eff) (Contract name)
getDeployedContract sproxy = do
  let fname = "./build/contracts/" <> reflectSymbol sproxy <> ".json"
  nodeId <- runWeb3MA (net_version :: Web3MA HttpProvider' _ _)
  ejson <- jsonParser <$> readTextFile UTF8 fname
  addr <- liftEff $ either throw pure $ do
    contractJson <- ejson
    networks <- note "artifact missing networks key" $ contractJson ^? _Object <<< ix "networks"
    net <- note ("artifact missing network: " <> show nodeId)  $ networks ^? _Object <<< ix (show nodeId)
    addr <- note "artifact has no address" $ net ^? _Object <<< ix "address" <<< _String
    fmapL (show <<< map renderForeignError) <<< runExcept <<< decode <<< encode $ addr
  pure $ Contract { address: addr
                  }


{-
foo = void <<< launchAff $ do
  p <- liftEff makeProvider
  r <- getDeployedAddress p "SimpleStorage"
  liftEff $ logShow r
  pure r
-}
