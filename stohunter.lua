-- ==========================================
-- TUẤN THỢ SĂN - ULTIMATE VIP HUB (BẢN FIX LỖI)
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Dọn file key cũ
if isfolder(".") then
    for _, file in ipairs(listfiles(".")) do
        if file:find("TuansKeySystem") then pcall(function() delfile(file) end) end
    end
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- GIAO DIỆN (UI)
-- ==========================================
local Window = Rayfield:CreateWindow({
   Name = "Tuấn Thợ Săn - Ultimate VIP",
   LoadingTitle = "Đang tải hệ thống...",
   LoadingSubtitle = "Đã fix lỗi hiển thị",
   ConfigurationSaving = { Enabled = false },
   KeySystem = true, 
   KeySettings = {
      Title = "Nhập Key",
      Subtitle = "Muốn lấy key thì phải khen bố",
      Note = "Key này đ có save đâu nha mấy em",
      FileName = "TuansKeySystem",
      SaveKey = false, 
      GrabKeyFromSite = true,
      Key = {"https://pastebin.com/raw/Byp17dHK"}
   }
})

local MainTab = Window:CreateTab("🛒 Chức năng chính", 4483362458) 
local PickupTab = Window:CreateTab("🧲 Auto Lụm Đồ", 4483362458) 

-- Biến logic
local autoBid = false
local autoTeleportAfterWin = false
local bypassEnabled = false
local auraEnabled = false
local auraRadius = 30
local isWeightExceeded = false

-- Monitor Weight
ReplicatedStorage:WaitForChild("Events"):WaitForChild("UI"):WaitForChild("VehicleWeightUpdate").OnClientEvent:Connect(function(cur, max) isWeightExceeded = (cur > max) end)

-- ==========================================
-- AUTO BID
-- ==========================================
MainTab:CreateSection("Đấu Giá")
MainTab:CreateToggle({Name = "Bật Auto Bid", CurrentValue = false, Callback = function(V) autoBid = V if autoBid then task.spawn(function() while autoBid do pcall(function() ReplicatedStorage.Events.Auction.Bid:FireServer() end) task.wait(0.7) end end) end end})
MainTab:CreateToggle({Name = "🚀 Bay vô kho sau khi thắng", CurrentValue = false, Callback = function(V) autoTeleportAfterWin = V end})

