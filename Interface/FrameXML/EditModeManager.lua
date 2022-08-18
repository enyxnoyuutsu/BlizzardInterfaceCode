EditModeManagerFrameMixin = {};

function EditModeManagerFrameMixin:OnLoad()
	self.registeredSystemFrames = {};
	self.RightActionBarsInLayout = {};
	self.modernSystemMap = EditModePresetLayoutManager:GetModernSystemMap();
	self.modernSystems = EditModePresetLayoutManager:GetModernSystems();

	self.LayoutDropdown:AddTopLabel(HUD_EDIT_MODE_LAYOUT);
	self.LayoutDropdown:SetTextJustifyH("LEFT");

	self.buttonEntryPool = CreateFramePool("FRAME", self, "EditModeDropdownEntryTemplate");
	self.layoutEntryPool = CreateFramePool("FRAME", self, "EditModeDropdownLayoutEntryTemplate");

	local function clearLockedLayoutButton()
		self:ClearLockedLayoutButton();
	end

	self.LayoutDropdown.DropDownMenu.onHide = clearLockedLayoutButton;

	local function createNewLayout()
		self:ShowNewLayoutDialog();
	end

	local function importLayout()
		self:ShowImportLayoutDialog();
	end

	local function shareLayout(layoutButton)
		self:ToggleShareDropdown(layoutButton);
	end

	local function copyToClipboard()
		self:CopyActiveLayoutToClipboard();
	end

	local function postInChat()
		self:LinkActiveLayoutToChat();
	end

	local function copyLayout()
		self:ShowNewLayoutDialog(self.lockedLayoutButton.layoutData);
	end

	local function renameLayout()
		self:ShowRenameLayoutDialog(self.lockedLayoutButton);
	end

	local function selectLayout(layoutButton)
		UIDropDownMenuButton_OnClick(layoutButton.owningButton);
	end

	local newLayoutButtonText = HUD_EDIT_MODE_NEW_LAYOUT:format(CreateAtlasMarkup("editmode-new-layout-plus"));
	local newLayoutButtonTextDisabled = HUD_EDIT_MODE_NEW_LAYOUT_DISABLED:format(CreateAtlasMarkup("editmode-new-layout-plus-disabled"));
	local dropdownButtonWidth = 210;
	local shareDropdownButtonMaxTextWidth = 190;
	local shareSubDropdownButtonWidth = 220;
	local copyRenameSubDropdownButtonWidth = 150;
	local subMenuButton = true;
	local disableOnMaxLayouts = true;
	local disableOnMaxLayoutsNo = false;
	local disableOnActiveChanges = true;
	local disableOnActiveChangesNo = false;

	local function layoutEntryCustomSetup(dropDownButtonInfo, standardFunc)
		if dropDownButtonInfo.value == "newLayout" then
			local newButton = self.buttonEntryPool:Acquire();
			newButton:Init(newLayoutButtonText, createNewLayout, disableOnMaxLayouts, disableOnActiveChangesNo, dropdownButtonWidth, nil, nil, nil, newLayoutButtonTextDisabled);
			dropDownButtonInfo.customFrame = newButton;
		elseif dropDownButtonInfo.value == "import" then
			local newButton = self.buttonEntryPool:Acquire();
			newButton:Init(HUD_EDIT_MODE_IMPORT_LAYOUT, importLayout, disableOnMaxLayouts, disableOnActiveChanges, dropdownButtonWidth);
			dropDownButtonInfo.customFrame = newButton;
		elseif dropDownButtonInfo.value == "share" then
			local newButton = self.buttonEntryPool:Acquire();
			local showArrow = true;
			newButton:Init(HUD_EDIT_MODE_SHARE_LAYOUT, shareLayout, disableOnMaxLayoutsNo, disableOnActiveChangesNo, dropdownButtonWidth, shareDropdownButtonMaxTextWidth, showArrow);
			dropDownButtonInfo.customFrame = newButton;
		elseif dropDownButtonInfo.value == "copyToClipboard" then
			local newButton = self.buttonEntryPool:Acquire();
			newButton:Init(HUD_EDIT_MODE_COPY_TO_CLIPBOARD, copyToClipboard, disableOnMaxLayoutsNo, disableOnActiveChangesNo, shareSubDropdownButtonWidth, nil, nil, subMenuButton);
			dropDownButtonInfo.customFrame = newButton;
		elseif dropDownButtonInfo.value == "postInChat" then
			local newButton = self.buttonEntryPool:Acquire();
			newButton:Init(HUD_EDIT_MODE_POST_IN_CHAT, postInChat, disableOnMaxLayoutsNo, disableOnActiveChangesNo, shareSubDropdownButtonWidth, nil, nil, subMenuButton);
			dropDownButtonInfo.customFrame = newButton;
		elseif dropDownButtonInfo.value == "copyLayout" then
			local newButton = self.buttonEntryPool:Acquire();
			newButton:Init(HUD_EDIT_MODE_COPY_LAYOUT, copyLayout, disableOnMaxLayouts, disableOnActiveChangesNo, copyRenameSubDropdownButtonWidth, nil, nil, subMenuButton);
			dropDownButtonInfo.customFrame = newButton;
		elseif dropDownButtonInfo.value == "renameLayout" then
			local newButton = self.buttonEntryPool:Acquire();
			newButton:Init(HUD_EDIT_MODE_RENAME_LAYOUT, renameLayout, disableOnMaxLayoutsNo, disableOnActiveChangesNo, copyRenameSubDropdownButtonWidth, nil, nil, subMenuButton);
			dropDownButtonInfo.customFrame = newButton;
		elseif dropDownButtonInfo.value == "header" then
			dropDownButtonInfo.isTitle = true;
			dropDownButtonInfo.notCheckable = true;
		else
			local newButton = self.layoutEntryPool:Acquire();
			newButton:Init(dropDownButtonInfo.value, dropDownButtonInfo.data, self.layoutInfo.activeLayout == dropDownButtonInfo.value, selectLayout);
			dropDownButtonInfo.customFrame = newButton;
		end
	end

	self.LayoutDropdown:SetCustomSetup(layoutEntryCustomSetup);

	local function layoutSelectedCallback(value, isUserInput)
		if isUserInput then
			if self:HasActiveChanges() then
				self:ShowRevertWarningDialog(value);
			else
				self:SelectLayout(value);
			end
		end
	end

	local function onCloseCallback()
		if self:HasActiveChanges() then
			self:ShowRevertWarningDialog();
		else
			HideUIPanel(self);
		end
	end

	local function onShowGridCheckboxChecked(isChecked, isUserInput)
		self:SetGridShown(isChecked, isUserInput);
	end

	self.ShowGridCheckButton:SetCallback(onShowGridCheckboxChecked);

	self.onCloseCallback = onCloseCallback;

	self.LayoutDropdown:SetOptionSelectedCallback(layoutSelectedCallback);
	self.SaveChangesButton:SetOnClickHandler(GenerateClosure(self.SaveLayoutChanges, self));
	self.RevertAllChangesButton:SetOnClickHandler(GenerateClosure(self.RevertAllChanges, self));

	self:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player");
