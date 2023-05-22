local vehicle_sounds = {}

vehiclehandling = {}
enginespec = false
customturbo = {}
Citizen.CreateThread(function()
    Wait(0)
	while true do
		local vehicle = GetVehiclePedIsIn(PlayerPedId())
		if vehicle ~= 0 then
			local plate = GetVehicleNumberPlateText(vehicle)
			local veh = Entity(vehicle).state
			if veh and veh.turbo ~= nil then
				customturbo[plate] = veh.turbo
			end
			if customturbo[plate] then
				local turbo = Config.turbos[customturbo[plate]]
				local default = {fDriveInertia = GetVehicleHandlingFloat(vehicle , "CHandlingData","fDriveInertia"), fInitialDriveForce = GetVehicleHandlingFloat(vehicle , "CHandlingData","fInitialDriveForce")}
				ToggleVehicleMod(vehicle,18,true)
				EnableVehicleExhaustPops(vehicle, true)
				local basepower = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce")
				local boostlag = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia")
				local sound = false
				local soundofnitro = nil
				local customized = false
				local boost = 0
				local oldgear = 1
				local cd = 0
				local rpm = GetVehicleCurrentRpm(vehicle)
				local gear = GetVehicleCurrentGear(vehicle)
				local maxvol = 0.60
				local minvol = 0.20
				local ent = Entity(vehicle).state
				while customturbo[plate] ~= nil and customturbo[plate] ~= 'Default' do
					turbo = Config.turbos[customturbo[plate]]
					customturbo[plate] = veh.turbo
					while IsControlPressed(0, 71) do
						if turbo.Torque > boost then
							boost = boost + 0.01
						end
						cd = cd + 10
						rpm = GetVehicleCurrentRpm(vehicle)
						gear = GetVehicleCurrentGear(vehicle)
						SetVehicleTurboPressure(vehicle , boost + turbo.Power * rpm)
						if GetVehicleCurrentRpm(vehicle) >= turbo.Wastegate then

							local power = turbo.Power 
							if ent.nitroenable then
								power = power + ent.nitropower
							end
							SetVehicleCheatPowerIncrease(vehicle,power * GetVehicleTurboPressure(vehicle))
							SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", basepower + turbo.Power)
							SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", boostlag + turbo.Torque)
						end
						if not sound then
							--soundofnitro = PlaySoundFromEntity(GetSoundId(), "Flare", vehicle , "DLC_HEISTS_BIOLAB_FINALE_SOUNDS", 0, 0)
							sound = true
						end
						if sound and IsControlJustReleased(1, 71) or IsControlJustReleased(1, 71) and rpm > turbo.Wastegate and oldgear ~= gear then

							StopSound(soundofnitro)
							ReleaseSoundId(soundofnitro)
							sound = false
							local table = {
								['file'] = customturbo[plate],
								['volume'] = maxvol * (boost / (basepower+turbo.Power)),
								['coord'] = GetEntityCoords(PlayerPedId())
							}
							if GetVehicleTurboPressure(vehicle) >= turbo.Power and cd >= 1000 then
								--TriggerServerEvent('renzu_turbo:soundsync',table)
								cd = 0
							elseif GetVehicleCurrentRpm(vehicle) >= Config.ExhaustPopScale then
								TriggerServerEvent('renzu_turbo:soundsync',table)

								for k,v in pairs(Config.p_flame_location) do
									for i = 1, #v, 4 do 
										local myExhaustBone = GetEntityBoneIndexByName(vehicle, v)
										local myExhaustBonePos = GetEntityBonePosition_2(vehicle, myExhaustBone)
										local myExhaustBonePitch = GetEntityPhysicsHeading(myExhaustBone)
										local myExhaustBoneRot = GetEntityBoneRotation(vehicle, myExhaustBone)
										local p_large_flame = randomFloat(1.75, 2.50)
										local p_small_flame = randomFloat(0.875, 1.50)
										if myExhaustBone > 0 then
											local p_flame_particle_large = "veh_backfire"
											local p_flame_particle_large_ext = "veh_backfire"
											local p_flame_particle_small = "veh_sm_car_small_backfire"
											local p_flame_particle_small_ext = "veh_sm_car_small_backfire"
											local p_flame_particle_asset2 = "core"
											UseParticleFxAssetNextCall(p_flame_particle_asset2)
											bigFlameShoot = StartNetworkedParticleFxNonLoopedAtCoord(p_flame_particle_large, myExhaustBonePos.x, myExhaustBonePos.y-0.100, myExhaustBonePos.z, myExhaustBoneRot.x, myExhaustBoneRot.y, myExhaustBoneRot.z, p_large_flame, false, false, false)
											bigFlameExt = StartNetworkedParticleFxNonLoopedOnEntityBone(p_flame_particle_large_ext, vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, myExhaustBone, p_large_flame, false, false, false)
											StopParticleFxLooped(bigFlameShoot, 1)
											StopParticleFxLooped(bigFlameExt, 1)
											Wait(100)
											smallFlameShoot = StartNetworkedParticleFxNonLoopedAtCoord(p_flame_particle_small, myExhaustBonePos.x, myExhaustBonePos.y-0.100, myExhaustBonePos.z, myExhaustBoneRot.x, myExhaustBoneRot.y, myExhaustBoneRot.z, p_small_flame, false, false, false)
											smallFlameExt = StartNetworkedParticleFxNonLoopedOnEntityBone(p_flame_particle_small_ext, vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, myExhaustBone, p_small_flame, false, false, false)
											StopParticleFxLooped(smallFlameShoot, 1)
											StopParticleFxLooped(smallFlameExt, 1)
										end	
									end
								end
								cd = 0
							end
							SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", basepower)
							SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", boostlag)
							boost = 0
							oldgear = gear
						end
						Wait(1)
					end
					if sound and IsControlJustReleased(1, 71) or IsControlJustReleased(1, 71) and rpm > turbo.Wastegate and oldgear ~= gear then
						StopSound(soundofnitro)
						ReleaseSoundId(soundofnitro)
						sound = false
						local table = {
							['file'] = customturbo[plate],
							['volume'] = maxvol * (boost / (basepower+turbo.Power)),
							['coord'] = GetEntityCoords(PlayerPedId())
						}
						if GetVehicleTurboPressure(vehicle) >= turbo.Power and cd >= 1000 then
							--TriggerServerEvent('renzu_turbo:soundsync',table)
							cd = 0
						elseif rpm >= Config.ExhaustPopScale then
							TriggerServerEvent('renzu_turbo:soundsync',table)

							for k,v in pairs(Config.p_flame_location) do
								for i = 1, #v, 4 do 
									local myExhaustBone = GetEntityBoneIndexByName(vehicle, v)
									local myExhaustBonePos = GetEntityBonePosition_2(vehicle, myExhaustBone)
									local myExhaustBonePitch = GetEntityPhysicsHeading(myExhaustBone)
									local myExhaustBoneRot = GetEntityBoneRotation(vehicle, myExhaustBone)
									local p_large_flame = randomFloat(1.75, 2.50)
									local p_small_flame = randomFloat(0.875, 1.50)

									if myExhaustBone > 0 then
										local p_flame_particle_large = "veh_backfire"
										local p_flame_particle_large_ext = "veh_backfire"
										local p_flame_particle_small = "veh_sm_car_small_backfire"
										local p_flame_particle_small_ext = "veh_sm_car_small_backfire"
										local p_flame_particle_asset2 = "core"
										UseParticleFxAssetNextCall(p_flame_particle_asset2)
										bigFlameShoot = StartNetworkedParticleFxNonLoopedAtCoord(p_flame_particle_large, myExhaustBonePos.x, myExhaustBonePos.y-0.100, myExhaustBonePos.z, myExhaustBoneRot.x, myExhaustBoneRot.y, myExhaustBoneRot.z, p_large_flame, false, false, false)
										bigFlameExt = StartNetworkedParticleFxNonLoopedOnEntityBone(p_flame_particle_large_ext, vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, myExhaustBone, p_large_flame, false, false, false)
										StopParticleFxLooped(bigFlameShoot, 1)
										StopParticleFxLooped(bigFlameExt, 1)
										smallFlameShoot = StartNetworkedParticleFxNonLoopedAtCoord(p_flame_particle_small, myExhaustBonePos.x, myExhaustBonePos.y-0.100, myExhaustBonePos.z, myExhaustBoneRot.x, myExhaustBoneRot.y, myExhaustBoneRot.z, p_small_flame, false, false, false)
										smallFlameExt = StartNetworkedParticleFxNonLoopedOnEntityBone(p_flame_particle_small_ext, vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, myExhaustBone, p_small_flame, false, false, false)
										StopParticleFxLooped(smallFlameShoot, 1)
										StopParticleFxLooped(smallFlameExt, 1)
									end	
								end
							end
							cd = 0
						elseif rpm <=Config.ExhaustPopScale and rpm>=0.45 then
							local soundIndex    = math.random(1, #Config.popList)
   							local soundTable    = Config.popList[soundIndex]
					
							for k,v in pairs(Config.p_flame_location) do
								local pick = math.random(1,8)
								for i = pick, #v, 4 do 
									local myExhaustBone = GetEntityBoneIndexByName(vehicle, v)
									local myExhaustBonePos = GetEntityBonePosition_2(vehicle, myExhaustBone)
									local myExhaustBonePitch = GetEntityPhysicsHeading(myExhaustBone)
									local myExhaustBoneRot = GetEntityBoneRotation(vehicle, myExhaustBone)
									local p_large_flame = randomFloat(1.25, 1.75)
									local p_small_flame = randomFloat(0.875, 1.25)

									if myExhaustBone > 0 then
										local p_flame_particle_large = "veh_backfire"
										local p_flame_particle_small = "veh_sm_car_small_backfire"
										local p_flame_particle_asset2 = "core"
										if pick==1 then
											UseParticleFxAssetNextCall(p_flame_particle_asset2)
											bigFlame = StartNetworkedParticleFxNonLoopedOnEntityBone(p_flame_particle_large, vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, myExhaustBone, p_large_flame, false, false, false)
											StopParticleFxLooped(bigFlame, 1)
											smallFlame = StartNetworkedParticleFxNonLoopedOnEntityBone(p_flame_particle_small, vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, myExhaustBone, p_small_flame, false, false, false)
											StopParticleFxLooped(smallFlame, 1)
											PlaySoundFromEntity(-1, soundTable["Name"], vehicle, soundTable["Parent"], true, 0)
										else
											UseParticleFxAssetNextCall(p_flame_particle_asset2)
											bigFlame = StartNetworkedParticleFxNonLoopedOnEntityBone(p_flame_particle_large, vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, myExhaustBone, p_large_flame, false, false, false)
											StopParticleFxLooped(bigFlame, 1)
											Wait(100)
											smallFlame = StartNetworkedParticleFxNonLoopedOnEntityBone(p_flame_particle_small, vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, myExhaustBone, p_small_flame, false, false, false)
											StopParticleFxLooped(smallFlame, 1)
											PlaySoundFromEntity(-1, soundTable["Name"], vehicle, soundTable["Parent"], true, 0)
										end
									end	
								end
							end
							cd = 0
						end
						SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", basepower)
						SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", boostlag)
						boost = 0
						oldgear = gear
					end
					boost = 0
					vehicle = GetVehiclePedIsIn(PlayerPedId())
					if customturbo[plate] == 'Default' then
						break
					end
					turbo = Config.turbos[customturbo[plate]]
					if vehicle == 0 then
						break
					end
					Wait(500)
					Wait(7)
					customized = true
				end
				if customized then
					Wait(1000)
				end
			end
		end
		Wait(100)
	end
end)

function randomFloat(lower, greater)
    return lower + math.random()  * (greater - lower);
end

RegisterNetEvent('renzu_turbo:soundsync')
AddEventHandler('renzu_turbo:soundsync', function(table)
    local volume = table['volume']
	local mycoord = GetEntityCoords(PlayerPedId())
	local distIs  = tonumber(string.format("%.1f", #(mycoord - table['coord'])))
	if (distIs <= 30) then
		distPerc = distIs / 30
		volume = (1-distPerc) * table['volume']
		local table = {
			['file'] = table['file'],
			['volume'] = volume
		}
		SendNUIMessage({
			type = "playsound",
			content = table
		})
	end
	local vehicle = GetVehiclePedIsIn(PlayerPedId())
	local vehicleSpeed = GetEntitySpeed(vehicle)
	local soundIndex    = math.random(1, #Config.popList)
   	local soundTable    = Config.popList[soundIndex]
	for k,v in pairs(Config.p_flame_location) do
		local pick = math.random(1,4)
		local pic2 = math.random(4,32)
		for i = pick, #v, pic2 do 
			local myExhaustBone = GetEntityBoneIndexByName(vehicle, v)
			local myExhaustBonePos = GetEntityBonePosition_2(vehicle, myExhaustBone)
			local myExhaustBonePitch = GetEntityPhysicsHeading(myExhaustBone)
			local myExhaustBoneRot = GetEntityBoneRotation(vehicle, myExhaustBone)
			local p_large_flame = randomFloat(1.75, 2.50)
			local p_small_flame = randomFloat(0.875, 1.50)

			if myExhaustBone > 0 and vehicleSpeed > 35.76 then
				local p_flame_particle_large = "veh_backfire"
				local p_flame_particle_small = "veh_sm_car_small_backfire"
				local p_flame_particle_asset2 = "core"
				if pick==1 then 
					UseParticleFxAssetNextCall(p_flame_particle_asset2)
					bigFlame = StartNetworkedParticleFxNonLoopedOnEntityBone(p_flame_particle_large, vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, myExhaustBone, p_large_flame, false, false, false)
					smallFlame = StartNetworkedParticleFxNonLoopedOnEntityBone(p_flame_particle_small, vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, myExhaustBone, p_small_flame, false, false, false)
					PlaySoundFromEntity(-1, soundTable["Name"], vehicle, soundTable["Parent"], true, 0)
					StopParticleFxLooped(smallFlame, 1)
					StopParticleFxLooped(bigFlame, 1)
				else
					UseParticleFxAssetNextCall(p_flame_particle_asset2)
					bigFlame = StartNetworkedParticleFxNonLoopedOnEntityBone(p_flame_particle_large, vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, myExhaustBone, p_large_flame, false, false, false)
					smallFlame = StartNetworkedParticleFxNonLoopedOnEntityBone(p_flame_particle_small, vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, myExhaustBone, p_small_flame, false, false, false)
					PlaySoundFromEntity(-1, soundTable["Name"], vehicle, soundTable["Parent"], true, 0)
					Wait(250)
					StopParticleFxLooped(smallFlame, 1)
					StopParticleFxLooped(bigFlame, 1)
				end
				--Wait(1000)
			end	
		end
	end
					
end)

RegisterNetEvent('renzu_turbo:partRemoval')
AddEventHandler('renzu_turbo:partRemoval', function()

	local vehicle = GetVehiclePedIsIn(PlayerPedId())
	ToggleVehicleMod(vehicle,18,false)
	EnableVehicleExhaustPops(vehicle, false)
end)