-- Logic xử lý kho
ReplicatedStorage:WaitForChild("Events"):WaitForChild("Auction"):WaitForChild("AuctionPickupStart").OnClientEvent:Connect(function()
    if autoTeleportAfterWin then
        task.wait(0.5)
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local savedPos = hrp.CFrame
        local prompts, totalPos = {}, Vector3.zero
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                table.insert(prompts, obj)
                local part = obj.Parent
                if part and part:IsA("BasePart") then totalPos = totalPos + part.Position end
            end
        end
        
        if #prompts > 0 then
            hrp.CFrame = CFrame.new((totalPos / #prompts) + Vector3.new(0, 3, 0)) 
            if auraEnabled then
                task.wait(0.5)
                local clean = false
                while not clean and not isWeightExceeded do
                    local looted = 0
                    for _, p in ipairs(prompts) do
                        if isWeightExceeded then break end
                        if p and p.Parent then
                            local part = p.Parent
                            local pos = part:IsA("BasePart") and part.Position or (part:IsA("Model") and part.PrimaryPart and part.PrimaryPart.Position)
                            if pos and (pos - hrp.Position).Magnitude <= auraRadius then
                                pcall(function() fireproximityprompt(p) end)
                                looted = looted + 1
                            end
                        end
                    end
                    if looted == 0 then clean = true else task.wait(0.3) end
                end
            end
            task.wait(0.5)
            hrp.CFrame = savedPos
        end
    end
end)

-- ==========================================
-- AUTO LỤM ĐỒ
-- ==========================================
PickupTab:CreateSection("Cấu hình Aura")
PickupTab:CreateToggle({Name = "🧲 Kích hoạt Aura dọn kho", CurrentValue = false, Callback = function(V) auraEnabled = V end})
PickupTab:CreateSlider({Name = "Bán kính hút (Studs)", Range = {5, 100}, Increment = 5, CurrentValue = 30, Callback = function(V) auraRadius = V end})
PickupTab:CreateToggle({Name = "Bật Lụm Nhanh (Bypass)", CurrentValue = false, Callback = function(V) bypassEnabled = V for _,p in pairs(workspace:GetDescendants()) do if p:IsA("ProximityPrompt") then p.HoldDuration = V and 0 or (p:GetAttribute("OriginalDuration") or 1) end end end})

Rayfield:Notify({Title = "Tuấn Thợ Săn", Content = "Menu đã sẵn sàng!", Duration = 5})
-- TAB 1: CHỨC NĂNG CHÍNH (ĐẤU GIÁ & BẢN ĐỒ)
-- ==========================================
MainTab:CreateSection("Auto Đấu Giá & Kho")

MainTab:CreateToggle({
    Name = "Bật Auto Bid (Đấu Giá)", 
    CurrentValue = false, 
    Flag = "Toggle_AutoBid", 
    Callback = function(Value) 
        autoBid = Value 
        if autoBid then 
            task.spawn(function() 
                local BidEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Auction"):WaitForChild("Bid") 
                while autoBid do pcall(function() BidEvent:FireServer() end) task.wait(bidSpeed) end 
            end) 
        end 
    end
})

MainTab:CreateDropdown({
    Name = "Tốc độ Bid (Cooldown)", 
    Options = {"Normal (0.7s)", "Fast (0.3s)", "The Flash (0.1s)"}, 
    CurrentOption = {"Normal (0.7s)"}, 
    MultipleOptions = false, 
    Flag = "Dropdown_BidSpeed", 
    Callback = function(Option) 
        local choice = Option[1] 
        if choice == "Normal (0.7s)" then bidSpeed = 0.7 elseif choice == "Fast (0.3s)" then bidSpeed = 0.3 elseif choice == "The Flash (0.1s)" then bidSpeed = 0.1 end 
    end
})

MainTab:CreateToggle({
   Name = "🚀 Tự động bay vô kho sau khi Bid xong",
   CurrentValue = false,
   Flag = "Toggle_TeleVaoKho",
   Callback = function(Value) autoTeleportAfterWin = Value end,
})

-- Chuỗi hành động tự động khi thắng đấu giá (Dynamic Scan Loop cho đến khi Clean)
local PickupEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Auction"):WaitForChild("AuctionPickupStart")
PickupEvent.OnClientEvent:Connect(function()
    if autoTeleportAfterWin then
        task.wait(0.5)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local savedOriginalPosition = hrp.CFrame
        local closestItem = nil
        local shortestDistance = math.huge
        local cachedPrompts = {}
        
        for _, prompt in pairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                table.insert(cachedPrompts, prompt)
                local itemPart = prompt.Parent
                if itemPart and itemPart:IsA("BasePart") then
                    local distance = (itemPart.Position - hrp.Position).Magnitude
                    if distance < shortestDistance then 
                        shortestDistance = distance 
                        closestItem = itemPart 
                    end
                end
            end
        end
        
        if closestItem then
            hrp.CFrame = CFrame.new(closestItem.Position + Vector3.new(0, 3, 0)) 
            Rayfield:Notify({Title = "Đột nhập", Content = "Đã vào kho thành công!", Duration = 1.5})
            
            isWeightExceeded = false
            
            if auraEnabled then
                task.wait(0.5)
                local clean = false
                local safeguard = 0
                
                -- Vòng lặp Scan liên tục cho đến khi hoàn toàn sạch (clean) hoặc kho đầy
                while not clean and safeguard < 20 and not isWeightExceeded do
                    safeguard = safeguard + 1
                    local itemsProcessed = 0
                    
                    for _, prompt in ipairs(cachedPrompts) do
                        if isWeightExceeded then break end
                        
                        if prompt and prompt.Parent then
                            local itemPart = prompt.Parent
                            if itemPart and itemPart.Parent then
                                local itemPos = itemPart:IsA("BasePart") and itemPart.Position or (itemPart:IsA("Model") and itemPart.PrimaryPart and itemPart.PrimaryPart.Position)
                                
                                if itemPos then
                                    local dist = (itemPos - hrp.Position).Magnitude
                                    if dist <= auraRadius then
                                        pcall(function() fireproximityprompt(prompt) end)
                                        itemsProcessed = itemsProcessed + 1
                                    end
                                end
                            end
                        end
                    end
                    
                    -- Nếu vòng quét này không tìm/xử lý thêm được món nào nữa -> Đã Clean!
                    if itemsProcessed == 0 then
                        clean = true
                    else
                        task.wait(0.3) -- Nghỉ ngắn trước khi sang lượt scan tiếp theo
                    end
                end
                
                if isWeightExceeded then
                    Rayfield:Notify({Title = "Kho đầy!", Content = "Đã đạt giới hạn cân nặng, dừng lụm!", Duration = 2})
                else
                    Rayfield:Notify({Title = "Thu hoạch", Content = "Đã dọn sạch kho hoàn toàn (Clean)!", Duration = 1.5})
                end
            end
            
            task.wait(0.5)
            hrp.CFrame = savedOriginalPosition
            Rayfield:Notify({Title = "Trở về", Content = "Đã bay về vị trí đấu giá!", Duration = 2})
        end
    end
end)

MainTab:CreateSection("Khu vực Cá nhân")
MainTab:CreateButton({Name = "🏠 Dịch chuyển về: " .. LocalPlayer.Name .. " House", Callback = function()
   local found = false
   pcall(function()
       local result = ReplicatedStorage.Events.GPS.GetPOIs:InvokeServer()
       for _, poi in ipairs(result.pois) do
           if poi.ownerUserId == LocalPlayer.UserId then
               LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(poi.position + Vector3.new(0, 3, 0))
               Rayfield:Notify({Title = "Thành công!", Content = "Đã về nhà: " .. LocalPlayer.Name, Duration = 2})
               found = true break
           end
       end
   end)
   if not found then Rayfield:Notify({Title = "Lỗi", Content = "Không tìm thấy nhà của bạn trong Server!", Duration = 3}) end
end})

MainTab:CreateSection("Bản đồ (Bấm nút bay nhiều lần thoải mái)")
local selectedFav = ""
local favoriteLocations = {}

MainTab:CreateDropdown({
   Name = "1. CHỌN ĐỊA ĐIỂM (Ở ĐÂY)",
   Options = DropdownOptions,
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "Dropdown_Teleport",
   Callback = function(Option) selectedFav = Option[1] end,
})

MainTab:CreateButton({
   Name = "🚀 2. DỊCH CHUYỂN ĐẾN NƠI ĐÃ CHỌN",
   Callback = function()
       if selectedFav == "" then Rayfield:Notify({Title = "Thông báo", Content = "Vui lòng chọn địa điểm trước!", Duration = 2}) return end
       local engKey = NameToEnglishKey[selectedFav]
       local targetVector = LocationList[engKey]
       if targetVector then
           local char = LocalPlayer.Character
           if char and char:FindFirstChild("HumanoidRootPart") then
               char.HumanoidRootPart.CFrame = CFrame.new(targetVector + Vector3.new(0, 3, 0))
               Rayfield:Notify({Title = "Thành công!", Content = "Đã bay đến: " .. selectedFav, Duration = 2})
           end
       end
   end,
})

MainTab:CreateButton({
   Name = "⭐ Thêm / Bỏ Yêu Thích Địa Điểm Này",
   Callback = function()
       if selectedFav == "" then return end
       local idx = table.find(favoriteLocations, selectedFav)
       if idx then
           table.remove(favoriteLocations, idx) Rayfield:Notify({Title = "Yêu thích", Content = "Đã XÓA", Duration = 2})
       else
           table.insert(favoriteLocations, selectedFav) Rayfield:Notify({Title = "Yêu thích", Content = "Đã THÊM", Duration = 2})
       end
   end,
})

MainTab:CreateSection("Danh sách Yêu thích")
local selectedFavTeleport = ""
local FavDropdown = MainTab:CreateDropdown({
   Name = "⭐ Chọn mục yêu thích", Options = {"Chưa có mục yêu thích"}, CurrentOption = {""}, MultipleOptions = false, Flag = "Dropdown_Favorites", Callback = function(Option) selectedFavTeleport = Option[1] end,
})

MainTab:CreateButton({
   Name = "🚀 DỊCH CHUYỂN (MỤC YÊU THÍCH)",
   Callback = function()
       if selectedFavTeleport == "" or selectedFavTeleport == "Chưa có mục yêu thích" then return end
       local targetVector = LocationList[NameToEnglishKey[selectedFavTeleport]]
       if targetVector then LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetVector + Vector3.new(0, 3, 0)) end
   end,
})

MainTab:CreateButton({
   Name = "🔄 Làm mới danh sách Yêu Thích",
   Callback = function()
       if #favoriteLocations > 0 then FavDropdown:Refresh(favoriteLocations, true) else FavDropdown:Refresh({"Chưa có mục yêu thích"}, true) end
   end,
})

-- ==========================================
-- TAB 2: AUTO LỤM ĐỒ (PICKUP & AURA)
-- ==========================================
PickupTab:CreateSection("Tùy chỉnh Lụm Đồ")

local function bypassPrompt(prompt)
    if prompt:IsA("ProximityPrompt") then
        if not prompt:GetAttribute("OriginalDuration") then prompt:SetAttribute("OriginalDuration", prompt.HoldDuration) end
        if bypassEnabled then prompt.HoldDuration = 0 else prompt.HoldDuration = prompt:GetAttribute("OriginalDuration") or 1 end
    end
end

PickupTab:CreateToggle({
   Name = "Bật Lụm Nhanh (Chạm 1 cái là lụm, ko cần đè)",
   CurrentValue = false,
   Flag = "Toggle_BypassHold",
   Callback = function(Value)
       bypassEnabled = Value
       for _, v in pairs(workspace:GetDescendants()) do bypassPrompt(v) end
   end,
})

workspace.DescendantAdded:Connect(function(v)
    if bypassEnabled then task.spawn(function() task.wait(0.1) bypassPrompt(v) end) end
end)

PickupTab:CreateSection("Aura Nhặt Đồ Thông Minh")

PickupTab:CreateToggle({
   Name = "🧲 Kích hoạt Aura dọn kho (Scan liên tục đến khi Clean)",
   CurrentValue = false,
   Flag = "Toggle_Aura",
   Callback = function(Value) 
       auraEnabled = Value 
   end,
})

PickupTab:CreateSlider({
   Name = "Bán kính hút đồ (Radius)", Range = {5, 50}, Increment = 1, Suffix = "Studs", CurrentValue = 15, Flag = "Slider_AuraRadius",
   Callback = function(Value) auraRadius = Value end,
})

-- ==========================================
-- TAB 3: NHÂN VẬT & NGƯỜI CHƠI
-- ==========================================
PlayerTab:CreateSection("Tùy chỉnh Nhân vật")
local walkSpeedEnabled = false
local walkSpeedValue = 16
PlayerTab:CreateToggle({Name = "Bật Chạy Nhanh", CurrentValue = false, Flag = "Toggle_Speed", Callback = function(Value) walkSpeedEnabled = Value end})
PlayerTab:CreateSlider({Name = "Điều chỉnh Tốc độ chạy", Range = {16, 300}, Increment = 1, Suffix = "Speed", CurrentValue = 50, Flag = "Slider_Speed", Callback = function(Value) walkSpeedValue = Value end})
RunService.RenderStepped:Connect(function() if walkSpeedEnabled then local char = LocalPlayer.Character local hum = char and char:FindFirstChild("Humanoid") if hum then hum.WalkSpeed = walkSpeedValue end end end)

local flyEnabled = false
local flySpeed = 50
PlayerTab:CreateToggle({Name = "Bật Bay (Fly - Dùng WASD + Space)", CurrentValue = false, Flag = "Toggle_Fly", Callback = function(Value) flyEnabled = Value end})
PlayerTab:CreateSlider({Name = "Điều chỉnh Tốc độ Bay", Range = {20, 500}, Increment = 1, Suffix = "Fly Speed", CurrentValue = 50, Flag = "Slider_FlySpeed", Callback = function(Value) flySpeed = Value end})
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character local hrp = char and char:FindFirstChild("HumanoidRootPart") local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    if flyEnabled then
        if not hrp:FindFirstChild("FlyVelocity") then
            local bv = Instance.new("BodyVelocity") bv.Name = "FlyVelocity" bv.MaxForce = Vector3.new(9e9, 9e9, 9e9) bv.Velocity = Vector3.zero bv.Parent = hrp
            local bg = Instance.new("BodyGyro") bg.Name = "FlyGyro" bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9) bg.P = 9e4 bg.CFrame = hrp.CFrame bg.Parent = hrp
            hum.PlatformStand = true
        end
        local bv = hrp:FindFirstChild("FlyVelocity") local bg = hrp:FindFirstChild("FlyGyro") local cam = workspace.CurrentCamera
        if bv and bg and cam then
            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            bv.Velocity = moveDir * flySpeed bg.CFrame = cam.CFrame
        end
    else
        if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
        if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
        if hum then hum.PlatformStand = false end
    end
