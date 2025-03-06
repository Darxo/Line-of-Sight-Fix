::modLOSFIX.Logic <- {
	TileMatrix = [],

	// This function must be called once at the start of each combat
	function initialize()
	{
		local mapSize = ::Tactical.getMapSize();
		this.TileMatrix = array(mapSize.X * mapSize.Y, null);
		for (local i = 0; i < mapSize.X * mapSize.Y; ++i)
		{
			this.TileMatrix[i] = {Defogged = false};
		}
	}

	function clearTileMatrix()
	{
		foreach (entry in this.TileMatrix)
		{
			entry.Defogged = false;
		}
	}

	// This function is only relevant for the player
	// This function will first apply fog of war to all tiles on the battlefield and then remove fog of war for each tile, currently revealed to the player
	// You must be sure that you went through all tiles on the map and analysed their Fog-State into the TileMatrix, before you call this function
	function resetFog()
	{
		// First we apply fog to all tiles on the battlefield
		::Tactical.clearVisibility();

		// Then we reveal all tiles again, that the player is allowed to see
		foreach (index, entry in this.TileMatrix)
		{
			if (entry.Defogged)
			{
				local tile = ::modLOSFIX.VisionMatrixCache.matrixIndexToTile(index);
				tile.addVisibilityForFaction(::Const.Faction.Player);
			}
		}
	}

	// Determines whether _entity can see _targetTile
	// Will consider vision of _entity, visibility blocking obstacles and terrain level
	// Returns true if _entity can see _targetTile; return false otherwise
	function canSeeTile( _entity, _targetTile )
	{
		local myTile = _entity.getTile();
		local visionRange = _entity.getCurrentProperties().getVision();
		local tileDistance = myTile.getDistanceTo(_targetTile);

		local bonusVision = ::Math.max(0, myTile.Level - _targetTile.Level);		// You can view farther downhill
		if (tileDistance > visionRange + bonusVision)
		{
			return false;	// Our vision is not enough to see the tile
		}

		return ::modLOSFIX.Logic.hasLineOfSight(myTile, _targetTile);
	}

	// Determines whether _entity can see the content on top of _targetTile. Bushes and other plantlife might hide what is on top of a tile
	// Note: This function does not replace a canSeeTile call and should only be called after confirming that one first
	function canSeeContent( _entity, _targetTile )
	{
		if (!_targetTile.IsHidingEntity) return true;

		if (_entity.getTile().getDistanceTo(_targetTile) <= 1)
		{
			return true;
		}

		// The tile has been revealed to the player at some point during the current round
		local belongsToPlayer = (_entity.getFaction() == ::Const.Faction.Player || _entity.getFaction() == ::Const.Faction.PlayerAnimals);
		if (belongsToPlayer) return _targetTile.IsVisibleForPlayer;

		// The tile is empty, so we can never see it
		if (!_targetTile.IsOccupiedByActor) return false;

		local targetEntity = _targetTile.getEntity();
		if (_entity.isAlliedWith(targetEntity.getFaction()))
		{
			// Approximation: We could also check whether targetEntity is part of getKnownAllies() but I believe especially for allies we can do it simpler
			return true;
		}
		else
		{
			// I don't actually know how Vanilla calculates whether it can see enemies in bushes. The code does not explain that
			// From the internet I get the rough idea that once you are discovered by the AI, you can't hide in bushes anymore

			// We check, whether the enemy on that tile is already known to us and whether the bush is the last position we know about them
			local opponents =  _entity.getAIAgent().getKnownOpponents();
			foreach(opponent in opponents)
			{
				if (::MSU.isEqual(opponent.Actor, targetEntity) && _targetTile.isSameTileAs(opponent.Tile))
				{
					return true;
				}
			}

			return false;
		}
	}

	// Reveal a single tile for _entity and the faction of _entity
	// @return true, if a forbidden tile was revealed
	function revealTile( _entity, _tile )
	{
		_tile.addVisibilityForCurrentEntity();
		_tile.addVisibilityForFaction(_entity.getFaction());

		if (_entity.getFaction() == ::Const.Faction.PlayerAnimals)
		{
			_tile.addVisibilityForFaction(::Const.Faction.Player);
		}

		/*
		// This vanilla logic is currently not needed here, because whenever revealTile is called for Player/PlayerAnimals all target entities are already been discovered by the LF_UpdateVisibilityForPlayer
		if (_tile.IsOccupiedByActor)
		{
			// Player and PlayerAnimals will discover entities for the Player
			if (_entity.getFaction() == ::Const.Faction.Player || _entity.getFaction() == ::Const.Faction.PlayerAnimals)
			{
				_tile.getEntity().setDiscovered(true);
			}
		}
		*/
	}

	// Proxy-Function.
	// Determines whether _startTile can see _targetTile
	// Will consider visibility blocking obstacles and terrain level
	// Returns true if _startTile can see _targetTile; return false otherwise
	function hasLineOfSight( _startTile, _targetTile )
	{
		::logError("Proxy Function was not replaced!");
	}

	// Determines whether _tile would block line of sight between _userTile and _targetTile
	// This function is symmetric in the sense that it will always yield the same result, even if _userTile and _targetTile was swapped
	function isBlockingLOS( _userTile, _targetTile, _tile )
	{
		if (_tile.isSameTileAs(_userTile)) return false;	// My tile never blocks line of sight
		if (_tile.isSameTileAs(_targetTile)) return false;	// The destination tile never blocks line of sight

		local tileHeight = _tile.Level;
		if (!_tile.IsEmpty && _tile.getEntity().isBlockingSight()) tileHeight += 2;	// A visibility blocking object counts as 2 height instead of blocking LOS outright

		// If the tile in question is very close to the user or target, then it is sufficient if it's 2 levels higher in order to block line of sight
		if (_userTile.getDistanceTo(_tile) == 1 && (tileHeight >= _userTile.Level + 2))
		{
			return true;
		}
		if (_targetTile.getDistanceTo(_tile) == 1 && (tileHeight >= _targetTile.Level + 2))
		{
			return true;
		}

		local totalHeightDifference = tileHeight - _userTile.Level + tileHeight - _targetTile.Level;
		return totalHeightDifference >= 3;
	}

// Getter Setter
	function getTileInfo( _tile )
	{
		return this.TileMatrix[::modLOSFIX.VisionMatrixCache.__getID(_tile)];
	}

	// Determines whether _startTile can see _targetTile
	// Will consider visibility blocking obstacles and terrain level
	// Returns true if _startTile can see _targetTile; return false otherwise
	function __hasLineOfSight( _startTile, _targetTile )
	{
		local ccStartTile = ::modLOSFIX.CubeCoordinates.fromAxial(_startTile);
		local ccTargetTile = ::modLOSFIX.CubeCoordinates.fromAxial(_targetTile);
		local path = ::modLOSFIX.CubeCoordinates.generatePath(ccStartTile, ccTargetTile);

		// Remove all tiles from the path, which block line of sight
		for (local index = path.len() - 1; index >= 0; --index)
		{
			if (!::Tactical.isValidTile(path[index].axialX, path[index].axialY))
			{
				path.remove(index);
				continue;
			}

			if (this.isBlockingLOS(_startTile, _targetTile, ::Tactical.getTile(path[index].axialX, path[index].axialY)))
			{
				path.remove(index);
				continue;
			}
		}

		return ::modLOSFIX.CubeCoordinates.isPathPossible(ccStartTile, ccTargetTile, path);
	}
}

// This function will normally be replaced by the callback function of our VisionMatrixCache setting, but that might not happen the first time ever, you use this mod
::modLOSFIX.Logic.hasLineOfSight = ::modLOSFIX.Logic.__hasLineOfSight;