end

function EditModeManagerFrameMixin:OnDragStart()
	self:StartMoving();
end

function EditModeManagerFrameMixin:OnDragStop()
	self:StopMovingOrSizing();
end

function EditModeManagerFrameMixin:ShowSystemSelections()
	for _, systemFrame in ipairs(self.registeredSystemFrames) do
		systemFrame:OnEditModeEnter();
	end
end

function EditModeManagerFrameMixin:EnterEditMode()
	self.editModeActive = true;
	self:ClearActiveChangesFlags();
	self:UpdateDropdownOptions();
	self:ShowSystemSelections();
	self.AccountSettings:OnEditModeEnter();
end

function EditModeManagerFrameMixin:HideSystemSelections()
	for _, systemFrame in ipairs(self.registeredSystemFrames) do
		systemFrame:OnEditModeExit();
	end
end

function EditModeManagerFrameMixin:ExitEditMode()
	self.editModeActive = false;
	self:RevertAllChanges();
	self:HideSystemSelections();
	self.AccountSettings:OnEditModeExit();
end

function EditModeManagerFrameMixin:OnShow()
	if not self:IsEditModeLocked() then
		self:EnterEditMode();
	elseif self:IsEditModeInLockState("hideSelections")  then
		self:ShowSystemSelections();
	end

	self:ClearEditModeLockState();
	self:Layout();
end

function EditModeManagerFrameMixin:OnHide()
	if not self:IsEditModeLocked() then
		self:ExitEditMode();
	elseif self:IsEditModeInLockState("hideSelections") then
		self:HideSystemSelections();
	end
end

function EditModeManagerFrameMixin:IsEditModeActive()
	return self.editModeActive;
end

function EditModeManagerFrameMixin:SetEditModeLockState(lockState)
	self.editModeLockState = lockState;
end

function EditModeManagerFrameMixin:IsEditModeInLockState(lockState)
	return self.editModeLockState == lockState;
end

function EditModeManagerFrameMixin:ClearEditModeLockState()
	self.editModeLockState = nil;
end

function EditModeManagerFrameMixin:IsEditModeLocked()
	return self.editModeLockState ~= nil;
end

function EditModeManagerFrameMixin:OnEvent(event, ...)
	if event == "EDIT_MODE_LAYOUTS_UPDATED" then
		local layoutInfo, reconcileLayouts = ...;
		self:UpdateLayoutInfo(layoutInfo, reconcileLayouts);
		self:InitializeAccountSettings();
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		local layoutInfo = C_EditMode.GetLayouts();
		local activeLayoutChanged = (layoutInfo.activeLayout ~= self.layoutInfo.activeLayout);
		self:UpdateLayoutInfo(layoutInfo);
		if activeLayoutChanged then
			self:NotifyChatOfLayoutChange();
		end
	elseif event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" then
		self:UpdateRightAnchoredActionBarScales();
	end
end

function EditModeManagerFrameMixin:IsInitialized()
	return self.layoutInfo ~= nil;
end

function EditModeManagerFrameMixin:RegisterSystemFrame(systemFrame)
	table.insert(self.registeredSystemFrames, systemFrame);
end

function EditModeManagerFrameMixin:GetRegisteredSystemFrame(system, systemIndex)
	for _, systemFrame in ipairs(self.registeredSystemFrames) do
		if systemFrame.system == system and systemFrame.systemIndex == systemIndex then
			return systemFrame;
		end
	end

	return nil;
end

local function AreAnchorsEqual(anchorInfo, otherAnchorInfo)
	if anchorInfo and otherAnchorInfo then
		return anchorInfo.point == otherAnchorInfo.point
		and anchorInfo.relativeTo == otherAnchorInfo.relativeTo
		and anchorInfo.relativePoint == otherAnchorInfo.relativePoint
		and anchorInfo.offsetX == otherAnchorInfo.offsetX
		and anchorInfo.offsetY == otherAnchorInfo.offsetY
		and anchorInfo.isDefaultPosition == otherAnchorInfo.isDefaultPosition;
	end

	return anchorInfo == otherAnchorInfo;
end

local function CopyAnchorInfo(anchorInfo, otherAnchorInfo)
	if anchorInfo and otherAnchorInfo then
		anchorInfo.point = otherAnchorInfo.point;
		anchorInfo.relativeTo = otherAnchorInfo.relativeTo;
		anchorInfo.relativePoint = otherAnchorInfo.relativePoint;
		anchorInfo.offsetX = otherAnchorInfo.offsetX;
		anchorInfo.offsetY = otherAnchorInfo.offsetY;
		anchorInfo.isDefaultPosition = otherAnchorInfo.isDefaultPosition;
	end
end

local function ConvertToAnchorInfo(point, relativeTo, relativePoint, offsetX, offsetY, isDefaultPosition)
	if point then
		local anchorInfo = {};
		anchorInfo.point = point;
		anchorInfo.relativeTo = relativeTo and relativeTo:GetName() or "UIParent";
		anchorInfo.relativePoint = relativePoint;
		anchorInfo.offsetX = offsetX;
		anchorInfo.offsetY = offsetY;
		anchorInfo.isDefaultPosition = isDefaultPosition or false;
		return anchorInfo;
	end

	return nil;
end

function EditModeManagerFrameMixin:SetHasActiveChanges(hasActiveChanges)
	self.hasActiveChanges = hasActiveChanges;
	self.SaveChangesButton:SetEnabled(hasActiveChanges);
	self.RevertAllChangesButton:SetEnabled(hasActiveChanges);
end

function EditModeManagerFrameMixin:CheckForSystemActiveChanges()
	local hasActiveChanges = false;
	for _, systemFrame in ipairs(self.registeredSystemFrames) do
		if systemFrame:HasActiveChanges() then
			hasActiveChanges = true;
			break;
		end
	end

	self:SetHasActiveChanges(hasActiveChanges);
end

function EditModeManagerFrameMixin:HasActiveChanges()
	return self.hasActiveChanges;
end

local function UpdateSystemAnchorInfo(systemInfo, systemFrame, isDefaultPosition)
	local point, relativeTo, relativePoint, offsetX, offsetY = systemFrame:GetPoint(1);
	local newAnchorInfo = ConvertToAnchorInfo(point, relativeTo, relativePoint, offsetX, offsetY, isDefaultPosition);
	if not AreAnchorsEqual(systemInfo.anchorInfo, newAnchorInfo) then
		CopyAnchorInfo(systemInfo.anchorInfo, newAnchorInfo);
		return true;
	end

	return false;
end

