{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric      #-}
-----------------------------------------------------------------------------
-- |
-- License     :  BSD-3-Clause
-- Maintainer  :  Oleg Grenrus <oleg.grenrus@iki.fi>
--
module Github.Data.Teams where

import Github.Data.Definitions

import Control.DeepSeq          (NFData (..))
import Control.DeepSeq.Generics (genericRnf)
import Data.Binary              (Binary)
import Data.Data                (Data, Typeable)
import Data.Text                (Text)
import Data.Vector              (Vector)
import GHC.Generics             (Generic)

import Github.Data.Id    (Id)
import Github.Data.Name  (Name)
import Github.Data.Repos (Repo)

data Privacy =
    PrivacyClosed
  | PrivacySecret
  deriving (Show, Data, Typeable, Eq, Ord, Generic)

instance NFData Privacy where rnf = genericRnf
instance Binary Privacy

data Permission =
    PermissionPull
  | PermissionPush
  | PermissionAdmin
  deriving (Show, Data, Typeable, Eq, Ord, Generic)

instance NFData Permission where rnf = genericRnf
instance Binary Permission

data SimpleTeam = SimpleTeam {
   simpleTeamId              :: !(Id Team)
  ,simpleTeamUrl             :: !Text
  ,simpleTeamName            :: !Text
  ,simpleTeamSlug            :: !(Name Team)
  ,simpleTeamDescription     :: !(Maybe Text)
  ,simpleTeamPrivacy         :: !(Maybe Privacy)
  ,simpleTeamPermission      :: !Permission
  ,simpleTeamMembersUrl      :: !Text
  ,simpleTeamRepositoriesUrl :: !Text
} deriving (Show, Data, Typeable, Eq, Ord, Generic)

instance NFData SimpleTeam where rnf = genericRnf
instance Binary SimpleTeam

data Team = Team {
   teamId              :: !(Id Team)
  ,teamUrl             :: !Text
  ,teamName            :: !(Name Team)
  ,teamSlug            :: !Text
  ,teamDescription     :: !(Maybe Text)
  ,teamPrivacy         :: !(Maybe Privacy)
  ,teamPermission      :: !Permission
  ,teamMembersUrl      :: !Text
  ,teamRepositoriesUrl :: !Text
  ,teamMembersCount    :: !Int
  ,teamReposCount      :: !Int
  ,teamOrganization    :: !SimpleOrganization
} deriving (Show, Data, Typeable, Eq, Ord, Generic)

instance NFData Team where rnf = genericRnf
instance Binary Team

data CreateTeam = CreateTeam {
   createTeamName        :: !(Name Team)
  ,createTeamDescription :: !(Maybe Text)
  ,createTeamRepoNames   :: !(Vector (Name Repo))
  {-,createTeamPrivacy :: Privacy-}
  ,createTeamPermission  :: Permission
} deriving (Show, Data, Typeable, Eq, Ord, Generic)

instance NFData CreateTeam where rnf = genericRnf
instance Binary CreateTeam

data EditTeam = EditTeam {
   editTeamName        :: !(Name Team)
  ,editTeamDescription :: !(Maybe Text)
  {-,editTeamPrivacy :: Privacy-}
  ,editTeamPermission  :: !Permission
} deriving (Show, Data, Typeable, Eq, Ord, Generic)

instance NFData EditTeam where rnf = genericRnf
instance Binary  EditTeam

data Role =
     RoleMaintainer
  |  RoleMember
  deriving (Show, Data, Typeable, Eq, Ord, Generic)

instance NFData Role
instance Binary Role

data ReqState =
     StatePending
  |  StateActive
  deriving (Show, Data, Typeable, Eq, Ord, Generic)

instance NFData ReqState where rnf = genericRnf
instance Binary ReqState

data TeamMembership = TeamMembership {
  teamMembershipUrl      :: !Text,
  teamMembershipRole     :: !Role,
  teamMembershipReqState :: !ReqState
} deriving (Show, Data, Typeable, Eq, Ord, Generic)

instance NFData TeamMembership where rnf = genericRnf
instance Binary TeamMembership

data CreateTeamMembership = CreateTeamMembership {
  createTeamMembershipRole :: !Role
} deriving (Show, Data, Typeable, Eq, Ord, Generic)

instance NFData CreateTeamMembership where rnf = genericRnf
instance Binary CreateTeamMembership
