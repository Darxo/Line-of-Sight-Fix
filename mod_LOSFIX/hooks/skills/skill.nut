::modLOSFIX.HooksMod.hook("scripts/skills/skill", function(q) {
	q.onVerifyTarget = @(__original) function( _originTile, _targetTile )
	{
		if (!::modLOSFIX.Mod.ModSettings.getSetting("CustomLOSActive").getValue())
		{
			return __original(_originTile, _targetTile);
		}

		// We switcheroo the value of IsVisibleTileNeeded to false to skip a hacky vanilla check which prevents melee attacks from hitting through mountains
		// It is required in vanilla because their Line of Sight algorithm does a poor job in those situations
		// Our custom Line of Sight algorithm changes the visibility over mountains in exactly such a way to prevent these melee attack situations
		// 	so that check is no longer needed
		local oldIsVisibleTileNeeded = this.m.IsVisibleTileNeeded;
		this.m.IsVisibleTileNeeded = false;

		local ret = __original(_originTile, _targetTile);

		this.m.IsVisibleTileNeeded = oldIsVisibleTileNeeded;

		return ret;
	}
});