function EditModeManagerFrameMixin:OnSystemPositionChange(systemFrame, isDefaultPosition)
	local systemInfo = self:GetActiveLayoutSystemInfo(systemFrame.system, systemFrame.systemIndex);
	if systemInfo then
		if UpdateSystemAnchorInfo(systemInfo, systemFrame, isDefaultPosition) then
			systemFrame:SetHasActiveChanges(true);

			local isRightActionBar = EditModeUtil:IsRightAnchoredActionBar(systemFrame);
			if isRightActionBar then
				self:UpdateRightAnchoredActionBarWidth();
			end

			if isRightActionBar or systemFrame == MinimapCluster then
				self:UpdateRightAnchoredActionBarScales();
			end

			if EditModeUtil:IsBottomAnchoredActionBar(systemFrame) then
				self:UpdateBottomAnchoredActionBarHeight();
			end

			if systemFrame.isBottomManagedFrame then
				UIParent_ManageFramePositions();
			end

			EditModeSystemSettingsDialog:UpdateDialog(systemFrame);
		end
	end
end

function EditModeManagerFrameMixin:MirrorSetting(system, systemIndex, setting, value)
	local mirroredSettings = EditModeSettingDisplayInfoManager:GetMirroredSettings(system, systemIndex, setting);
	if mirroredSettings then
		for _, mirroredSettingInfo in ipairs(mirroredSettings) do
			local systemFrame = self:GetRegisteredSystemFrame(mirroredSettingInfo.system, mirroredSettingInfo.systemIndex);
			if systemFrame then
				systemFrame:UpdateSystemSettingValue(setting, value);
			end
		end
	end
end

function EditModeManagerFrameMixin:OnSystemSettingChange(systemFrame, changedSetting, newValue)
	local systemInfo = self:GetActiveLayoutSystemInfo(systemFrame.system, systemFrame.systemIndex);
	if systemInfo then
		systemFrame:UpdateSystemSettingValue(changedSetting, newValue);
	end
end

function EditModeManagerFrameMixin:RevertSystemChanges(systemFrame)
	local activeLayoutInfo = self:GetActiveLayoutInfo();
	if activeLayoutInfo then
		for index, systemInfo in ipairs(activeLayoutInfo.systems) do
			if systemInfo.system == systemFrame.system and systemInfo.systemIndex == systemFrame.systemIndex then
				activeLayoutInfo.systems[index] = systemFrame.savedSystemInfo;

				systemFrame:UpdateSystem(systemFrame.savedSystemInfo);
				self:CheckForSystemActiveChanges();
				return;
			end
		end
	end
end

function EditModeManagerFrameMixin:GetSettingValue(system, systemIndex, setting, useRawValue)
	local systemFrame = self:GetRegisteredSystemFrame(system, systemIndex);
	if systemFrame then
		return systemFrame:GetSettingValue(setting, useRawValue)
	end
end

function EditModeManagerFrameMixin:GetSettingValueBool(system, systemIndex, setting, useRawValue)
	local systemFrame = self:GetRegisteredSystemFrame(system, systemIndex);
	if systemFrame then
		return systemFrame:GetSettingValueBool(setting, useRawValue)
	end
end

function EditModeManagerFrameMixin:DoesSettingValueEqual(system, systemIndex, setting, value)
	local systemFrame = self:GetRegisteredSystemFrame(system, systemIndex);
	if systemFrame then
		return systemFrame:DoesSettingValueEqual(setting, value);
	end
end

function EditModeManagerFrameMixin:DoesSettingDisplayValueEqual(system, systemIndex, setting, value)
	local systemFrame = self:GetRegisteredSystemFrame(system, systemIndex);
	if systemFrame then
		return systemFrame:DoesSettingDisplayValueEqual(setting, value);
	end
end

function EditModeManagerFrameMixin:GetRightAnchoredActionBarWidth()
	return self.rightAnchoredActionBarWidth;
end

function EditModeManagerFrameMixin:GetBottomAnchoredActionBarHeight()
	return self.bottomAnchoredActionBarHeight;
end

function EditModeManagerFrameMixin:UpdateRightAnchoredActionBarWidth()
	self.rightAnchoredActionBarWidth = EditModeUtil:GetRightActionBarWidth();
	UIParent_ManageFramePositions();
end

function EditModeManagerFrameMixin:UpdateRightAnchoredActionBarScales()
	if not self:IsInitialized() then
		return;
	end

	local topLimit = MinimapCluster:IsInDefaultPosition() and (MinimapCluster:GetBottom() - 10) or UIParent:GetTop();
	local bottomLimit = MicroButtonAndBagsBar:GetTop() + 24;
	local availableSpace = topLimit - bottomLimit;
	local multiBarHeight = MultiBarRight:GetHeight();

	if multiBarHeight <= availableSpace then
		MultiBarRight:SetScale(1);
		MultiBarLeft:SetScale(1);
		return;
	end

	local scale = availableSpace / multiBarHeight;
	MultiBarRight:SetScaleIfRightAnchored(scale);
	MultiBarLeft:SetScaleIfRightAnchored(scale);
end

function EditModeManagerFrameMixin:UpdateBottomAnchoredActionBarHeight(includeMainMenuBar)
	self.bottomAnchoredActionBarHeight =  EditModeUtil:GetBottomActionBarHeight(includeMainMenuBar);

	-- Update bottom anchoring bars which show on top of other bars since if other bottom bars changed we may wanna change those bars too
	local bottomAnchoredActionBarsToUpdate = { StanceBar, PetActionBar, PossessActionBar};

	local topMostBottomAnchoredBar = nil;
	if MultiBar2_IsVisible() and MultiBarBottomRight:IsInDefaultPosition() then
		topMostBottomAnchoredBar = MultiBarBottomRight;
	elseif MultiBar1_IsVisible() and MultiBarBottomLeft:IsInDefaultPosition() then
		topMostBottomAnchoredBar = MultiBarBottomLeft;
	elseif MainMenuBar:IsInDefaultPosition() then
		topMostBottomAnchoredBar = MainMenuBar;
	end

	for index, bar in ipairs(bottomAnchoredActionBarsToUpdate) do
		if (bar and bar:IsShown()) then
			-- Only update bar's anchor if it was already bottom anchored
			local point, relativeTo, relativePoint, offsetX, offsetY = bar:GetPoint(1);
			if EditModeUtil:IsBottomAnchoredActionBar(relativeTo) then
				if topMostBottomAnchoredBar and relativeTo ~= topMostBottomAnchoredBar then
					bar:SetPoint("BOTTOMLEFT", topMostBottomAnchoredBar, "TOPLEFT", 0, 5);
					
					local isDefaultPosition = true;
					EditModeManagerFrame:OnSystemPositionChange(bar, isDefaultPosition);
				end

				if bar:IsInDefaultPosition() then
					-- This bar is now the new topmost bar
					topMostBottomAnchoredBar = bar;
				end
			end
		end
	end

	UIParent_ManageFramePositions();
end

function EditModeManagerFrameMixin:SelectSystem(selectFrame)
	if not self:IsEditModeLocked() then
		for _, systemFrame in ipairs(self.registeredSystemFrames) do
			if systemFrame == selectFrame then
				systemFrame:SelectSystem();
			else
				-- Only highlight a system if it was already highlighted
				if systemFrame.isHighlighted then
					systemFrame:HighlightSystem();
				end
			end
		end
	end
