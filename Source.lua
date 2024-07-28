--[[


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
					
					

]]

-- [ SERVICES ]
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [ MODULES ]
local Signal = require(script.Signal)

-- [ VARIABLES ]
local goofy_hitbox = {}
goofy_hitbox.__index = goofy_hitbox

local adornments = {
    ["Shape"] = {
        [Enum.PartType.Ball] = "SphereHandleAdornment",
        [Enum.PartType.Block] = "BoxHandleAdornment",
    },
    ["Proportion"] = {
        [Enum.PartType.Ball] = "Radius",
        [Enum.PartType.Block] = "Size",
    },
}

local getCFrames = {
    ["Instance"] = function(point)
        return point.CFrame
    end,
    
    ["CFrame"] = function(point)
        return point
    end,
}

local spatial_query = {
    [Enum.PartType.Block] = function(self)
        local part_CFrame = getCFrames[typeof(self.CFrame)](self.CFrame) * self.Offset
        local parts = workspace:GetPartBoundsInBox(part_CFrame, self.Size, self.OverlapParams)
        
        return parts
    end,
    
    [Enum.PartType.Ball] = function(self)
        
        local part_CFrame = getCFrames[typeof(self.CFrame)](self.CFrame) * self.Offset
        local parts = workspace:GetPartBoundsInRadius(part_CFrame.Position, self.Size, self.OverlapParams)

        return parts
    end,
}

local hitboxes = {}

-- [ FUNCTIONS ]
function goofy_hitbox.CreateHitbox()
    local self = {
        Debug = true,
        AutoDestroy = true,
        Key = HttpService:GenerateGUID(false),
        
        Connection = nil,
        Box = nil,
        OverlapParams = OverlapParams.new(),
        
        Touched = Signal.new(),
        TouchEnded = Signal.new(),
        
        Hitlist = {},
        TouchingParts = {},
        Mode = "Default",
        DetectAccessories = false,
        
        Size = Vector3.new(0,0,0),
        Offset = CFrame.new(0,0,0),
        Shape = Enum.PartType.Block,
        CFrame = CFrame.new(0,0,0),    
    }
    setmetatable(self, goofy_hitbox) 
    return self
end

function goofy_hitbox:FindHitbox(key) 
    if hitboxes[key] then
        return hitboxes[key]
    end
end

function goofy_hitbox:_debug()
    if not self.Debug then return end
    
    -- Grab the point type and cframe.
    local point_Type = typeof(self.CFrame)
    local point_CFrame = getCFrames[point_Type](self.CFrame)
    
    if self.Box then
        -- If the debug block exists, then set it's CFrame.
        self.Box.CFrame = point_CFrame * self.Offset
    else
        -- Create a new debug block which is the same size and shape.
        self.Box = Instance.new(adornments.Shape[self.Shape])
        self.Box.Name = "HitboxDebug"
        self.Box.Adornee = workspace.Terrain
        self.Box[adornments.Proportion[self.Shape]] = self.Size
        self.Box.CFrame = point_CFrame * self.Offset
        self.Box.Color3 = Color3.fromRGB(255,0,0)
        self.Box.Transparency = 0.8
        self.Box.Parent = workspace.Terrain
    end
end

function goofy_hitbox:_find(a, b) : boolean
    for _, part2 in pairs(b) do
        if part2 == a then
            return true
        end
    end
  
    return false
end

function goofy_hitbox:_FindTouchEnded(parts)
    -- Check if there are any touching parts.
    if #self.TouchingParts == 0 then return end
    
    
    -- Check for parts that were lost.
    local lostParts = {}
    for _, part in pairs(self.TouchingParts) do
        if not self:_find(part, parts) then
            table.insert(lostParts, part)
            table.remove(self.TouchingParts, table.find(self.TouchingParts, part))
        end
    end
    
    -- Fire an event for all parts that stopped touching.
    for _, part in pairs(lostParts) do
        self.TouchEnded:Fire(part)
    end
end

function goofy_hitbox:_InsertParts(part)
    -- Check if part already exists in touching part.
    if table.find(self.TouchingParts, part) then return end
    
    -- Insert the part into the touching parts.
    table.insert(self.TouchingParts, part)
end

function goofy_hitbox:_cast()
    -- Find parts touching the hitbox.
    local parts = spatial_query[self.Shape](self)
    
    -- Check if any parts has left the box.
    self:_FindTouchEnded(parts)
    
    -- Loop through the parts
    for _, part : BasePart in pairs(parts) do
        if not self.DetectAccessories and part:FindFirstAncestorOfClass("Accessory") then continue end
        
        local character = part:FindFirstAncestorOfClass("Model") or part.Parent
        local humanoid : Humanoid = character:FindFirstChildOfClass("Humanoid")
        
        -- Check if player has been hit already.
        if self.Mode == "Default" and humanoid and not self.Hitlist[table.find(self.Hitlist, humanoid)] then
            -- Insert them into hit table.
            table.insert(self.Hitlist, humanoid)
            self:_InsertParts(part)
            
            -- Fire the touched event.
            self.Touched:Fire(part, humanoid)
        elseif self.Mode == "ConstantDetection" and humanoid then
            -- Insert the touching part.
            self:_InsertParts(part)
            
            -- Fire the touched event.
            self.Touched:Fire(part, humanoid)
        elseif self.Mode == "HitOnce" and humanoid then 
            -- Insert the touching part.
            self:_InsertParts(part)
            
            -- Fire the touched event.
            self.Touched:Fire(part, humanoid)
            self.TouchEnded:Fire(humanoid)
            
            -- Stop the hitbox.
            self:Stop()
            break
        elseif self.Mode == "HitParts" then
            -- Insert the touching part.
            self:_InsertParts(part)
           
            -- Send a touched event.
            self.Touched:Fire(part)
        end
    end
end

function goofy_hitbox:Start()
    -- Detect if there already is a hitbox with the same key.
    if hitboxes[self.Key] then
        error("Key "..self.Key.." is already being used for a Hitbox. Leave blank and the script will set one for you or change this key.")
    end
    
    -- Insert the hitbox into the keys.
    hitboxes[self.Key] = self
    
    -- Start looping for the hitbox
    task.spawn(function()
        self.Connection = RunService.Heartbeat:Connect(function()
            self:_debug()
            self:_cast()
        end)
    end)
end

function goofy_hitbox:_clear()
    -- Clear the hitlist.
    self.Hitlist = {}
    
    -- Disable the connection
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    
    -- Remove the debug box.
    if self.Box then
        self.Box:Destroy()
        self.Box = nil
    end
    
    -- Remove the key.
    if self.Key then
        hitboxes[self.Key] = nil
    end
end

function goofy_hitbox:Stop()
    -- Clear all data on the hitbox.
    self:_clear()
    
    -- Check if the hitbox should destroy itself.
    if not self.AutoDestroy then return end
    
    -- Disconnect all events.
    self.Touched:DisconnectAll()
    self.TouchEnded:DisconnectAll()
    setmetatable(self, nil)
end

function goofy_hitbox:Destroy()
    -- Clear all data on the hitbox.
    self:_clear()
    
    -- Disconnect all events.
    self.Touched:DisconnectAll()
    self.TouchEnded:DisconnectAll()
    setmetatable(self, nil)
end

-- [ RETURNING ]
return goofy_hitbox