::modLOSFIX.HooksMod.hook("scripts/ui/screens/tooltip/tooltip_events", function(q) {
	q.m.MarkedTiles <- [];

	q.tactical_queryTileTooltipData = @(__original) function()
	{
		local lastTileHovered = ::Tactical.State.getLastTileHovered();
		if (lastTileHovered == null) return null;

		local activeEntity = ::Tactical.TurnSequenceBar.getActiveEntity();
		if (activeEntity != null)
		{
			if (::modLOSFIX.Mod.ModSettings.getSetting("DisplayLOSPath").getValue())
			{
				::TooltipEvents.markTiles([], []);	// Reset the current path. It may point to tiles from the last battle
				local pathArray = this.getTacticalPath(activeEntity.getTile(), lastTileHovered);
				this.markTiles(pathArray[0], pathArray[1]);
			}
		}

		if (!::modLOSFIX.Mod.ModSettings.getSetting("ShowTileDebugInfo").getValue())
		{
			return __original();
		}

		local ret = __original();
		if (ret == null)
		{
			ret = [
				{
					id = 1,
					type = "title",
					text = ::Const.Strings.Tactical.TerrainName[lastTileHovered.Subtype],
					icon = "ui/tooltips/height_" + lastTileHovered.Level + ".png"
				}
			];
		}

		local ccTile = ::modLOSFIX.CubeCoordinates.fromAxial(lastTileHovered);

		local hasLineOfSight = false;
		if (activeEntity != null && activeEntity.isPlacedOnMap()) hasLineOfSight = ::modLOSFIX.Logic.hasLineOfSight(activeEntity.getTile(), lastTileHovered);
		ret.extend([
			{
				id = 89,
				type = "text",
				text = "hasLineOfSight: " + hasLineOfSight,
			},
			{
				id = 90,
				type = "text",
				text = "IsDiscovered: " + lastTileHovered.IsDiscovered
			},
			{
				id = 90,
				type = "text",
				text = "IsVisibleForEntity: " + lastTileHovered.IsVisibleForEntity
			},
			{
				id = 90,
				type = "text",
				text = "IsVisibleForPlayer: " + lastTileHovered.IsVisibleForPlayer
			},
			{
				id = 90,
				type = "text",
				text = "IsSpecialTerrain: " + lastTileHovered.IsSpecialTerrain
			},
			{
				id = 90,
				type = "text",
				text = "IsOccupiedByActor: " + lastTileHovered.IsOccupiedByActor
			},
			{
				id = 90,
				type = "text",
				text = "IsHidingEntity: " + lastTileHovered.IsHidingEntity
			},
			{
				id = 90,
				type = "text",
				text = "IsEmpty: " + lastTileHovered.IsEmpty
			},
			{
				id = 90,
				type = "text",
				text = "Default (Axial): X: " + lastTileHovered.X + ", Y: " + lastTileHovered.Y
			},
			/*{
				id = 90,
				type = "text",
				text = "Coords (Axial): X: " + lastTileHovered.Coords.X + ", Y: " + lastTileHovered.Coords.Y
			},*/
			{
				id = 90,
				type = "text",
				text = "Square (Odd-Q): X: " + lastTileHovered.SquareCoords.X + ", Y: " + lastTileHovered.SquareCoords.Y
			},
			{
				id = 89,
				type = "text",
				text = "ccTile: " + ccTile.asString(),
			},
			{
				id = 91,
				type = "text",
				text = "Tile Level: " + lastTileHovered.Level,
			},
		]);

		return ret;
	}

// New Functions
	// Unmark the previous tiles and mark the new passed ones
	q.markTiles <- function( _validTiles, _blockedTiles )
	{
		foreach (tile in this.m.MarkedTiles)
		{
			tile.clear(::Const.Tactical.DetailFlag.SpecialOverlay);
		}
		this.m.MarkedTiles = [];

		foreach (tile in _validTiles)
		{
			tile.spawnDetail("zone_selection_overlay", ::Const.Tactical.DetailFlag.SpecialOverlay, false, true);
			this.m.MarkedTiles.push(tile);
		}

		foreach (tile in _blockedTiles)
		{
			tile.spawnDetail("zone_target_overlay", ::Const.Tactical.DetailFlag.SpecialOverlay, false, true);
			this.m.MarkedTiles.push(tile);
		}
	}

	// Generate a path from _startTile to _targetTile and diffentiate tiles which block vision on that path
	// Return an array with two entries. The first entry is an array of all valid tiles. The second entry is an array with all invalid tiles
	q.getTacticalPath <- function( _startTile, _targetTile )
	{
		local ccStartTile = ::modLOSFIX.CubeCoordinates.fromAxial(_startTile);
		local ccTargetTile = ::modLOSFIX.CubeCoordinates.fromAxial(_targetTile);
		local path = ::modLOSFIX.CubeCoordinates.generatePath(ccStartTile, ccTargetTile);

		local validTiles = [];
		local blockedTiles = [];

		// Remove all tiles from the path, which block line of sight
		for (local index = path.len() - 1; index >= 0; --index)
		{
			if (!::Tactical.isValidTile(path[index].axialX, path[index].axialY))
			{
				continue;
			}

			local tacticalTile = ::Tactical.getTile(path[index].axialX, path[index].axialY);
			if (::modLOSFIX.Logic.isBlockingLOS(_startTile, _targetTile, tacticalTile))
			{
				blockedTiles.push(tacticalTile);
			}
			else
			{
				validTiles.push(tacticalTile);
			}
		}

		return [validTiles, blockedTiles];
	}
});

