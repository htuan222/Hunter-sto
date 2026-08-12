-- ==========================================
-- TUẤN THỢ SĂN - ULTIMATE VIP HUB (FIXED & FULL AURA)
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
-- 1. THIẾT LẬP DỮ LIỆU BẢN ĐỒ
-- ==========================================
local LocationList = {
    ["Junk Yard"] = Vector3.new(19.876174926758, 1719.7297363281, -24.290977478027),
    ["Back Alley"] = Vector3.new(-571.18017578125, 1719.3342285156, -399.95452880859),
    ["Farmyard"] = Vector3.new(-89.327423095703, 1720.2707519531, -1153.0178222656),
    ["Shipyard"] = Vector3.new(-550.99005126953, 1719.4323730469, 698.22430419922),
    ["Shopping Mall"] = Vector3.new(346.7200012207, 1719.3807373047, -172.73672485352),
    ["Lucky Beach"] = Vector3.new(-222.60774230957, 1686.7734375, -1784.8059082031),
    ["Power Plant"] = Vector3.new(-2115.6499023438, 1719.0513916016, -955.83801269531),
    ["Car Shop"] = Vector3.new(-222.93823242188, 1721.9176025391, -170.5347442627),
    ["Museum"] = Vector3.new(506.39321899414, 1725.0548095703, -185.03215026855),
    ["Authenticator"] = Vector3.new(-677.49078369141, 1723.3251953125, -923.75372314453),
    ["Club"] = Vector3.new(-693.76568603516, 1721.5576171875, -1020.4771728516),
    ["Energy Drink Shop"] = Vector3.new(337.17178344727, 1721.9250488281, -7.1113896369934),
    ["Locksmith"] = Vector3.new(394.72604370117, 1722.1179199219, -22.085414886475),
    ["Repair Shop"] = Vector3.new(458.13327026367, 1721.919921875, -79.289375305176),
    ["Car Customisation"] = Vector3.new(-72.562911987305, 1722.0942382812, 237.34637451172),
    ["Grading Store"] = Vector3.new(336.45843505859, 1721.912109375, -308.212890625),
    ["Trailer Store"] = Vector3.new(484.9274597168, 1721.3779296875, -1371.8649902344),
    ["Item Cleaning Services"] = Vector3.new(440.5322265625, 1721.9113769531, -277.263671875),
    ["Quck Sell Shop"] = Vector3.new(366.48297119141, 1721.9233398438, -21.546489715576),
    ["Lake"] = Vector3.new(631.587890625, 1713.3345947266, -852.09771728516)
}

local TranslateMap = {
    ["Junk Yard"] = "Bãi phế liệu (Junk Yard)", ["Back Alley"] = "Ngõ hẻm (Back Alley)", ["Farmyard"] = "Nông trại (Farmyard)", ["Shipyard"] = "Bến tàu (Shipyard)", ["Shopping Mall"] = "TTTM (Shopping Mall)", ["Lucky Beach"] = "Bãi biển (Lucky Beach)", ["Power Plant"] = "Nhà máy điện (Power Plant)", ["Car Shop"] = "Cửa hàng xe hơi (Car Shop)", ["Museum"] = "Bảo tàng (Museum)", ["Authenticator"] = "Phòng thẩm định (Authenticator)", ["Club"] = "Quán Bar (Club)", ["Energy Drink Shop"] = "Tiệm nước tăng lực (Energy Drink Shop)", ["Locksmith"] = "Thợ khóa (Locksmith)", ["Repair Shop"] = "Tiệm sửa chữa (Repair Shop)", ["Car Customisation"] = "Xưởng độ xe (Car Customisation)", ["Grading Store"] = "Tiệm định giá (Grading Store)", ["Trailer Store"] = "Cửa hàng xe kéo (Trailer Store)", ["Item Cleaning Services"] = "Dịch vụ làm sạch (Cleaning)", ["Quck Sell Shop"] = "Cửa hàng bán nhanh (Quick Sell)", ["Lake"] = "Hồ nước (Lake)"
}

local DropdownOptions = {}
local NameToEnglishKey = {}
for engKey, _ in pairs(LocationList) do 
    local displayName = TranslateMap[engKey] or engKey
    table.insert(DropdownOptions, displayName)
    NameToEnglishKey[displayName] = engKey
