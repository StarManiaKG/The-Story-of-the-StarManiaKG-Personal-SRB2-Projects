--// BASIC I/O SYSTEM DEMONSTRATION //--

--// STAR NOTE: this isn't mine by the way//--
--// just thought i'd add this here for future reference though, lol //-

addHook("PlayerSpawn", function(p)

	local savedata = io.openlocal("client/idlesave.txt", "r")

	if (savedata:read("*a") == nil)
		local makesave = io.openlocal("client/idlesave.txt", "w+")
		print("Creating save.")
		p.cookies = 0
		p.data = "00000000000000000"
		makesave:write(p.data)
		makesave:close()
		print("Save created.")
	end

	savedata:close()
	
	local savedata = io.openlocal("client/idlesave.txt", "r")

	if string.len(savedata:read("*a")) < 14
		print("Error: Savedata length less than required length. Save was likely tampered with.")
		p.cookies = 0
		p.data = "00000000000000000"
		p.loaded = true
	else
		p.data = savedata:read("*a")
		print("Save loaded.")
		print(p.data)
		print(string.sub(p.data, 0, 7))
		p.loaded = true
		p.cookies = string.sub(p.data, 0, 7)
	end
	
	savedata:close()
	
end)

addHook("PlayerThink", function(p)

	if p.loaded

		if (p.cmd.buttons & BT_CUSTOM1)
			print(p.data)
		end
		
		if (p.cmd.buttons & BT_CUSTOM2)
			local savedata = io.openlocal("client/idlesave.txt", "r")
			print(savedata:read("*a"))
			savedata:close()
		end
		
		if (string.len(tostring(p.cookies)) < 8)
			p.cookies = tostring("0" .. p.cookies)
		end
		
		if (string.len(tostring(p.cookies)) == 8)
			p.data = tostring(p.cookies) .. "000" .. "000"
		end
	
	end
	
end)

addHook("PlayerThink", function(p)

	if p.loaded

		if ((p.cmd.buttons & BT_CUSTOM3) and (not p.saving))
			local savedata = io.openlocal("client/idlesave.txt", "w+")
			p.saving = true
			savedata:write(p.data)
			savedata:close()
			p.saving = false
		end
	
	end

end)