end)

PlayerTab:CreateSection("Người chơi trong Server")
local selectedPlayer = ""
local PlayerDropdown = PlayerTab:CreateDropdown({Name = "1. CHỌN NGƯỜI CHƠI", Options = {"Chưa tải danh sách..."}, CurrentOption = {""}, MultipleOptions = false, Flag = "Dropdown_TeleportPlayer", Callback = function(Option) selectedPlayer = Option[1] end})
PlayerTab:CreateButton({Name = "🚀 2. DỊCH CHUYỂN TỚI NGƯỜI NÀY", Callback = function()
   if selectedPlayer == "" or selectedPlayer == "Chưa tải danh sách..." then return end
   local targetPlayer = Players:FindFirstChild(selectedPlayer)
   if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame end
end})
PlayerTab:CreateButton({Name = "🔄 Làm mới danh sách Người chơi", Callback = function()
   local pList = {} for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(pList, p.Name) end end
   if #pList > 0 then PlayerDropdown:Refresh(pList, true) else Rayfield:Notify({Title = "Thông báo", Content = "Bạn đang ở một mình trong Server!", Duration = 2}) end
end})

-- ==========================================
-- TAB 4: QUẢN LÝ CẤU HÌNH (CONFIG SYSTEM)
-- ==========================================
ConfigTab:CreateSection("Quản lý File Config")