end

function EditModeManagerFrameMixin:ClearSelectedSystem()
	for _, systemFrame in ipairs(self.registeredSystemFrames) do
		-- Only highlight a system if it was already highlighted
		if systemFrame.isHighlighted then
			systemFrame:HighlightSystem();
		end
	end
	EditModeSystemSettingsDialog:Hide();
end

function EditModeManagerFrameMixin:NotifyChatOfLayoutChange()
	local newActiveLayoutName = self:GetActiveLayoutInfo().layoutName;
	local systemChatInfo = ChatTypeInfo["SYSTEM"];
	DEFAULT_CHAT_FRAME:AddMessage(HUD_EDIT_MODE_LAYOUT_APPLIED:format(newActiveLayoutName), systemChatInfo.r, systemChatInfo.g, systemChatInfo.b, systemChatInfo.id);
end

-- This method handles removing any out-dated systems/settings from a saved layout data table
function EditModeManagerFrameMixin:RemoveOldSystemsAndSettings(layoutInfo)
	local removedSomething = false;
	local keepSystems = {};

	for _, layoutSystemInfo in ipairs(layoutInfo.systems) do
		local keepSystem;
		if layoutSystemInfo.systemIndex then
			keepSystem = self.modernSystemMap[layoutSystemInfo.system] and self.modernSystemMap[layoutSystemInfo.system][layoutSystemInfo.systemIndex];
		else
			keepSystem = self.modernSystemMap[layoutSystemInfo.system];
		end

		if keepSystem then
			-- This system still exists, so we want to add it to keepSystems, but first we want to check if any settings within it were removed
			local keepSettings = {};
			local removedSetting = false;
			for _, settingInfo in ipairs(layoutSystemInfo.settings) do
				if keepSystem.settings[settingInfo.setting] then
					-- This setting still exists, so we want to add it to keepSettings
					table.insert(keepSettings, settingInfo);
				else
					-- This setting no longer exists, so don't add it to keepSystems
					removedSomething = true;
					removedSetting = true;
				end
			end

			if removedSetting then
				-- A setting was removed, so replace the settings table with keepSettings
				layoutSystemInfo.settings = keepSettings;
			end

			-- Add layoutSystemInfo to keepSystems;
			table.insert(keepSystems, layoutSystemInfo);
		else
			-- This system no longer exists, so don't add it to keepSystems
			removedSomething = true;
		end
	end

	if removedSomething then
		-- Something was removed, so replace the systems table with keepSystems
		layoutInfo.systems = keepSystems;
	end

	return removedSomething;
end

-- This method handles adding any missing systems/settings to a saved layout data table
function EditModeManagerFrameMixin:AddNewSystemsAndSettings(layoutInfo)
	local addedSomething = false;

	-- Create a system/setting map to allow for efficient checking of each system & setting below
	local layoutSystemMap = {};
	for _, layoutSystemInfo in ipairs(layoutInfo.systems) do
		local settingMap = EditModeUtil:GetSettingMapFromSettings(layoutSystemInfo.settings);

		if layoutSystemInfo.systemIndex then
			if not layoutSystemMap[layoutSystemInfo.system] then
				layoutSystemMap[layoutSystemInfo.system] = {};
			end
			layoutSystemMap[layoutSystemInfo.system][layoutSystemInfo.systemIndex] = { settingMap = settingMap, settings = layoutSystemInfo.settings };
		else
			layoutSystemMap[layoutSystemInfo.system] = { settingMap = settingMap, settings = layoutSystemInfo.settings };
		end
	end

	-- Loop through all of the modern systems/setting and add any that don't exist in the saved layout data table
	for _, systemInfo in ipairs(self.modernSystems) do
		local existingSystem;
		if systemInfo.systemIndex then
			existingSystem = layoutSystemMap[systemInfo.system] and layoutSystemMap[systemInfo.system][systemInfo.systemIndex];
		else
			existingSystem = layoutSystemMap[systemInfo.system];
		end

		if not existingSystem then
			-- This system was newly added since this layout was saved so add it
			table.insert(layoutInfo.systems, CopyTable(systemInfo));
			addedSomething = true;
		else
			-- This system already existed, but we still need to check if any settings were added to it
			for _, settingInfo in ipairs(systemInfo.settings) do
				if not existingSystem.settingMap[settingInfo.setting] then
					-- This setting was newly added since this layout was saved so add it
					table.insert(existingSystem.settings, CopyTable(settingInfo));
					addedSomething = true;
				end
			end
		end
	end

	return addedSomething;
end

function EditModeManagerFrameMixin:ReconcileWithModern(layoutInfo)
	local removedSomething = self:RemoveOldSystemsAndSettings(layoutInfo);
	local addedSomething = self:AddNewSystemsAndSettings(layoutInfo);
	return removedSomething or addedSomething;
end

-- Sometimes new systems/settings may be added to (or removed from) EditMode. When that happens the saved layout data be will out of date
-- This method handles adding any missing systems/settings and removing any existing systems/settings from the saved layout data
function EditModeManagerFrameMixin:ReconcileLayoutsWithModern()
	local somethingChanged = false;
	for _, layoutInfo in ipairs(self.layoutInfo.layouts) do
		if self:ReconcileWithModern(layoutInfo) then
			somethingChanged = true;
		end
	end

	if somethingChanged then
		-- Something changed, so we need to send the updated edit mode info up to be saved on logout
		C_EditMode.SaveLayouts(self.layoutInfo);
	end
end

function EditModeManagerFrameMixin:UpdateAccountSettingMap()
	self.accountSettingMap = EditModeUtil:GetSettingMapFromSettings(self.accountSettings);
end

function EditModeManagerFrameMixin:GetAccountSettingValue(setting)
	return self.accountSettingMap[setting].value;
end

function EditModeManagerFrameMixin:GetAccountSettingValueBool(setting)
	return self:GetAccountSettingValue(setting) == 1;
end

function EditModeManagerFrameMixin:InitializeAccountSettings()
	self.accountSettings = C_EditMode.GetAccountSettings();
	self:UpdateAccountSettingMap();

	self:SetGridShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowGrid));
	self:SetGridSpacing(self:GetAccountSettingValue(Enum.EditModeAccountSetting.GridSpacing));
	self.AccountSettings:SetExpandedState(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.SettingsExpanded));
	self.AccountSettings:SetTargetAndFocusShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowTargetAndFocus));
	self.AccountSettings:SetActionBarShown(StanceBar, self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowStanceBar));
	self.AccountSettings:SetActionBarShown(PetActionBar, self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowPetActionBar));
	self.AccountSettings:SetActionBarShown(PossessActionBar, self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowPossessActionBar));
	self.AccountSettings:SetCastBarShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowCastBar));
	self.AccountSettings:SetEncounterBarShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowEncounterBar));
	self.AccountSettings:SetExtraAbilitiesShown(self:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowExtraAbilities));
end

