# goofy-hitboxe




    __                    __               ______           __         
   / /   __  __  _____   / /__   __  __   / ____/  _____   / /_   ____ 
  / /   / / / / / ___/  / //_/  / / / /  / __/    / ___/  / __ \ / __ \
 / /___/ /_/ / / /__   / ,<    / /_/ /  / /___   / /__   / / / // /_/ /
/_____/\__,_/  \___/  /_/|_|   \__, /  /_____/   \___/  /_/ /_/ \____/ 
                              /____/                                   


_____________________________________________________________________________________________________________________________________________________________________

    Example:
    
        local Module = require(ServerScriptService.Libaries.GoofyHitbox)

        local Hitbox = Module.CreateHitbox()
        Hitbox.Size = Vector3.new(3,3,3)
        Hitbox.CFrame = game.Workspace.HurtPart

        Hitbox.Touched:Connect(function(hit : Part, humanoid : Humanoid)
            humanoid.Health -= 10
            print(hit.Name.. " has touched the hurt part!")
        end)

        Hitbox.TouchEnded:Connect(function(part : Part)
            print(part.Name.. " has stopped touching the hitbox!")
        end)

        Hitbox:Start()

    
    Thanks for using this module, credit to SushiMaster for the idea and some code parts. Everything has been written by me, nothing was just copy and pasted.
    I made this because theirs was breaking for me, and in the discord server everyone said to just write my own, so I kind of fixed his and stuff. If you have
    any questions just DM me at @LuckyEcho on discord!
    
    @LuckyEcho
    7/27/2024 
    
_____________________________________________________________________________________________________________________________________________________________________

    
    [ GoofyHitbox Documentation]
    
        * local Module = require(GoofyHitbox)
        
            [ FUNCTIONS ]
        
        * Module.CreateHitbox()
				Description
					-- Creates a hitbox
	    
	    * Module.Stop()
				Description
					-- Stops the hitbox.
	    
	    * Module.Start()
				Description
					-- Starts the hitbox.
					
	    * Module.FindHitbox(key : String)
				Description
					-- Returns the hitbox with the specified key.
					
	    * Module.Destroy()
				Description
					-- Destroys the hitbox, only use this if you decided to have AutoDestroy set to false.
			
			[ EVENTS ]
			
		* HitboxInstance.Touched:Connect(hit : Part, humanoid : Humanoid)
		        Description
		            -- Fired when a humanoid touches the hitbox, returns information on them.
		        Arguments
		            -- Part Instance: Returns the part that touched the hitbox.
		            -- Humanoid Instance: Returns the humanoid that touched the hitbox.
		
		* HitboxInstance.TouchEnded:Connect(part : Part)
		        Description
		            -- Fired when a part that has touched the hitbox exits the hitbox.
		        Arguments
		            -- Part Instance: Returns the part has exited the hitbox.
		    
		    [ PROPERTIES ]
		    
		* HitboxObject.DetectAccessories : Boolean
		        Description
		            --- Should the hitboxes detect accessories on players?
		
		* HitboxObject.OverlapParams: OverlapParams
				Description
					--- OverlapParams object for the hitbox to use.

		* HitboxObject.Debug: boolean
				Description
					--- Turns on or off the debug hitbox part.

		* HitboxObject.CFrame: CFrame / Instance
				Description
					--- Sets the hitbox CFrame to the CFrame inserted.
					--- If its an instance, the hitbox will follow that instance's CFrame.
					
		* HitboxObject.Shape: Enum.PartType.Block / Enum.PartType.Ball
				Description
					--- Automatically set to Block.
					--- Sets the hitbox shape to the property.
					
		* HitboxObject.Size: Vector3 / number 
				Description
					--- Sets the size of the hitbox.
					--- Use a Vector3 if it's a block hitbox.
					--- Use a number if it's a ball hitbox.
					
		* HitboxObject.Offset: CFrame
				Description
					--- Hitbox offset from the main CFrame.

		* HitboxObject.DetectionMode: string | "Default" , "HitOnce" , "HitParts" , "ConstantDetection"
				Description
					--- Default value set to "Default".
					--- Changes on how the detection works.
					
		* HitboxObject.Key: String
				Description
					--- The key property for the find hitbox function.
					--- GoofyHitbox will automatically generate one for you, which you can find with Hitbox.Key, and you can find the Hitbox with :FindHitbox(key).
					
		* HitboxObject.AutoDestroy: boolean
				Description
					--- Automatically set to true.
					--- When set to true, :Stop() automatically destroys the hitbox.
					--- Does not destroy the hitbox when set to false. You'll 
						have to use :Destroy() to delete the hitbox.
			
			[ DETECTION MODES ]

		* Default
				Description
					--- Checks if a humanoid exists when this hitbox touches a part. The hitbox will not return humanoids it has already hit for the duration
					--- the hitbox has been active.

		* HitParts
				Description
					--- OnHit will return every hit part, regardless if it's ascendant has a humanoid or not.
					--- OnHit will no longer return a humanoid so you will have to check it every time.

		* HitOnce
				Description
					--- Hitbox will stop as soon as it detects a humanoid
					
		* ConstantDetection
				Description
					--- The default detection mode but no hitlist / debounce
					
					