if not isfolder("UltimateFarmHub") then makefolder("UltimateFarmHub") end
if not isfolder("UltimateFarmHub/Autoload") then makefolder("UltimateFarmHub/Autoload") end

local configFileName = "my_config"
ConfigTab:CreateInput({Name = "Đặt tên Config", PlaceholderText = "Nhập tên file...", RemoveTextAfterFocusLost = false, Flag = "Input_ConfigName", Callback = function(Text) if Text ~= "" then configFileName = Text end end})

local function getConfigFiles()
    local files = {}
    if isfolder("UltimateFarmHub") then for _, file in ipairs(listfiles("UltimateFarmHub")) do local name = file:match("([^/]+)$") name = name:match("(.+)%..+$") or name if name ~= "Autoload" then table.insert(files, name) end end end
    if #files == 0 then table.insert(files, "Trống") end return files
end

local selectedConfigToLoad = ""
local ConfigDropdown = ConfigTab:CreateDropdown({Name = "Chọn File Config có sẵn", Options = getConfigFiles(), CurrentOption = {"Trống"}, MultipleOptions = false, Flag = "Dropdown_Configs", Callback = function(Option) selectedConfigToLoad = Option[1] end})
ConfigTab:CreateButton({Name = "🔄 Làm mới danh sách File", Callback = function() ConfigDropdown:Refresh(getConfigFiles(), true) end})
ConfigTab:CreateButton({Name = "➕ Tạo Config Mới", Callback = function()
   local path = "UltimateFarmHub/" .. configFileName .. ".json"
   if isfile(path) then Rayfield:Notify({Title = "Lỗi", Content = "File này đã tồn tại!", Duration = 3}) else
       local data = {Favorites = favoriteLocations, Speed = walkSpeedValue, FlySpeed = flySpeed}
       writefile(path, HttpService:JSONEncode(data)) Rayfield:Notify({Title = "Thành công", Content = "Đã tạo config", Duration = 2}) ConfigDropdown:Refresh(getConfigFiles(), true)
   end
end})
ConfigTab:CreateButton({Name = "💾 Ghi Đè (Đè dữ liệu vào file đang chọn)", Callback = function()
   local targetFile = (selectedConfigToLoad ~= "" and selectedConfigToLoad ~= "Trống") and selectedConfigToLoad or configFileName
   local path = "UltimateFarmHub/" .. targetFile .. ".json"
   local data = {Favorites = favoriteLocations, Speed = walkSpeedValue, FlySpeed = flySpeed}
   writefile(path, HttpService:JSONEncode(data)) Rayfield:Notify({Title = "Thành công", Content = "Đã ghi đè", Duration = 2})
end})
ConfigTab:CreateButton({Name = "🗑️ Xóa Config Đang Chọn", Callback = function()
   if selectedConfigToLoad == "" or selectedConfigToLoad == "Trống" then return end
   local path = "UltimateFarmHub/" .. selectedConfigToLoad .. ".json"
   if isfile(path) then delfile(path) local autoPath = "UltimateFarmHub/Autoload/" .. selectedConfigToLoad .. ".lua" if isfile(autoPath) then delfile(autoPath) end ConfigDropdown:Refresh(getConfigFiles(), true) end
end})

