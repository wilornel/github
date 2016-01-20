{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}
module Github.UsersSpec where

import Data.Aeson.Compat  (eitherDecodeStrict)
import Data.Either.Compat (isRight, isLeft)
import Data.FileEmbed     (embedFile)
import System.Environment (lookupEnv)
import Test.Hspec         (Spec, describe, it, pendingWith, shouldBe,
                           shouldSatisfy)

import Github.Data             (GithubAuth (..), User (..), Organization (..), fromGithubOwner)
import Github.Request          (executeRequest)
import Github.Users            (userInfoCurrent', userInfoFor', ownerInfoForR)
import Github.Users.Followers  (usersFollowedByR, usersFollowingR)

fromRightS :: Show a => Either a b -> b
fromRightS (Right b) = b
fromRightS (Left a) = error $ "Expected a Right and got a Left" ++ show a

fromLeftS :: Show b => Either a b -> a
fromLeftS (Left b) = b
fromLeftS (Right a) = error $ "Expected a Left and got a RIght" ++ show a

withAuth :: (GithubAuth -> IO ()) -> IO ()
withAuth action = do
  mtoken <- lookupEnv "GITHUB_TOKEN"
  case mtoken of
    Nothing    -> pendingWith "no GITHUB_TOKEN"
    Just token -> action (GithubOAuth token)

spec :: Spec
spec = do
  describe "userInfoFor" $ do
    it "decodes user json" $ do
      let userInfo = eitherDecodeStrict $(embedFile "fixtures/user.json")
      userLogin (fromRightS userInfo) `shouldBe` "mike-burns"

    it "returns information about the user" $ withAuth $ \auth -> do
      userInfo <- userInfoFor' (Just auth) "mike-burns"
      userLogin (fromRightS userInfo) `shouldBe` "mike-burns"

    it "catches http exceptions" $ withAuth $ \auth -> do
      userInfo <- userInfoFor' (Just auth) "i-hope-this-user-will-never-exist"
      userInfo `shouldSatisfy` isLeft

    it "should fail for organization" $ withAuth $ \auth -> do
      userInfo <- userInfoFor' (Just auth) "haskell"
      userInfo `shouldSatisfy` isLeft

  describe "ownerInfoFor" $ do
    it "works for users and organizations" $ withAuth $ \auth -> do
      a <- executeRequest auth $ ownerInfoForR "haskell"
      b <- executeRequest auth $ ownerInfoForR "phadej"
      a `shouldSatisfy` isRight
      b `shouldSatisfy` isRight
      (organizationLogin . fromRightS . fromGithubOwner . fromRightS $ a) `shouldBe` "haskell"
      (userLogin . fromLeftS . fromGithubOwner . fromRightS $ b) `shouldBe` "phadej"

  describe "userInfoCurrent'" $ do
    it "returns information about the autenticated user" $ withAuth $ \auth -> do
      userInfo <- userInfoCurrent' auth
      userInfo `shouldSatisfy` isRight

  describe "usersFollowing" $ do
    it "works" $ withAuth $ \auth -> do
      us <- executeRequest auth $ usersFollowingR "phadej" (Just 10)
      us `shouldSatisfy` isRight

  describe "usersFollowedBy" $ do
    it "works" $ withAuth $ \auth -> do
      us <- executeRequest auth $ usersFollowedByR "phadej" (Just 10)
      us `shouldSatisfy` isRight
