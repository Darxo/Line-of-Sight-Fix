::modLOSFIX.HooksMod.hook("scripts/scenarios/tactical/scenario_template", function(q) {
	q.initMap <- function()
	{
	}
});

::modLOSFIX.HooksMod.hookTree("scripts/scenarios/tactical/scenario_template", function(q) {
	q.initMap = @(__original) function()
	{
		__original();
		::modLOSFIX.VisionMatrixCache.initializeMatrix();
		::modLOSFIX.Logic.initialize();
	}
});