ConfigTab:CreateSection("Tự động thực thi (Auto Execute)")
ConfigTab:CreateButton({Name = "⚡ Bật Auto Execute cho File Này", Callback = function()
   if selectedConfigToLoad == "" or selectedConfigToLoad == "Trống" then Rayfield:Notify({Title = "Lỗi", Content = "Vui lòng chọn file trong danh sách!", Duration = 3}) return end
   local scriptContent = '-- Auto Execute generated by Tuấn Thợ Săn\ntask.spawn(function()\n    pcall(function()\n        print("Tuấn Thợ Săn: Loaded Config: ' .. selectedConfigToLoad .. '")\n    end)\nend)'
   local autoPath = "UltimateFarmHub/Autoload/" .. selectedConfigToLoad .. ".lua"
   writefile(autoPath, scriptContent)
   Rayfield:Notify({Title = "Thành công", Content = "Đã bật Auto Execute", Duration = 3})
end})
ConfigTab:CreateButton({Name = "❌ Tắt Auto Execute của File Này", Callback = function()
   if selectedConfigToLoad == "" or selectedConfigToLoad == "Trống" then return end
   local autoPath = "UltimateFarmHub/Autoload/" .. selectedConfigToLoad .. ".lua"
   if isfile(autoPath) then delfile(autoPath) Rayfield:Notify({Title = "Thành công", Content = "Đã tắt Auto Execute", Duration = 3}) end
end})
   end)
   if not found then Rayfield:Notify({Title = "Lỗi", Content = "Không tìm thấy nhà của bạn trong Server!", Duration = 3}) end
