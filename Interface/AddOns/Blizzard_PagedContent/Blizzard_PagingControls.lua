--[[
	Generic pagination controls with left/right arrows and current/max page display.
	Can be used with a PagedContentFrame template or on its own.
]]

PagingControlsMixin = {}

function PagingControlsMixin:OnLoad()
	self.currentPage = 1;
	self.maxPages = 1;
	self:UpdateControls();

	if self.fontName then
		self.PageText:SetFontObject(self.fontName);
	end
	if self.fontColor then
		self.PageText:SetTextColor(self.fontColor:GetRGBA());
	end

	self.PrevPageButton:SetScript("OnClick", GenerateClosure(self.PreviousPage, self));
	self.NextPageButton:SetScript("OnClick", GenerateClosure(self.NextPage, self));
end

function PagingControlsMixin:GetMaxPages()
	return self.maxPages;
end

function PagingControlsMixin:SetMaxPages(maxPages)
	maxPages = math.max(maxPages, 1);
	if self.maxPages == maxPages then
		return;
	end
	self.maxPages = maxPages;
	if self.maxPages < self.currentPage then
		self:SetCurrentPage(self.maxPages);
	else
		self:UpdateControls();
	end
end

function PagingControlsMixin:GetCurrentPage()
	return self.currentPage;
end

function PagingControlsMixin:SetCurrentPage(page)
	page = Clamp(page, 1, self.maxPages);
	if self.currentPage == page then
		return;
	end

	self.currentPage = page;
	self:UpdateControls();

	local parent = self:GetParent();
	if parent and parent.OnPageChanged then
		parent:OnPageChanged();
	end
end

function PagingControlsMixin:NextPage()
	self:SetCurrentPage(self.currentPage + self:GetPageDelta());
end

function PagingControlsMixin:PreviousPage()
	self:SetCurrentPage(self.currentPage - self:GetPageDelta());
end

function PagingControlsMixin:GetPageDelta()
	local delta = 1;
	if self.canUseShiftKey and IsShiftKeyDown() then
		delta = 10;
	end
	if self.canUseControlKey and IsControlKeyDown() then
		delta = 100;
	end
	return delta;
end

function PagingControlsMixin:OnMouseWheel(delta)
	if delta > 0 then
		self:PreviousPage();
	else
		self:NextPage();
	end
end

function PagingControlsMixin:UpdateControls()
	self.PrevPageButton:SetEnabled(self.currentPage > 1);
	self.NextPageButton:SetEnabled(self.currentPage < self.maxPages);

	local shouldHideControls = self.hideWhenSinglePage and self.maxPages <= 1;
	-- Hide controls with alpha to avoid conflicting with any higher level hiding/showing done by our parent
	self:SetAlpha(shouldHideControls and 0 or 1);

	if not shouldHideControls then
		if self.displayMaxPages then
			self.PageText:SetFormattedText(self.currentPageWithMaxText, self.currentPage, self.maxPages);
		else
			self.PageText:SetFormattedText(self.currentPageOnlyText, self.currentPage);
		end
	end
end