function EditModeManagerFrameMixin:OnAccountSettingChanged(changedSetting, newValue)
	if type(newValue) == "boolean" then
		newValue = newValue and 1 or 0;
	end

	for _, settingInfo in pairs(self.accountSettings) do
		if settingInfo.setting == changedSetting then
			if settingInfo.value ~= newValue then
				settingInfo.value = newValue;
				self:UpdateAccountSettingMap();
				C_EditMode.SetAccountSetting(changedSetting, newValue);
			end
			return;
		end
	end
end

function EditModeManagerFrameMixin:UpdateLayoutCounts(savedLayouts)
	self.numLayouts = {
		[Enum.EditModeLayoutType.Account] = 0,
		[Enum.EditModeLayoutType.Character] = 0,
	};

	for _, layoutInfo in ipairs(savedLayouts) do
		self.numLayouts[layoutInfo.layoutType] = self.numLayouts[layoutInfo.layoutType] + 1;
	end
end

function EditModeManagerFrameMixin:AreLayoutsOfTypeMaxed(layoutType)
	return self.numLayouts[layoutType] >= Constants.EditModeConsts.EditModeMaxLayoutsPerType;
end

function EditModeManagerFrameMixin:AreLayoutsFullyMaxed()
	return self:AreLayoutsOfTypeMaxed(Enum.EditModeLayoutType.Account) and self:AreLayoutsOfTypeMaxed(Enum.EditModeLayoutType.Character);
end

function EditModeManagerFrameMixin:UpdateLayoutInfo(layoutInfo, reconcileLayouts)
	self.layoutInfo = layoutInfo;

	if reconcileLayouts then
		self:ReconcileLayoutsWithModern();
	end

	local savedLayouts = self.layoutInfo.layouts;
	self.layoutInfo.layouts = EditModePresetLayoutManager:GetCopyOfPresetLayouts();
	tAppendAll(self.layoutInfo.layouts, savedLayouts);

	self:UpdateLayoutCounts(savedLayouts);

	self:UpdateSystems();
	self:ClearActiveChangesFlags();

	if self:IsShown() then
		self:UpdateDropdownOptions();
	end
end

function EditModeManagerFrameMixin:SetGridShown(gridShown, isUserInput)
	self.Grid:SetShown(gridShown);
	self.GridSpacingSlider:SetEnabled(gridShown);

	if isUserInput then
		self:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowGrid, gridShown);
	else
		self.ShowGridCheckButton:SetControlChecked(gridShown);
	end
end

function EditModeManagerFrameMixin:SetGridSpacing(gridSpacing, isUserInput)
	self.Grid:SetGridSpacing(gridSpacing);
	self.GridSpacingSlider:SetupSlider(gridSpacing);

	if isUserInput then
		self:OnAccountSettingChanged(Enum.EditModeAccountSetting.GridSpacing, gridSpacing);
	end
end

local characterLayoutHeaderText = GetClassColoredTextForUnit("player", HUD_EDIT_MODE_CHARACTER_LAYOUTS_HEADER:format(UnitNameUnmodified("player")));

local function SortLayouts(a, b)
	if a.data.layoutType ~= b.data.layoutType then
		return a.data.layoutType > b.data.layoutType;
	end

	return a.value < b.value;
end

function EditModeManagerFrameMixin:UpdateDropdownOptions()
	self:ClearLockedLayoutButton();
	self.buttonEntryPool:ReleaseAll();
	self.layoutEntryPool:ReleaseAll();
	self.highestLayoutIndexByType = {};

	local options = {};

	local hasCharacterLayouts = false;
	for index, layoutInfo in ipairs(self.layoutInfo.layouts) do
		local dropdownText = (layoutInfo.layoutType == Enum.EditModeLayoutType.Preset) and HUD_EDIT_MODE_PRESET_LAYOUT:format(layoutInfo.layoutName) or layoutInfo.layoutName;

		table.insert(options, { value = index, selectedText = layoutInfo.layoutName, data = layoutInfo });

		if layoutInfo.layoutType == Enum.EditModeLayoutType.Character then
			hasCharacterLayouts = true;
		end

		if not self.highestLayoutIndexByType[layoutInfo.layoutType] or self.highestLayoutIndexByType[layoutInfo.layoutType] < index then
			self.highestLayoutIndexByType[layoutInfo.layoutType] = index;
		end
	end

	-- Sort the layouts: character-specific -> account -> preset
	table.sort(options, SortLayouts);

	-- Insert a divider between each section
	local lastLayoutType = nil;
	for index, optionInfo in ipairs(options) do
		if lastLayoutType and lastLayoutType ~= optionInfo.data.layoutType then
			table.insert(options, index, { isSeparator = true });
		end

		lastLayoutType = optionInfo.data.layoutType;
	end

	-- Insert a header before the character-specific layouts if there are any
	if hasCharacterLayouts then
		table.insert(options, 1, { value = "header", text = characterLayoutHeaderText });
	end

	-- Insert a divider and the New Layout, Import and Share buttons
	table.insert(options, { isSeparator = true });
	table.insert(options, { value = "newLayout" });
	table.insert(options, { value = "import" });
	table.insert(options, { value = "share" });

	-- Add the 2nd-level options (rename and copy)
	table.insert(options, { value = "copyLayout", text = HUD_EDIT_MODE_COPY_LAYOUT, level = 2 });
	table.insert(options, { value = "renameLayout", text = HUD_EDIT_MODE_RENAME_LAYOUT, level = 2 });

	-- And the 3rd-level options (copy to clipboard and post in chat)
	table.insert(options, { value = "copyToClipboard", text = HUD_EDIT_MODE_COPY_TO_CLIPBOARD, level = 3 });
	table.insert(options, { value = "postInChat", text = HUD_EDIT_MODE_POST_IN_CHAT, level = 3 });

	self.LayoutDropdown:SetOptions(options, self.layoutInfo.activeLayout);
end

function EditModeManagerFrameMixin:UpdateSystems()
	for _, systemFrame in ipairs(self.registeredSystemFrames) do
		local systemInfo = self:GetActiveLayoutSystemInfo(systemFrame.system, systemFrame.systemIndex);
		if systemInfo then
			systemFrame:UpdateSystem(systemInfo);
		end
	end

	self:UpdateRightAnchoredActionBarWidth();
	self:UpdateBottomAnchoredActionBarHeight();
	self:UpdateRightAnchoredActionBarScales();
end

function EditModeManagerFrameMixin:GetActiveLayoutInfo()
	return self.layoutInfo and self.layoutInfo.layouts[self.layoutInfo.activeLayout];
end

function EditModeManagerFrameMixin:GetActiveLayoutSystemInfo(system, systemIndex)
	local activeLayoutInfo = self:GetActiveLayoutInfo();
	if activeLayoutInfo then
		for _, systemInfo in ipairs(activeLayoutInfo.systems) do
			if systemInfo.system == system and systemInfo.systemIndex == systemIndex then
				return systemInfo;
			end
		end
	end
end