end})

-- CHỈNH SỬA Ở ĐÂY: TÁCH NÚT TELEPORT RA KHỎI DROPDOWN
MainTab:CreateSection("Bản đồ (Bấm nút bay nhiều lần thoải mái)")
local selectedFav = ""
local favoriteLocations = {}

MainTab:CreateDropdown({
   Name = "1. CHỌN ĐỊA ĐIỂM (Ở ĐÂY)",
   Options = DropdownOptions,
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "Dropdown_Teleport",
   Callback = function(Option)
       selectedFav = Option[1] -- Chỉ lưu lại địa điểm bạn vừa chọn, chưa bay
   end,
})

MainTab:CreateButton({
   Name = "🚀 2. DỊCH CHUYỂN ĐẾN NƠI ĐÃ CHỌN",
   Callback = function()
       if selectedFav == "" then
           Rayfield:Notify({Title = "Thông báo", Content = "Vui lòng chọn địa điểm ở thanh bên trên trước!", Duration = 2})
           return
       end
       local engKey = NameToEnglishKey[selectedFav]
       local targetVector = LocationList[engKey]
       if targetVector then
           local char = LocalPlayer.Character
           if char and char:FindFirstChild("HumanoidRootPart") then
               char.HumanoidRootPart.CFrame = CFrame.new(targetVector + Vector3.new(0, 3, 0))
               Rayfield:Notify({Title = "Thành công!", Content = "Đã bay đến: " .. selectedFav, Duration = 2})
           end
       end
   end,
})

MainTab:CreateButton({
   Name = "⭐ Thêm / Bỏ Yêu Thích Địa Điểm Này",
   Callback = function()
       if selectedFav == "" then Rayfield:Notify({Title = "Thông báo", Content = "Vui lòng chọn địa điểm trước!", Duration = 2}) return end
       local idx = table.find(favoriteLocations, selectedFav)
       if idx then
           table.remove(favoriteLocations, idx) Rayfield:Notify({Title = "Yêu thích", Content = "Đã XÓA: " .. selectedFav, Duration = 2})
       else
           table.insert(favoriteLocations, selectedFav) Rayfield:Notify({Title = "Yêu thích", Content = "Đã THÊM: " .. selectedFav, Duration = 2})
       end
   end,
})

MainTab:CreateSection("Danh sách Yêu thích")
local selectedFavTeleport = ""
local FavDropdown = MainTab:CreateDropdown({
   Name = "⭐ Chọn mục yêu thích",
   Options = {"Chưa có mục yêu thích"},
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "Dropdown_Favorites",
   Callback = function(Option)
       selectedFavTeleport = Option[1]
   end,
})

MainTab:CreateButton({
   Name = "🚀 DỊCH CHUYỂN (MỤC YÊU THÍCH)",
   Callback = function()
       if selectedFavTeleport == "" or selectedFavTeleport == "Chưa có mục yêu thích" then
           Rayfield:Notify({Title = "Thông báo", Content = "Chưa chọn mục yêu thích hợp lệ!", Duration = 2})
           return
       end
       local engKey = NameToEnglishKey[selectedFavTeleport]
       local targetVector = LocationList[engKey]
       if targetVector then
           local char = LocalPlayer.Character
           if char and char:FindFirstChild("HumanoidRootPart") then
               char.HumanoidRootPart.CFrame = CFrame.new(targetVector + Vector3.new(0, 3, 0))
               Rayfield:Notify({Title = "Yêu thích", Content = "Đã bay đến: " .. selectedFavTeleport, Duration = 2})
           end
       end
   end,
})

MainTab:CreateButton({
   Name = "🔄 Làm mới danh sách Yêu Thích",
   Callback = function()
       if #favoriteLocations > 0 then
           FavDropdown:Refresh(favoriteLocations, true) Rayfield:Notify({Title = "Thành công", Content = "Đã cập nhật!", Duration = 2})
       else
           FavDropdown:Refresh({"Chưa có mục yêu thích"}, true) Rayfield:Notify({Title = "Trống", Content = "Chưa có địa điểm yêu thích nào!", Duration = 2})
       end
   end,
})

