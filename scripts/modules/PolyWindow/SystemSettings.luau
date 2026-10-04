local set = {}

print("+++++++++++ init settings... +++++++++++")
set.debug = require(script.Parent.Packages.Debug)
print("dbg done")
set.packages = script.Parent.Packages
set.plugins = script.Parent.Plugins
set.plugin_settings = script.Parent.PluginSettings
set.themes = script.Parent.Themes
set.apps = script.Parent.Apps
set.wcreate_managers = script.Parent.WCreateManagers
print("paths done")

set.spring = require(set.packages:WaitChild("SpringV2"))
print("springv2 done")

set.defaultTheme = "Dark"
set.defaultWCreateManager = "Vanilla"
set.currentWCreateManager = nil

set.headerHeight = 32
set.outroTime = 0.45
set.grid = Vector2.New(0, 0)
set.executionTimeBudget = 1 / 120

set.springTypes = {
	primary = set.spring.springInfo(0.5, 2),
	secondary = set.spring.springInfo(0.75, 2),
	tertiary = set.spring.springInfo(1, 3),
	heavy = set.spring.springInfo(1.25, 2),
	fast = set.spring.springInfo(0.5, 3),
	snappy = set.spring.springInfo(0.22, 0),
}

set.offsets = { contentOffset = Vector2.New(0, 2) }
set.transparency = { activeAlpha = 0.95, inactiveAlpha = 0.8 }
print("config done")
print("+++++++++++ settings done ++++++++++++")

return set