function EditModeManagerFrameMixin:IsActiveLayoutPreset()
	local activeLayoutInfo = self:GetActiveLayoutInfo();
	return activeLayoutInfo and activeLayoutInfo.layoutType == Enum.EditModeLayoutType.Preset;
end

function EditModeManagerFrameMixin:SelectLayout(layoutIndex)
	if layoutIndex ~= self.layoutInfo.activeLayout then
		self:ClearSelectedSystem();
		C_EditMode.SetActiveLayout(layoutIndex);
		self:NotifyChatOfLayoutChange();
	end
end

function EditModeManagerFrameMixin:MakeNewLayout(newLayoutInfo, layoutType, layoutName)
	if newLayoutInfo and layoutName and layoutName ~= "" then
		newLayoutInfo.layoutType = layoutType;
		newLayoutInfo.layoutName = layoutName;

		local newLayoutIndex;
		if self.highestLayoutIndexByType[layoutType] then
			newLayoutIndex = self.highestLayoutIndexByType[layoutType] + 1;
		elseif (layoutType == Enum.EditModeLayoutType.Character) and self.highestLayoutIndexByType[Enum.EditModeLayoutType.Account] then
			newLayoutIndex = self.highestLayoutIndexByType[Enum.EditModeLayoutType.Account] + 1;
		else
			newLayoutIndex = Enum.EditModePresetLayoutsMeta.NumValues + 1;
		end

		table.insert(self.layoutInfo.layouts, newLayoutIndex, newLayoutInfo);
		self:SaveLayouts();
		C_EditMode.OnLayoutAdded(newLayoutIndex);
	end
end

function EditModeManagerFrameMixin:DeleteLayout(layoutIndex)
	local deleteLayoutInfo = self.layoutInfo.layouts[layoutIndex];
	if deleteLayoutInfo and deleteLayoutInfo.layoutType ~= Enum.EditModeLayoutType.Preset then
		table.remove(self.layoutInfo.layouts, layoutIndex);
		self:SaveLayouts();
		C_EditMode.OnLayoutDeleted(layoutIndex);
	end
end

function EditModeManagerFrameMixin:RenameLayout(layoutIndex, layoutName)
	if layoutName ~= "" then
		local renameLayoutInfo = self.layoutInfo.layouts[layoutIndex];
		if renameLayoutInfo and renameLayoutInfo.layoutType ~= Enum.EditModeLayoutType.Preset then
			renameLayoutInfo.layoutName = layoutName;
			self:SaveLayouts();
			self:UpdateDropdownOptions();
		end
	end
end

function EditModeManagerFrameMixin:CopyActiveLayoutToClipboard()
	CloseDropDownMenus();
	local activeLayoutInfo = self:GetActiveLayoutInfo();
	CopyToClipboard(C_EditMode.ConvertLayoutInfoToString(activeLayoutInfo));
	DEFAULT_CHAT_FRAME:AddMessage(HUD_EDIT_MODE_COPY_TO_CLIPBOARD_NOTICE:format(activeLayoutInfo.layoutName), YELLOW_FONT_COLOR:GetRGB());
end

function EditModeManagerFrameMixin:LinkActiveLayoutToChat()
	CloseDropDownMenus();
	local hyperlink = C_EditMode.ConvertLayoutInfoToHyperlink(self:GetActiveLayoutInfo());
	if not ChatEdit_InsertLink(hyperlink) then
		ChatFrame_OpenChat(hyperlink);
	end
end

function EditModeManagerFrameMixin:ClearActiveChangesFlags()
	for _, systemFrame in ipairs(self.registeredSystemFrames) do
		systemFrame:SetHasActiveChanges(false);
	end
	self:SetHasActiveChanges(false);
end

function EditModeManagerFrameMixin:ImportLayout(newLayoutInfo, layoutType, layoutName)
	self:RevertAllChanges();
	self:MakeNewLayout(newLayoutInfo, layoutType, layoutName);
end

function EditModeManagerFrameMixin:SaveLayouts()
	C_EditMode.SaveLayouts(self.layoutInfo);
	self:ClearActiveChangesFlags();
end

function EditModeManagerFrameMixin:SaveLayoutChanges()
	if self:IsActiveLayoutPreset() then
		self:ShowNewLayoutDialog();
	else
		self:SaveLayouts();
	end
end

function EditModeManagerFrameMixin:RevertAllChanges()
	self:ClearSelectedSystem();
	self:UpdateLayoutInfo(C_EditMode.GetLayouts());
	UIParent_ManageFramePositions();
end

function EditModeManagerFrameMixin:ShowNewLayoutDialog(layoutData)
	CloseDropDownMenus();
	EditModeNewLayoutDialog:ShowDialog(layoutData or self:GetActiveLayoutInfo());
end

function EditModeManagerFrameMixin:ShowImportLayoutDialog()
	CloseDropDownMenus();
	EditModeImportLayoutDialog:ShowDialog();
end

function EditModeManagerFrameMixin:OpenAndShowImportLayoutLinkDialog(link)
	if not self:IsShown() then
		self:Show();
	end

	EditModeImportLayoutLinkDialog:ShowDialog(link);
end

function EditModeManagerFrameMixin:ShowRenameLayoutDialog(layoutButton)
	CloseDropDownMenus();

	local function onAcceptCallback(layoutName)
		self:RenameLayout(layoutButton.layoutIndex, layoutName);
	end

	local data = {text = HUD_EDIT_MODE_RENAME_LAYOUT_DIALOG_TITLE, text_arg1 = layoutButton.layoutData.layoutName, callback = onAcceptCallback, acceptText = SAVE }
	StaticPopup_ShowCustomGenericInputBox(data);
end

function EditModeManagerFrameMixin:ShowDeleteLayoutDialog(layoutButton)
	CloseDropDownMenus();

	local function onAcceptCallback()
		self:DeleteLayout(layoutButton.layoutIndex);
	end

	local data = {text = HUD_EDIT_MODE_DELETE_LAYOUT_DIALOG_TITLE, text_arg1 = layoutButton.layoutData.layoutName, callback = onAcceptCallback }
	StaticPopup_ShowCustomGenericConfirmation(data);
end

function EditModeManagerFrameMixin:ShowRevertWarningDialog(selectedLayoutIndex)
	EditModeUnsavedChangesDialog:ShowDialog(selectedLayoutIndex);
end

function EditModeManagerFrameMixin:ToggleSubDropdown(level, layoutButton)
	ToggleDropDownMenu(level, layoutButton.layoutIndex, self.LayoutDropdown.DropDownMenu, nil, nil, nil, nil, layoutButton.owningButton);

	if self.lockedLayoutButton then
		self.lockedLayoutButton = nil;
	else
		self.lockedLayoutButton = layoutButton;
	end
end

function EditModeManagerFrameMixin:ToggleRenameOrCopyLayoutDropdown(layoutButton)
	self:ToggleSubDropdown(2, layoutButton)
end

function EditModeManagerFrameMixin:ToggleShareDropdown(layoutButton)
	self:ToggleSubDropdown(3, layoutButton)
end