-- ==========================================
-- TAB 2: NHÂN VẬT & NGƯỜI CHƠI
-- ==========================================
PlayerTab:CreateSection("Tùy chỉnh Nhân vật")
local walkSpeedEnabled = false
local walkSpeedValue = 16
PlayerTab:CreateToggle({Name = "Bật Chạy Nhanh", CurrentValue = false, Flag = "Toggle_Speed", Callback = function(Value) walkSpeedEnabled = Value end})
PlayerTab:CreateSlider({Name = "Điều chỉnh Tốc độ chạy", Range = {16, 300}, Increment = 1, Suffix = "Speed", CurrentValue = 50, Flag = "Slider_Speed", Callback = function(Value) walkSpeedValue = Value end})
RunService.RenderStepped:Connect(function() if walkSpeedEnabled then local char = LocalPlayer.Character local hum = char and char:FindFirstChild("Humanoid") if hum then hum.WalkSpeed = walkSpeedValue end end end)

local flyEnabled = false
local flySpeed = 50
PlayerTab:CreateToggle({Name = "Bật Bay (Fly - Dùng WASD + Space)", CurrentValue = false, Flag = "Toggle_Fly", Callback = function(Value) flyEnabled = Value end})
PlayerTab:CreateSlider({Name = "Điều chỉnh Tốc độ Bay", Range = {20, 500}, Increment = 1, Suffix = "Fly Speed", CurrentValue = 50, Flag = "Slider_FlySpeed", Callback = function(Value) flySpeed = Value end})
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character local hrp = char and char:FindFirstChild("HumanoidRootPart") local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    if flyEnabled then
        if not hrp:FindFirstChild("FlyVelocity") then
            local bv = Instance.new("BodyVelocity") bv.Name = "FlyVelocity" bv.MaxForce = Vector3.new(9e9, 9e9, 9e9) bv.Velocity = Vector3.zero bv.Parent = hrp
            local bg = Instance.new("BodyGyro") bg.Name = "FlyGyro" bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9) bg.P = 9e4 bg.CFrame = hrp.CFrame bg.Parent = hrp
            hum.PlatformStand = true
        end
        local bv = hrp:FindFirstChild("FlyVelocity") local bg = hrp:FindFirstChild("FlyGyro") local cam = workspace.CurrentCamera
        if bv and bg and cam then
            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            bv.Velocity = moveDir * flySpeed bg.CFrame = cam.CFrame
        end
    else
        if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
        if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
        if hum then hum.PlatformStand = false end
    end
end)

PlayerTab:CreateSection("Người chơi trong Server")
local selectedPlayer = ""
local PlayerDropdown = PlayerTab:CreateDropdown({
   Name = "1. CHỌN NGƯỜI CHƠI",
   Options = {"Chưa tải danh sách..."},
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "Dropdown_TeleportPlayer",
   Callback = function(Option)
       selectedPlayer = Option[1]
   end,
})

PlayerTab:CreateButton({
   Name = "🚀 2. DỊCH CHUYỂN TỚI NGƯỜI NÀY",
   Callback = function()
       if selectedPlayer == "" or selectedPlayer == "Chưa tải danh sách..." then
           Rayfield:Notify({Title = "Thông báo", Content = "Vui lòng chọn người chơi trước!", Duration = 2})
           return
       end
       local targetPlayer = Players:FindFirstChild(selectedPlayer)
       if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
           local char = LocalPlayer.Character
           if char and char:FindFirstChild("HumanoidRootPart") then
               char.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
               Rayfield:Notify({Title = "Thành công!", Content = "Đã tele tới " .. selectedPlayer, Duration = 2})
           end
       end
   end,
})

PlayerTab:CreateButton({
   Name = "🔄 Làm mới danh sách Người chơi",
   Callback = function()
       local pList = {}
       for _, p in ipairs(Players:GetPlayers()) do
           if p ~= LocalPlayer then table.insert(pList, p.Name) end
       end
       if #pList > 0 then
           PlayerDropdown:Refresh(pList, true) Rayfield:Notify({Title = "Thành công", Content = "Đã cập nhật danh sách người chơi!", Duration = 2})
       else
           Rayfield:Notify({Title = "Thông báo", Content = "Bạn đang ở một mình trong Server!", Duration = 2})
       end
   end,
})

-- ==========================================
-- TAB 3: QUẢN LÝ CẤU HÌNH (CONFIG SYSTEM)
-- ==========================================
ConfigTab:CreateSection("Quản lý File Config")

if not isfolder("UltimateFarmHub") then makefolder("UltimateFarmHub") end
if not isfolder("UltimateFarmHub/Autoload") then makefolder("UltimateFarmHub/Autoload") end

local configFileName = "my_config"

ConfigTab:CreateInput({Name = "Đặt tên Config", PlaceholderText = "Nhập tên file...", RemoveTextAfterFocusLost = false, Flag = "Input_ConfigName", Callback = function(Text) if Text ~= "" then configFileName = Text end end})

