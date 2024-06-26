---------------------------- Main Menus ----------------------------------------------
function UnitPopupMenuSelf:GetMenuButtons()
	return {
		UnitPopupRaidTargetButtonMixin, 
		UnitPopupSetFocusButtonMixin,
		UnitPopupSelfHighlightSelectButtonMixin,
		UnitPopupPvpFlagButtonMixin,
		UnitPopupLootSubsectionTitle,
		UnitPopupSelectLootSpecializationButtonMixin,
		UnitPopupInstanceSubsectionTitle,
		UnitPopupConvertToRaidButtonMixin,
		UnitPopupConvertToPartyButtonMixin,
		UnitPopupDungeonDifficultyButtonMixin,
		UnitPopupRaidDifficultyButtonMixin, 
		UnitPopupResetInstancesButtonMixin,
		UnitPopupResetChallengeModeButtonMixin, 
		UnitPopupGarrisonVisitButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupEnterEditModeMixin,
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupSelectRoleButtonMixin,
		UnitPopupMovePlayerFrameButtonMixin,
		UnitPopupMoveTargetFrameButtonMixin,
		UnitPopupPartyInstanceLeaveButtonMixin,
		UnitPopupPartyLeaveButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end

function UnitPopupMenuParty:GetMenuButtons()
	return {
		UnitPopupMenuFriendlyPlayer, --This is a submenu
		UnitPopupRafSummonButtonMixin,
		UnitPopupPromoteButtonMixin,
		UnitPopupPromoteGuideButtonMixin,
		UnitPopupMenuFriendlyPlayerInteract, --This is a submenu
		UnitPopupOtherSubsectionTitle,
		UnitPopupEnterEditModeMixin,
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupSelectRoleButtonMixin,
		UnitPopupMovePlayerFrameButtonMixin,
		UnitPopupMoveTargetFrameButtonMixin,
		UnitPopupReportGroupMemberButtonMixin,
		UnitPopupPvpReportGroupMemberButtonMixin,
		UnitPopupCopyCharacterNameButtonMixin,
		UnitPopupPvpReportAfkButtonMixin,
		UnitPopupVoteToKickButtonMixin,
		UnitPopupUninviteButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end

function UnitPopupMenuEnemyPlayer:GetMenuButtons()
	return {
		UnitPopupSetFocusButtonMixin,
		UnitPopupInteractSubsectionTitle,
		UnitPopupInspectButtonMixin, 
		UnitPopupAchievementButtonMixin,
		UnitPopupDuelButtonMixin,
		UnitPopupPetBattleDuelButtonMixin, 
		UnitPopupOtherSubsectionTitle,
		UnitPopupEnterEditModeMixin,
		UnitPopupMovePlayerFrameButtonMixin,
		UnitPopupMoveTargetFrameButtonMixin,
		UnitPopupReportInWorldButtonMixin,
		UnitPopupCopyCharacterNameButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end

function UnitPopupMenuRaidPlayer:GetMenuButtons()
	return {
		UnitPopupMenuFriendlyPlayer, --This is a subMenu
		UnitPopupRafSummonButtonMixin,
		UnitPopupSetRaidLeaderButtonMixin,
		UnitPopupSetRaidAssistButtonMixin, 
		UnitPopupSetRaidDemoteButtonMixin,
		UnitPopupMenuFriendlyPlayerInteract, --This is a subMenu
		UnitPopupOtherSubsectionTitle,
		UnitPopupVoiceChatButtonMixin, 
		UnitPopupSelectRoleButtonMixin,
		UnitPopupMovePlayerFrameButtonMixin,
		UnitPopupMoveTargetFrameButtonMixin,
		UnitPopupEnterEditModeMixin,
		UnitPopupReportGroupMemberButtonMixin,
		UnitPopupPvpReportGroupMemberButtonMixin,
		UnitPopupCopyCharacterNameButtonMixin,
		UnitPopupPvpReportAfkButtonMixin,
		UnitPopupVoteToKickButtonMixin,
		UnitPopupSetRaidRemoveButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end

function UnitPopupMenuBnFriend:GetMenuButtons()
	return { 
		UnitPopupPopoutChatButtonMixin,
		UnitPopupBnetTargetButtonMixin,
		UnitPopupSetBNetNoteButtonMixin, 
		UnitPopupViewBnetFriendsButtonMixin,
		UnitPopupInteractSubsectionTitle,
		UnitPopupRafSummonButtonMixin,
		UnitPopupBnetInviteButtonMixin,
		UnitPopupBnetSuggestInviteButtonMixin,
		UnitPopupBnetRequestInviteButtonMixin,
		UnitPopupWhisperButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupDeleteCommunityMessageButtonMixin,
		UnitPopupBnetAddFavoriteButtonMixin,
		UnitPopupBnetRemoveFavoriteButtonMixin,
		UnitPopupRemoveBnetFriendButtonMixin,
		UnitPopupReportFriendButtonMixin,
		UnitPopupReportChatButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end 

function UnitPopupMenuBnFriendOffline:GetMenuButtons()
	return { 
		UnitPopupSetBNetNoteButtonMixin, 
		UnitPopupViewBnetFriendsButtonMixin,
		UnitPopupInteractSubsectionTitle,
		UnitPopupWhisperButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupBnetAddFavoriteButtonMixin,
		UnitPopupBnetRemoveFavoriteButtonMixin,
		UnitPopupRemoveBnetFriendButtonMixin,
		UnitPopupReportFriendButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end

function UnitPopupMenuCommunitiesWowMember:GetMenuButtons()
	return {
		UnitPopupTargetButtonMixin,
		UnitPopupAddFriendMenuButtonMixin, 
		UnitPopupSubsectionSeperatorMixin, 
		UnitPopupVoiceChatMicrophoneVolumeButtonMixin, 
		UnitPopupVoiceChatSpeakerVolumeButtonMixin,
		UnitPopupVoiceChatUserVolumeButtonMixin,
		UnitPopupInteractSubsectionTitle,
		UnitPopupMenuFriendlyPlayerInviteOptions, --Submenu
		UnitPopupWhisperButtonMixin,
		UnitPopupIgnoreButtonMixin,
		UnitPopupCommunitiesLeaveButtonMixin,
		UnitPopupCommunitiesKickFriendButtonMixin,
		UnitPopupCommunitiesMemberNoteButtonMixin,
		UnitPopupCommunitiesRoleButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupReportClubMemberButtonMixin,
		UnitPopupCopyCharacterNameButtonMixin,
		UnitPopupCancelButtonMixin, 
	}
end

function UnitPopupMenuCommunitiesGuildMember:GetMenuButtons()
	return {
		UnitPopupTargetButtonMixin,
		UnitPopupAddFriendMenuButtonMixin, 
		UnitPopupSubsectionSeperatorMixin, 
		UnitPopupVoiceChatMicrophoneVolumeButtonMixin, 
		UnitPopupVoiceChatSpeakerVolumeButtonMixin,
		UnitPopupVoiceChatUserVolumeButtonMixin,
		UnitPopupSubsectionSeperatorMixin, 
		UnitPopupInteractSubsectionTitle,
		UnitPopupMenuFriendlyPlayerInviteOptions, --Submenu
		UnitPopupWhisperButtonMixin,
		UnitPopupIgnoreButtonMixin,
		UnitPopupGuildPromoteButtonMixin,
		UnitPopupOtherSubsectionTitle,
		UnitPopupGuildLeaveButtonMixin,
		UnitPopupReportClubMemberButtonMixin,
		UnitPopupCopyCharacterNameButtonMixin,
		UnitPopupCancelButtonMixin, 
	}
end

UnitPopupRafRecruit = CreateFromMixins(UnitPopupTopLevelMenuMixin);
UnitPopupManager:RegisterMenu("RAF_RECRUIT", UnitPopupRafRecruit);
function UnitPopupRafRecruit:GetMenuButtons()
	return {
		UnitPopupAddFriendButtonMixin,
		UnitPopupAddFriendMenuButtonMixin, 
		UnitPopupInteractSubsectionTitle, 
		UnitPopupRafSummonButtonMixin, 
		UnitPopupMenuFriendlyPlayerInviteOptions, --Submenu
		UnitPopupWhisperButtonMixin,
		UnitPopupOtherSubsectionTitle,
		--UnitPopupRafRemoveRecruitButtonMixin,
		UnitPopupCancelButtonMixin, 
	}
end