function EditModeManagerFrameMixin:ClearLockedLayoutButton(exemptLayoutButton)
	if self.lockedLayoutButton ~= exemptLayoutButton then
		self.lockedLayoutButton = nil;
		CloseDropDownMenus(2);
		CloseDropDownMenus(3);
	end
end

function EditModeManagerFrameMixin:IsLayoutButtonLocked(layoutButton)
	return self.lockedLayoutButton == layoutButton;
end

function EditModeManagerFrameMixin:AddRightActionBarToLayout(barToAdd)
	for i, bar in pairs(self.RightActionBarsInLayout) do
		if bar == barToAdd then
			return;
		end
	end

	table.insert(self.RightActionBarsInLayout, barToAdd);
	table.sort(self.RightActionBarsInLayout, LayoutIndexComparator);
	self:UpdateRightActionBarsLayout();
end

function EditModeManagerFrameMixin:RemoveRightActionBarFromLayout(barToRemove)
	for i, bar in pairs(self.RightActionBarsInLayout) do
		if bar == barToRemove then
			table.remove(self.RightActionBarsInLayout, i);
			table.sort(self.RightActionBarsInLayout, LayoutIndexComparator);
			self:UpdateRightActionBarsLayout();
			break;
		end
	end
end

function EditModeManagerFrameMixin:UpdateRightActionBarsLayout()
	local rightActionBarPadding = -5;
	local leftMostBar;

	for i, bar in pairs(self.RightActionBarsInLayout) do
		local offsetX = rightActionBarPadding;
		if leftMostBar then
			offsetX = offsetX + leftMostBar.systemInfo.anchorInfo.offsetX - leftMostBar:GetWidth();
		end

		bar:ClearAllPoints();
		bar:SetPoint("RIGHT", UIParent, "RIGHT", offsetX, -77);

		local isDefaultPosition = true;
		self:OnSystemPositionChange(bar, isDefaultPosition);

		leftMostBar = bar;
	end

	self:UpdateRightAnchoredActionBarWidth();
end

function EditModeManagerFrameMixin:TryShowUnsavedChangesGlow()
	if self:HasActiveChanges() then
		GlowEmitterFactory:Show(self.SaveChangesButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow);
		return true;
	end
end

function EditModeManagerFrameMixin:ClearUnsavedChangesGlow()
	GlowEmitterFactory:Hide(self.SaveChangesButton);
end

EditModeGridMixin = {}

function EditModeGridMixin:OnLoad()
	local function resetLine(pool, line)
		line:Hide();
		line:ClearAllPoints();
	end

	self.linePool = CreateObjectPool(
		function(pool)
			return self:CreateLine(nil, nil, "EditModeGridLineTemplate");
		end,

		resetLine
	);

	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function EditModeGridMixin:SetGridSpacing(spacing)
	self.gridSpacing = spacing;
	self:UpdateGrid();
end

function EditModeGridMixin:UpdateGrid()
	if not self:IsShown() then
		return;
	end

	self.linePool:ReleaseAll();

	local centerLine = true;
	local centerLineNo = false;
	local verticalLine = true;
	local verticalLineNo = false;

	local centerVerticalLine = self.linePool:Acquire();
	centerVerticalLine:SetupLine(centerLine, verticalLine, 0, 0);
	centerVerticalLine:Show();

	local centerHorizontalLine = self.linePool:Acquire();
	centerHorizontalLine:SetupLine(centerLine, verticalLineNo, 0, 0);
	centerHorizontalLine:Show();

	local halfNumVerticalLines = floor((self:GetWidth() / self.gridSpacing) / 2);
	local halfNumHorizontalLines = floor((self:GetHeight() / self.gridSpacing) / 2);

	for i = 1, halfNumVerticalLines do
		local xOffset = i * self.gridSpacing;

		local line = self.linePool:Acquire();
		line:SetupLine(centerLineNo, verticalLine, xOffset, 0);
		line:Show();

		line = self.linePool:Acquire();
		line:SetupLine(centerLineNo, verticalLine, -xOffset, 0);
		line:Show();
	end

	for i = 1, halfNumHorizontalLines do
		local yOffset = i * self.gridSpacing;

		local line = self.linePool:Acquire();
		line:SetupLine(centerLineNo, verticalLineNo, 0, yOffset);
		line:Show();

		line = self.linePool:Acquire();
		line:SetupLine(centerLineNo, verticalLineNo, 0, -yOffset);
		line:Show();
	end
end

EditModeGridSpacingSliderMixin = {};

function EditModeGridSpacingSliderMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.cbrHandles = EventUtil.CreateCallbackHandleContainer();
	self.cbrHandles:RegisterCallback(self.Slider, MinimalSliderWithSteppersMixin.Event.OnValueChanged, self.OnSliderValueChanged, self);

	self.formatters = {};
	self.formatters[MinimalSliderWithSteppersMixin.Label.Right] = CreateMinimalSliderFormatter(MinimalSliderWithSteppersMixin.Label.Right);
end

local minSpacing = Constants.EditModeConsts.EditModeMinGridSpacing;
local maxSpacing = Constants.EditModeConsts.EditModeMaxGridSpacing;
local spacingStepSize = 10;
local numSteps = (maxSpacing - minSpacing) / spacingStepSize;

function EditModeGridSpacingSliderMixin:SetupSlider(gridSpacing)
	self.Slider:Init(gridSpacing, minSpacing, maxSpacing, numSteps, self.formatters);
end

function EditModeGridSpacingSliderMixin:SetEnabled(enabled)
	self.Slider:SetEnabled_(enabled);
	self.Label:SetFontObject(enabled and GameFontHighlightMedium or GameFontDisableMed3);
end

function EditModeGridSpacingSliderMixin:OnSliderValueChanged(value)
	local isUserInput = true;
	EditModeManagerFrame:SetGridSpacing(value, isUserInput);
end

EditModeAccountSettingsMixin = {};

function EditModeAccountSettingsMixin:OnLoad()
	local function onTargetAndFocusCheckboxChecked(isChecked, isUserInput)
		self:SetTargetAndFocusShown(isChecked, isUserInput);
	end
	self.Settings.TargetAndFocus:SetCallback(onTargetAndFocusCheckboxChecked);

	local function onStanceBarCheckboxChecked(isChecked, isUserInput)
		self:SetActionBarShown(StanceBar, isChecked, isUserInput);
	end
	self.Settings.StanceBar:SetCallback(onStanceBarCheckboxChecked);

	local function onPetActionBarCheckboxChecked(isChecked, isUserInput)
		self:SetActionBarShown(PetActionBar, isChecked, isUserInput);
	end
	self.Settings.PetActionBar:SetCallback(onPetActionBarCheckboxChecked);

	local function onPossessActionBarCheckboxChecked(isChecked, isUserInput)
		self:SetActionBarShown(PossessActionBar, isChecked, isUserInput);
	end
	self.Settings.PossessActionBar:SetCallback(onPossessActionBarCheckboxChecked);

	local function onCastBarCheckboxChecked(isChecked, isUserInput)
		self:SetCastBarShown(isChecked, isUserInput);
	end
	self.Settings.CastBar:SetCallback(onCastBarCheckboxChecked);

	local function onEncounterBarCheckboxChecked(isChecked, isUserInput)
		self:SetEncounterBarShown(isChecked, isUserInput);
	end
	self.Settings.EncounterBar:SetCallback(onEncounterBarCheckboxChecked);

	local function onExtraAbilitiesCheckboxChecked(isChecked, isUserInput)
		self:SetExtraAbilitiesShown(isChecked, isUserInput);
	end
	self.Settings.ExtraAbilities:SetCallback(onExtraAbilitiesCheckboxChecked);
