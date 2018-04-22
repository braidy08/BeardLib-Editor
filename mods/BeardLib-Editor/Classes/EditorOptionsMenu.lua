EditorOptionsMenu = EditorOptionsMenu or class()
local Options = EditorOptionsMenu
function Options:init()
	local O = BeardLibEditor.Options
	local EMenu = BeardLibEditor.Menu
	MenuUtils:new(self, EMenu:make_page("Options"))
	local main = self:DivGroup("Main")
	self:TextBox("ExtractDirectory", ClassClbk(self, "set_clbk"), O:GetValue("ExtractDirectory"), {
		help = "The extract directory will be used to load units from extract and be able to edit lights", group = main
	})
	self:Slider("UndoHistorySize", ClassClbk(self, "set_clbk"), O:GetValue("UndoHistorySize"), {group = main, min = 1, max = 100000})

	local visual = self:DivGroup("Visual")
	self:Button("ResetVisualOptions", ClassClbk(self, "reset_options", visual), {group = visual})
	self:Button("AccentColor", ClassClbk(self, "open_set_color_dialog"), {group = visual})
	self:Button("BackgroundColor", ClassClbk(self, "open_set_color_dialog"), {group = visual})

	local themes = self:DivGroup("Themes", {group = visual, last_y_offset = 0})
	self:Button("Dark", ClassClbk(self, "set_theme"), {group = themes, text = "Dark[Default]"})
	self:Button("Light", ClassClbk(self, "set_theme"), {group = themes})
	local input = self:DivGroup("Input")
	local function keybind(setting, supports_mouse, text)
		return self:KeyBind("Input/"..setting, ClassClbk(self, "set_clbk"), O:GetValue("Input/"..setting), {text = text or string.pretty2(setting), group = input, supports_mouse = supports_mouse})
	end
	self:Button("ResetInputOptions", ClassClbk(self, "reset_options", input), {group = input})
	keybind("TeleportToSelection")
	keybind("CopyUnit")
	keybind("PasteUnit")
	keybind("SaveMap")
	keybind("ToggleMoveWidget")
	keybind("ToggleRotationWidget")
	keybind("DeleteSelection")
	keybind("ToggleMapEditor")
	keybind("IncreaseCameraSpeed")
	keybind("DecreaseCameraSpeed")
	keybind("ToggleGUI")
	keybind("ToggleRuler")

	self:Button("ResetOptions", ClassClbk(self, "reset_options"))
end

function Options:set_theme(item)
	local theme = item.name
	if theme == "Dark" then
		self:set("AccentColor", Color('4272d9'))
		self:set("BackgroundColor", Color(0.6, 0.2, 0.2, 0.2))
	else
		self:set("AccentColor", Color(0.40, 0.38, 1))
		self:set("BackgroundColor", Color(0.64, 0.70, 0.70, 0.70))
	end
    BeardLibEditor.Utils:Notify("Theme has been set, please restart")
end

function Options:reset_options(menu)
	for _, item in pairs(menu._my_items) do
		if item.menu_type then
			self:reset_options(item)
		else
			local opt = BeardLibEditor.Options:GetOption(item.name)
			if opt then
				local value = opt.default_value
				self:set(item.name, value)
				item:SetValue(value)
			end
		end
	end
end

function Options:set_clbk(item)
	self:set(item.name, item:Value())
	if item.name == "LevelsColumns" then
		BeardLibEditor.LoadLevel:load_levels()
	end
end

function Options:set(option, value)
	BeardLibEditor.Options:SetValue(option, value)
	BeardLibEditor.Options:Save()
end

function Options:open_set_color_dialog(item)
	option = item.name
    BeardLibEditor.ColorDialog:Show({color = BeardLibEditor.Options:GetValue(option), callback = function(color)
    	self:set(option, color)
    end})
end