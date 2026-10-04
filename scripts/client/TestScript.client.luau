wait(1)

local PolyWindow = require(Hidden:WaitChild("Modules"):WaitChild("PolyWindow"))

local button:UIButton = script.Parent

print("INIT FUNC")
local testFunc = function()
    --print("== PolyWindow test start ==")

    local content = Instance.New("UILabel")::UILabel
    content.Color = Color.New(0,0,0,0)
    content.Text = "Put anything in here lol"
    content.TextColor = Color.FromHex("#E8EDF2")
    content.SizeRelative = Vector2.New(1, 1)
    content.HorizontalAlignment = Enums.HorizontalAlignment.Center
    content.VerticalAlignment = Enums.VerticalAlignment.Middle

    local ok, window = pcall(function()
        return PolyWindow:create(content, Vector2.New(460, 320) --[[, "AllHallowsEve"]])
    end)
    --print("create ok:", ok)
    if not ok then warn(window); return end

    window.maxSize = Vector2.New(500, 380)

    local header = window:getPlugin("Header")
    header:setLabel("Test Window")
    header:addButton("error test", function() error("intentional test error") end)
    header:addButton("flip", function() print("flip pressed") end)

    --print("== test end ==")
end

print("CONNECTING")
button.Clicked:Connect(testFunc)