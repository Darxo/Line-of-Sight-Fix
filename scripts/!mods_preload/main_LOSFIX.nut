::modLOSFIX <- {
	ID = "mod_LOSFIX",
	Name = "Line of Sight Fix",
	Version = "1.0.0",
	GitHubURL = "https://github.com/Darxo/Line-of-Sight-Fix",
}

::modLOSFIX.HooksMod <- ::Hooks.register(::modLOSFIX.ID, ::modLOSFIX.Version, ::modLOSFIX.Name);
::modLOSFIX.HooksMod.require(["mod_msu"]);

::modLOSFIX.HooksMod.queue(">mod_msu", function() {
	::modLOSFIX.Mod <- ::MSU.Class.Mod(::modLOSFIX.ID, ::modLOSFIX.Version, ::modLOSFIX.Name);

	::modLOSFIX.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, ::modLOSFIX.GitHubURL);
	::modLOSFIX.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);

	::include("mod_LOSFIX/load");		// Load mod adjustments and other hooks
});
