{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Monad ( when )
import Safe ( headMay )
import System.Environment ( getArgs )
import Unison.Codebase.Serialization.V0 ( formatSymbol )
import Unison.Parser ( Ann(External) )
import qualified Unison.Codebase.Editor.HandleInput as HandleInput
import qualified Unison.Codebase.FileCodebase2 as FileCodebase
import qualified Unison.Codebase.Serialization as S
import qualified Unison.CommandLine.Main2 as CommandLine
import qualified Unison.Runtime.Rt1IO as Rt1

main :: IO ()
main = do
  args <- getArgs
  -- hSetBuffering stdout NoBuffering -- cool
  let codebasePath  = ".unison/v0"
      initialBranchName = "master"
      scratchFilePath   = "."
      theCodebase =
        FileCodebase.codebase1 External formatSymbol formatAnn codebasePath
      launch = CommandLine.main
        scratchFilePath
        initialBranchName
        (headMay args)
        (pure Rt1.runtime)
        theCodebase
  exists <- FileCodebase.exists codebasePath
  when (not exists) $ do
    putStrLn $ "☝️  No codebase exists here so I'm initializing one in: " <> codebasePath
    FileCodebase.initialize codebasePath
  -- Editor.initializeCodebase theCodebase
  launch

formatAnn :: S.Format Ann
formatAnn = S.Format (pure External) (\_ -> pure ())