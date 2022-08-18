local PlayerInteractionManagerConstants =
{
	Tables =
	{
		{
			Name = "PlayerInteractionType",
			Type = "Enumeration",
			NumValues = 64,
			MinValue = 0,
			MaxValue = 63,
			Fields =
			{
				{ Name = "None", Type = "PlayerInteractionType", EnumValue = 0 },
				{ Name = "TradePartner", Type = "PlayerInteractionType", EnumValue = 1 },
				{ Name = "Item", Type = "PlayerInteractionType", EnumValue = 2 },
				{ Name = "Gossip", Type = "PlayerInteractionType", EnumValue = 3 },
				{ Name = "QuestGiver", Type = "PlayerInteractionType", EnumValue = 4 },
				{ Name = "Merchant", Type = "PlayerInteractionType", EnumValue = 5 },
				{ Name = "TaxiNode", Type = "PlayerInteractionType", EnumValue = 6 },
				{ Name = "Trainer", Type = "PlayerInteractionType", EnumValue = 7 },
				{ Name = "Banker", Type = "PlayerInteractionType", EnumValue = 8 },
				{ Name = "AlliedRaceDetailsGiver", Type = "PlayerInteractionType", EnumValue = 9 },
				{ Name = "GuildBanker", Type = "PlayerInteractionType", EnumValue = 10 },
				{ Name = "Registrar", Type = "PlayerInteractionType", EnumValue = 11 },
				{ Name = "Vendor", Type = "PlayerInteractionType", EnumValue = 12 },
				{ Name = "PetitionVendor", Type = "PlayerInteractionType", EnumValue = 13 },
				{ Name = "TabardVendor", Type = "PlayerInteractionType", EnumValue = 14 },
				{ Name = "TalentMaster", Type = "PlayerInteractionType", EnumValue = 15 },
				{ Name = "SpecializationMaster", Type = "PlayerInteractionType", EnumValue = 16 },
				{ Name = "MailInfo", Type = "PlayerInteractionType", EnumValue = 17 },
				{ Name = "SpiritHealer", Type = "PlayerInteractionType", EnumValue = 18 },
				{ Name = "AreaSpiritHealer", Type = "PlayerInteractionType", EnumValue = 19 },
				{ Name = "Binder", Type = "PlayerInteractionType", EnumValue = 20 },
				{ Name = "Auctioneer", Type = "PlayerInteractionType", EnumValue = 21 },
				{ Name = "StableMaster", Type = "PlayerInteractionType", EnumValue = 22 },
				{ Name = "BattleMaster", Type = "PlayerInteractionType", EnumValue = 23 },
				{ Name = "Transmogrifier", Type = "PlayerInteractionType", EnumValue = 24 },
				{ Name = "LFGDungeon", Type = "PlayerInteractionType", EnumValue = 25 },
				{ Name = "VoidStorageBanker", Type = "PlayerInteractionType", EnumValue = 26 },
				{ Name = "BlackMarketAuctioneer", Type = "PlayerInteractionType", EnumValue = 27 },
				{ Name = "AdventureMap", Type = "PlayerInteractionType", EnumValue = 28 },
				{ Name = "WorldMap", Type = "PlayerInteractionType", EnumValue = 29 },
				{ Name = "GarrArchitect", Type = "PlayerInteractionType", EnumValue = 30 },
				{ Name = "GarrTradeskill", Type = "PlayerInteractionType", EnumValue = 31 },
				{ Name = "GarrMission", Type = "PlayerInteractionType", EnumValue = 32 },
				{ Name = "ShipmentCrafter", Type = "PlayerInteractionType", EnumValue = 33 },
				{ Name = "GarrRecruitment", Type = "PlayerInteractionType", EnumValue = 34 },
				{ Name = "GarrTalent", Type = "PlayerInteractionType", EnumValue = 35 },
				{ Name = "Trophy", Type = "PlayerInteractionType", EnumValue = 36 },
				{ Name = "PlayerChoice", Type = "PlayerInteractionType", EnumValue = 37 },
				{ Name = "ArtifactForge", Type = "PlayerInteractionType", EnumValue = 38 },
				{ Name = "ObliterumForge", Type = "PlayerInteractionType", EnumValue = 39 },
				{ Name = "ScrappingMachine", Type = "PlayerInteractionType", EnumValue = 40 },
				{ Name = "ContributionCollector", Type = "PlayerInteractionType", EnumValue = 41 },
				{ Name = "AzeriteRespec", Type = "PlayerInteractionType", EnumValue = 42 },
				{ Name = "IslandQueue", Type = "PlayerInteractionType", EnumValue = 43 },
				{ Name = "ItemInteraction", Type = "PlayerInteractionType", EnumValue = 44 },
				{ Name = "ChromieTime", Type = "PlayerInteractionType", EnumValue = 45 },
				{ Name = "CovenantPreview", Type = "PlayerInteractionType", EnumValue = 46 },
				{ Name = "AnimaDiversion", Type = "PlayerInteractionType", EnumValue = 47 },
				{ Name = "LegendaryCrafting", Type = "PlayerInteractionType", EnumValue = 48 },
				{ Name = "WeeklyRewards", Type = "PlayerInteractionType", EnumValue = 49 },
				{ Name = "Soulbind", Type = "PlayerInteractionType", EnumValue = 50 },
				{ Name = "CovenantSanctum", Type = "PlayerInteractionType", EnumValue = 51 },
				{ Name = "NewPlayerGuide", Type = "PlayerInteractionType", EnumValue = 52 },
				{ Name = "ItemUpgrade", Type = "PlayerInteractionType", EnumValue = 53 },
				{ Name = "AdventureJournal", Type = "PlayerInteractionType", EnumValue = 54 },
				{ Name = "Renown", Type = "PlayerInteractionType", EnumValue = 55 },
				{ Name = "AzeriteForge", Type = "PlayerInteractionType", EnumValue = 56 },
				{ Name = "PerksProgramVendor", Type = "PlayerInteractionType", EnumValue = 57 },
				{ Name = "ProfessionsCraftingOrder", Type = "PlayerInteractionType", EnumValue = 58 },
				{ Name = "Professions", Type = "PlayerInteractionType", EnumValue = 59 },
				{ Name = "ProfessionsCustomerOrder", Type = "PlayerInteractionType", EnumValue = 60 },
				{ Name = "TraitSystem", Type = "PlayerInteractionType", EnumValue = 61 },
				{ Name = "BarbersChoice", Type = "PlayerInteractionType", EnumValue = 62 },
				{ Name = "JailersTowerBuffs", Type = "PlayerInteractionType", EnumValue = 63 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PlayerInteractionManagerConstants);