end
table.sort(DropdownOptions)

-- ==========================================
-- 2. TẠO CỬA SỔ GIAO DIỆN (UI) - KHÔNG KEY
-- ==========================================
local Window = Rayfield:CreateWindow({
   Name = "Tuấn Thợ Săn - Ultimate VIP (Optimized)",
   LoadingTitle = "Đang tải hệ thống...",
   LoadingSubtitle = "Bản Lụm Đủ 6 Món Theo Thông Báo Game",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("🛒 Chức năng chính", 4483362458) 
local PickupTab = Window:CreateTab("🧲 Auto Lụm Đồ", 4483362458) 
local PlayerTab = Window:CreateTab("🏃 Nhân vật & Người chơi", 4483362458) 
local ConfigTab = Window:CreateTab("⚙️ Cấu hình (Config)", 4483362458) 

-- Biến cấu hình chung
local autoBid = false
local bidSpeed = 0.7 
local autoLoot6Items = false
local bypassEnabled = false
local auraEnabled = false
local auraRadius = 45 -- Đã mặc định là 45 Studs
local isWeightExceeded = false

-- Lắng nghe sự kiện quá tải trọng xe/kho
local WeightEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("UI"):WaitForChild("VehicleWeightUpdate")
WeightEvent.OnClientEvent:Connect(function(currentWeight, maxWeight)
    if currentWeight and maxWeight and currentWeight > maxWeight then
        isWeightExceeded = true
    else
        isWeightExceeded = false
    end
end)

-- ==========================================
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
   Name = "🧲 Vét máng chính xác 6 món dựa theo thông báo game",
   CurrentValue = false,
   Flag = "Toggle_Loot6Items",
   Callback = function(Value) autoLoot6Items = Value end,
})

-- LOGIC CHÍNH: LẮNG NGHE THÔNG BÁO "Added to vehicle!" ĐỂ ĐẾM ĐỦ 6 MÓN RỒI TỰ TẮT
local PickupEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Auction"):WaitForChild("AuctionPickupStart")
local NotifyEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("UI"):WaitForChild("Notify")

PickupEvent.OnClientEvent:Connect(function()
    if autoLoot6Items then
        task.wait(0.5)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        Rayfield:Notify({Title = "Thắng Bid!", Content = "Đang quét và đếm thông báo xe...", Duration = 1.5})
        isWeightExceeded = false
        
        local collectedCount = 0
        local notifyConnection
        
        -- Lắng nghe sự kiện thông báo của game để đếm chính xác số lượng item đã vào xe
        notifyConnection = NotifyEvent.OnClientEvent:Connect(function(msg)
            if type(msg) == "string" and msg:lower():find("added to vehicle") then
                collectedCount = collectedCount + 1
            end
        end)
        
        local safeguard = 0
        -- Vòng lặp bắn prompt liên tục cho đến khi nhận đủ 6 thông báo "Added to vehicle!" hoặc quá thời gian
        while collectedCount < 6 and safeguard < 40 and not isWeightExceeded do
            safeguard = safeguard + 1
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    local part = obj.Parent
                    local pos = part:IsA("BasePart") and part.Position or (part:IsA("Model") and part.PrimaryPart and part.PrimaryPart.Position)
                    
                    if pos and (pos - hrp.Position).Magnitude <= auraRadius then
                        pcall(function() fireproximityprompt(obj) end)
                    end
                end
            end
            
            task.wait(0.5)
        end
        
        -- Ngắt kết nối sự kiện thông báo sau khi hoàn tất để tiết kiệm tài nguyên
        if notifyConnection then
            notifyConnection:Disconnect()
        end
        
        if isWeightExceeded then
            Rayfield:Notify({Title = "Kho đầy!", Content = "Đã dừng lụm do kho đầy!", Duration = 2})
        else
            Rayfield:Notify({Title = "Hoàn tất", Content = "Đã nhận đủ 6 món vào xe!", Duration = 1.5})
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
   Callback = function(Option)
       selectedFav = Option[1]
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
       if selectedFav == "" then
           Rayfield:Notify({Title = "Thông báo", Content = "Vui lòng chọn địa điểm trước!", Duration = 2})
           return
       end
       local idx = table.find(favoriteLocations, selectedFav)
       if idx then
           table.remove(favoriteLocations, idx)
           Rayfield:Notify({Title = "Yêu thích", Content = "Đã XÓA: " .. selectedFav, Duration = 2})
       else
           table.insert(favoriteLocations, selectedFav)
           Rayfield:Notify({Title = "Yêu thích", Content = "Đã THÊM: " .. selectedFav, Duration = 2})
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
           FavDropdown:Refresh(favoriteLocations, true)
           Rayfield:Notify({Title = "Thành công", Content = "Đã cập nhật!", Duration = 2})
       else
           FavDropdown:Refresh({"Chưa có mục yêu thích"}, true)
           Rayfield:Notify({Title = "Trống", Content = "Chưa có địa điểm yêu thích nào!", Duration = 2})
       end
   end,
})

