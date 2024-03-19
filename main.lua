PLUGIN = nil

function Initialize(Plugin)
	Plugin:SetName("JaggerKits")
	Plugin:SetVersion(1)
	PLUGIN = Plugin

	cPluginManager.BindCommand("/savekit", "jaggerkits.savekit", SaveKit, " ~ Save a kit");
	cPluginManager.BindCommand("/getkit", "jaggerkits.getkit", GetKit, " ~ Get a kit");
	cPluginManager.BindCommand("/getkitfresh", "jaggerkits.getkitfresh", GetKitAndClear, " ~ Get a kit and clear the inventory");

	LOG("Initialised JaggerKits." .. Plugin:GetVersion())
	return true
end

function ItemWithDataToString(cItem)
	return cItem.m_ItemType .. "|" .. cItem.m_ItemCount .. "|" .. cItem.m_ItemDamage .. "|" .. cItem.m_Enchantments:ToString()
end

function StringWithItemDataToItem(ItemString)
	local ItemSplit = StringSplit(ItemString, "|")

	local ItemType = tonumber(ItemSplit[1])
	local ItemCount = tonumber(ItemSplit[2])
	local ItemDamage = tonumber(ItemSplit[3])
	local ItemEnchantmentsString = ItemSplit[4]

	return cItem(ItemType, ItemCount, ItemDamage, ItemEnchantmentsString)
end

function SaveKit(Split, Player)

	if (#Split ~= 2) then
		Player:SendMessage("Usage: /savekit [kitname]")
		return true
	end

	local kitname = Split[2]
	local Inventory = cItems()
	local Helm
	local Chest
	local Legs
	local Boots

	Player:GetInventory():GetInventoryGrid():CopyToItems(Inventory)
	Player:GetInventory():GetHotbarGrid():CopyToItems(Inventory)

	Helm = ItemWithDataToString(Player:GetInventory():GetArmorGrid():GetSlot(0):CopyOne())
	Chest = ItemWithDataToString(Player:GetInventory():GetArmorGrid():GetSlot(1):CopyOne())
	Legs = ItemWithDataToString(Player:GetInventory():GetArmorGrid():GetSlot(2):CopyOne())
	Boots = ItemWithDataToString(Player:GetInventory():GetArmorGrid():GetSlot(3):CopyOne())

	inifile = cIniFile()
	inifile:ReadFile("Kits.ini", false)

	inifile:DeleteKey(kitname)
	inifile:AddKeyName(kitname)
	inifile:AddValue(kitname, "Helm", Helm)
	inifile:AddValue(kitname, "Chest", Chest)
	inifile:AddValue(kitname, "Legs", Legs)
	inifile:AddValue(kitname, "Boots", Boots)

	LOG(Inventory:Size())
	for i= 0, Inventory:Size()-1 do
		inifile:AddValue(kitname, "Item" .. i, ItemWithDataToString(Inventory:Get(i)))
	end

	inifile:WriteFile("Kits.ini")
	
	return true
end

function GetKit(Split, Player)

	if (#Split ~= 2) then
		Player:SendMessage("Usage: /getkit [kitname]")
		return true
	end

	local kitname = Split[2]
	inifile = cIniFile()
	inifile:ReadFile("Kits.ini", false)

	--Player:GetInventory():Clear()

	Player:GetInventory():SetArmorSlot(0, StringWithItemDataToItem(inifile:GetValue(kitname, "Helm")))
	Player:GetInventory():SetArmorSlot(1, StringWithItemDataToItem(inifile:GetValue(kitname, "Chest")))
	Player:GetInventory():SetArmorSlot(2, StringWithItemDataToItem(inifile:GetValue(kitname, "Legs")))
	Player:GetInventory():SetArmorSlot(3, StringWithItemDataToItem(inifile:GetValue(kitname, "Boots")))

	local i = 0
	while true do
		local itemstr = inifile:GetValue(kitname, "item" .. i)

		if itemstr == "" then break end

		local item = StringWithItemDataToItem(itemstr)
		
		Player:GetInventory():AddItem(item, true)
		i = i + 1
	end

	return true	
end

function GetKitAndClear(Split, Player)

	if (#Split ~= 2) then
		Player:SendMessage("Usage: /getkitandclear [kitname]")
		return true
	end

	Player:GetInventory():Clear()
	GetKit(Split, Player)


	return true	
end

function OnDisable()
	LOG("Shutting down JaggerKits." .. Plugin:GetVersion())
end
