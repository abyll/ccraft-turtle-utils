-- Armor/tools autocombiner
-- for CCraft 1.6 and OpenPeripherals
-- Uses a filing cabinet above, and any storage below.
chest = peripheral.wrap("top")
wasteThreshold = 1.20 -- If a repair puts hp over this ratio, don't bother.
turtle.select(1)
while true do
	-- Check all items in cabinet
	-- work with first item
	selected = chest.getStackInSlot(1)
	chest.pushItem("down", 1,1) -- take into turtle
	-- if it's already undamaged, just pass it on
	if selected.dmg <= 0 then
		print("Fully repaired")
		turtle.dropDown() -- continue
	else
		-- find the lowest health (highest dmg) item of same ID
		-- or, lowest health that will fully repair this.
		-- repaired health = (max-dmg1)+(max-dmg2) + floor(max/20)
		-- repaired damage = max - (health) = -max + dmg 1 + dmg 2 - repair bonus
		-- = 2*max - dmg1 - dmg2 + repairbonus
		-- if hp >= max  //  if dmg <= 0
		stacks = chest.getAllStacks()
		iFound = 0
		bestDmg = 0
		lowestDmg = 0
		iLowest = 0
		maxItemDmg = selected.maxdmg
		repair = math.floor(maxItemDmg/20)
		
		for i,item in pairs(stacks) do
			if item.id == selected.id then 
				if item.dmg < lowestDmg then -- check highest health, in case we can't fully repair.
					iLowest = i
					lowestDmg = item.dmg
				end
				
				-- repaired damage = max - (health) = -max + dmg 1 + dmg 2 - repair bonus
				if item.dmg > bestDmg and -maxItemDmg + selected.dmg + item.dmg - repair <= 0   then
					-- this can repair it fully. And it's more damaged than previous best, so less a waste.
					iFound = i
					bestDmg = item.dmg
				end
			end
		end
		
		-- Check if we found one that would fully repair. If there wasn't, then fall back to highest health (lowest dmg)
		-- if it does fully repair, it's the lowest health that would do so
		if iFound == 0 then 
			iFound = iLowest
			print("won't fully repair")
		end
		if iFound ~=0 then -- match found
			item = chest.getStackInSlot(iFound)
			-- Waste check: if it overheals by too much, don't bother and try to find something better.
			if  maxItemDmg*2 - selected.dmg - item.dmg < wasteThreshold * maxItemDmg then
				-- Craft the repair combination.
				print("Repairing")
				chest.pushItem("down", iFound,1)
				turtle.craft()
				turtle.dropUp()
			else -- Abort craft
				-- TODO: Perhaps we can go back and find a lower health that won't fully repair.
				-- TODO: For now, just try a new combo.
				print("too much waste")
				turtle.dropUp()
			end
			-- TODO: check if craft was successful
		else -- No other option found
			turtle.dropUp()
		end
    end
	sleep(1)
end