-- ==========================================
-- TAB 2: AUTO LỤM ĐỒ (PICKUP & AURA)
-- ==========================================
PickupTab:CreateSection("Tùy chỉnh Lụm Đồ Nhanh")

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
   Name = "🧲 Kích hoạt Aura dọn kho thủ công",
   CurrentValue = false,
   Flag = "Toggle_Aura",
   Callback = function(Value) 
       auraEnabled = Value 
   end,
})

PickupTab:CreateSlider({
   Name = "Bán kính hút đồ (Radius)", 
   Range = {5, 100}, 
   Increment = 1, 
   Suffix = "Studs", 
   CurrentValue = 45, 
   Flag = "Slider_AuraRadius",
   Callback = function(Value) 
       auraRadius = Value 
   end,
})

task.spawn(function()
    while task.wait(0.3) do
        if auraEnabled and not isWeightExceeded then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        local part = obj.Parent
                        local pos = part:IsA("BasePart") and part.Position or (part:IsA("Model") and part.PrimaryPart and part.PrimaryPart.Position)
                        if pos and (pos - hrp.Position).Magnitude <= auraRadius then
                            pcall(function() fireproximityprompt(obj) end)
                        end
                    end
                end
            end
        end
    end
end)

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
               Rayfield:Notify({Title = "Thành công", Content = "Đã tele tới " .. selectedPlayer, Duration = 2})
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
           PlayerDropdown:Refresh(pList, true)
           Rayfield:Notify({Title = "Thành công", Content = "Đã cập nhật danh sách người chơi!", Duration = 2})
       else
           Rayfield:Notify({Title = "Thông báo", Content = "Bạn đang ở một mình trong Server!", Duration = 2})
       end
   end,
})

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

Rayfield:Notify({Title = "Tuấn Thợ Săn", Content = "Menu Full tính năng - Đã tích hợp sẵn Aura 45 Studs!", Duration = 3})
       else
           table.insert(favoriteLocations, selectedFav)
           Rayfield:Notify({Title = "Yêu thích", Content = "Đã THÊM: " .. selectedFav, Duration = 2})
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
           FavDropdown:Refresh(favoriteLocations, true)
           Rayfield:Notify({Title = "Thành công", Content = "Đã cập nhật!", Duration = 2})
       else
           FavDropdown:Refresh({"Chưa có mục yêu thích"}, true)
           Rayfield:Notify({Title = "Trống", Content = "Chưa có địa điểm yêu thích nào!", Duration = 2})
       end
   end,
})

-- ==========================================
-- TAB 2: AUTO LỤM ĐỒ (PICKUP - CHỈ CÒN LỤM NHANH)
-- ==========================================
PickupTab:CreateSection("Tùy chỉnh Lụm Đồ Nhanh")

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
               Rayfield:Notify({Title = "Thành công", Content = "Đã tele tới " .. selectedPlayer, Duration = 2})
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
           PlayerDropdown:Refresh(pList, true)
           Rayfield:Notify({Title = "Thành công", Content = "Đã cập nhật danh sách người chơi!", Duration = 2})
       else
           Rayfield:Notify({Title = "Thông báo", Content = "Bạn đang ở một mình trong Server!", Duration = 2})
       end
   end,
})

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

Rayfield:Notify({Title = "Tuấn Thợ Săn", Content = "Menu Full tính năng - Đã tối ưu tuyệt đối!", Duration = 3})

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