end

function EditModeAccountSettingsMixin:OnEditModeEnter()
	self.oldTargetName = UnitName("target");
	self.oldFocusName = UnitName("focus");
	self:RefreshTargetAndFocus();

	self.oldActionBarSettings = {};
	local function SetupActionBar(bar)
		self.oldActionBarSettings[bar] = {
			isShown = bar:IsShown();
			numShowingButtons = bar.numShowingButtons;
		}
		self:RefreshActionBarShown(bar);
	end
	SetupActionBar(StanceBar);
	SetupActionBar(PetActionBar);
	SetupActionBar(PossessActionBar);

	self:RefreshCastBar();
	self:RefreshEncounterBar();

	ExtraAbilityContainer.editModeEnterShown = ExtraAbilityContainer:IsShown();
	self:RefreshExtraAbilities();
end

function EditModeAccountSettingsMixin:OnEditModeExit()
	local clearSavedTargetAndFocus = true;
	self:ResetTargetAndFocus(clearSavedTargetAndFocus);
	self:ResetActionBarShown(StanceBar);
	self:ResetActionBarShown(PetActionBar);
	self:ResetActionBarShown(PossessActionBar);

	-- Undo encounter bar min size stuff so we don't have extra spacing in bottom managed container
	EncounterBar.minimumWidth = nil;
	EncounterBar.minimumHeight = nil;
	EncounterBar:Layout();
	UIParent_ManageFramePositions();

	ExtraAbilityContainer:SetShown(ExtraAbilityContainer.editModeEnterShown);
end

function EditModeAccountSettingsMixin:ResetTargetAndFocus(clearSavedTargetAndFocus)
	if self.oldTargetName then
		TargetUnit(self.oldTargetName);
	else
		ClearTarget();
	end

	if self.oldFocusName then
		FocusUnit(self.oldFocusName);
	else
		ClearFocus();
	end

	if clearSavedTargetAndFocus then
		self.oldTargetName = nil;
		self.oldFocusName = nil;
	end
end

function EditModeAccountSettingsMixin:RefreshTargetAndFocus()
	local showTargetAndFocus = self.Settings.TargetAndFocus:IsControlChecked();
	if showTargetAndFocus then
		if not TargetFrame:IsShown() then
			TargetUnit("player");
		end

		if not FocusFrame:IsShown() then
			FocusUnit("player");
		end
	else
		self:ResetTargetAndFocus();
	end
end

function EditModeAccountSettingsMixin:SetTargetAndFocusShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowTargetAndFocus, shown);
		self:RefreshTargetAndFocus();
	else
		self.Settings.TargetAndFocus:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:ResetActionBarShown(bar)
	bar.numShowingButtons = self.oldActionBarSettings[bar].numShowingButtons;
	bar:SetShowGrid(false, ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
	bar:SetShown(self.oldActionBarSettings[bar].isShown);
end

function EditModeAccountSettingsMixin:RefreshActionBarShown(bar)
	local barName = bar:GetName();
	local show = self.Settings[barName]:IsControlChecked();

	if show then
		if not bar:IsShown() then
			bar.numShowingButtons = bar.numButtons;
			bar:SetShowGrid(true, ACTION_BUTTON_SHOW_GRID_REASON_EVENT);
			bar:Show();
		end
	else
		self:ResetActionBarShown(bar);
	end

	if EditModeUtil:IsBottomAnchoredActionBar(bar) then
		EditModeManagerFrame:UpdateBottomAnchoredActionBarHeight();
	elseif EditModeUtil:IsRightAnchoredActionBar(bar) then
		EditModeManagerFrame:UpdateRightAnchoredActionBarWidth();
	end
end

function EditModeAccountSettingsMixin:SetActionBarShown(bar, shown, isUserInput)
	local barName = bar:GetName();
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting["Show"..barName], shown);
		self:RefreshActionBarShown(bar);
	else
		self.Settings[barName]:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:SetCastBarShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowCastBar, shown);
		self:RefreshCastBar();
	else
		self.Settings.CastBar:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshCastBar()
	local showCastBar = self.Settings.CastBar:IsControlChecked();
	PlayerCastingBarFrame:StopAnims();
	PlayerCastingBarFrame:SetAlpha(0);
	PlayerCastingBarFrame:SetShown(showCastBar);
	UIParent_ManageFramePositions();
end

function EditModeAccountSettingsMixin:SetEncounterBarShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowEncounterBar, shown);
		self:RefreshEncounterBar();
	else
		self.Settings.EncounterBar:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshEncounterBar()
	local showEncounterbar = self.Settings.EncounterBar:IsControlChecked();
	if showEncounterbar then
		EncounterBar.minimumWidth = 230;
		EncounterBar.minimumHeight = 30;

		EncounterBar:HighlightSystem();
	else
		EncounterBar.minimumWidth = nil;
		EncounterBar.minimumHeight = nil;

		EncounterBar:ClearHighlight();
	end

	EncounterBar:Layout();
	UIParent_ManageFramePositions();
end

function EditModeAccountSettingsMixin:SetExtraAbilitiesShown(shown, isUserInput)
	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowExtraAbilities, shown);
		self:RefreshExtraAbilities();
	else
		self.Settings.ExtraAbilities:SetControlChecked(shown);
	end
end

function EditModeAccountSettingsMixin:RefreshExtraAbilities()
	local showExtraAbilities = self.Settings.ExtraAbilities:IsControlChecked();
	if showExtraAbilities then
		ExtraAbilityContainer:Show();
		ExtraAbilityContainer:HighlightSystem();
	else
		ExtraAbilityContainer:SetShown(ExtraAbilityContainer.editModeEnterShown);
		ExtraAbilityContainer:ClearHighlight();
	end
end

function EditModeAccountSettingsMixin:SetExpandedState(expanded, isUserInput)
	self.expanded = expanded;
	self.Expander.Label:SetText(expanded and HUD_EDIT_MODE_COLLAPSE_OPTIONS or HUD_EDIT_MODE_EXPAND_OPTIONS);
	self.Settings:SetShown(self.expanded);
	EditModeManagerFrame:Layout();

	if isUserInput then
		EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.SettingsExpanded, expanded);
	end
end

function EditModeAccountSettingsMixin:ToggleExpandedState()
	local isUserInput = true;
	self:SetExpandedState(not self.expanded, isUserInput);
end