local function getConfigFiles()
    local files = {}
    if isfolder("UltimateFarmHub") then
        for _, file in ipairs(listfiles("UltimateFarmHub")) do
            local name = file:match("([^/]+)$") name = name:match("(.+)%..+$") or name
            if name ~= "Autoload" then table.insert(files, name) end
        end
    end
    if #files == 0 then table.insert(files, "Trống") end return files
end

local selectedConfigToLoad = ""
local ConfigDropdown = ConfigTab:CreateDropdown({Name = "Chọn File Config có sẵn", Options = getConfigFiles(), CurrentOption = {"Trống"}, MultipleOptions = false, Flag = "Dropdown_Configs", Callback = function(Option) selectedConfigToLoad = Option[1] end})
ConfigTab:CreateButton({Name = "🔄 Làm mới danh sách File", Callback = function() ConfigDropdown:Refresh(getConfigFiles(), true) Rayfield:Notify({Title = "Thành công", Content = "Đã cập nhật danh sách file!", Duration = 2}) end})
ConfigTab:CreateButton({Name = "➕ Tạo Config Mới", Callback = function() local path = "UltimateFarmHub/" .. configFileName .. ".json" if isfile(path) then Rayfield:Notify({Title = "Lỗi", Content = "File này đã tồn tại! Hãy dùng nút Ghi Đè.", Duration = 3}) else local data = {Favorites = favoriteLocations, Speed = walkSpeedValue, FlySpeed = flySpeed} writefile(path, HttpService:JSONEncode(data)) Rayfield:Notify({Title = "Thành công", Content = "Đã tạo config: " .. configFileName, Duration = 2}) ConfigDropdown:Refresh(getConfigFiles(), true) end end})
ConfigTab:CreateButton({Name = "💾 Ghi Đè (Đè dữ liệu vào file đang chọn)", Callback = function() local targetFile = (selectedConfigToLoad ~= "" and selectedConfigToLoad ~= "Trống") and selectedConfigToLoad or configFileName local path = "UltimateFarmHub/" .. targetFile .. ".json" local data = {Favorites = favoriteLocations, Speed = walkSpeedValue, FlySpeed = flySpeed} writefile(path, HttpService:JSONEncode(data)) Rayfield:Notify({Title = "Thành công", Content = "Đã ghi đè dữ liệu vào: " .. targetFile, Duration = 2}) end})
ConfigTab:CreateButton({Name = "🗑️ Xóa Config Đang Chọn", Callback = function() if selectedConfigToLoad == "" or selectedConfigToLoad == "Trống" then Rayfield:Notify({Title = "Lỗi", Content = "Chưa chọn file để xóa!", Duration = 2}) return end local path = "UltimateFarmHub/" .. selectedConfigToLoad .. ".json" if isfile(path) then delfile(path) local autoPath = "UltimateFarmHub/Autoload/" .. selectedConfigToLoad .. ".lua" if isfile(autoPath) then delfile(autoPath) end Rayfield:Notify({Title = "Thành công", Content = "Đã xóa config: " .. selectedConfigToLoad, Duration = 2}) ConfigDropdown:Refresh(getConfigFiles(), true) end end})

ConfigTab:CreateSection("Tự động thực thi (Auto Execute)")
ConfigTab:CreateButton({Name = "⚡ Bật Auto Execute cho File Này", Callback = function() if selectedConfigToLoad == "" or selectedConfigToLoad == "Trống" then Rayfield:Notify({Title = "Lỗi", Content = "Vui lòng chọn file trong danh sách để bật Auto Execute!", Duration = 3}) return end local scriptContent = '-- Auto Execute generated by Tuấn Thợ Săn\ntask.spawn(function()\n    pcall(function()\n        print("Tuấn Thợ Săn: Auto Execute Loaded Config: ' .. selectedConfigToLoad .. '")\n    end)\nend)' local autoPath = "UltimateFarmHub/Autoload/" .. selectedConfigToLoad .. ".lua" writefile(autoPath, scriptContent) Rayfield:Notify({Title = "Thành công", Content = "Đã bật Auto Execute cho: " .. selectedConfigToLoad, Duration = 3}) end})
ConfigTab:CreateButton({Name = "❌ Tắt Auto Execute của File Này", Callback = function() if selectedConfigToLoad == "" or selectedConfigToLoad == "Trống" then Rayfield:Notify({Title = "Lỗi", Content = "Chưa chọn file!", Duration = 2}) return end local autoPath = "UltimateFarmHub/Autoload/" .. selectedConfigToLoad .. ".lua" if isfile(autoPath) then delfile(autoPath) Rayfield:Notify({Title = "Thành công", Content = "Đã tắt Auto Execute cho: " .. selectedConfigToLoad, Duration = 3}) else Rayfield:Notify({Title = "Thông báo", Content = "File này chưa bật Auto Execute trước đó.", Duration = 2}) end end})
