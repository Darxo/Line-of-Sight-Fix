::modLOSFIX.Logic <- {
	function isBlockingLOS( _userTile, _targetTile, _tile )
	{
		if (_userTile.getDistanceTo(_targetTile) <= 1) return false;	// Both tiles are adjacent. They will always see each other

		local tileHeight = _tile.Level;
		if (!_tile.IsEmpty && _tile.getEntity().isBlockingSight()) tileHeight += 2;	// A visibility blocking object counts as 2 height instead of blocking LOS outright

		// If the tile in question is very close to the user or target, then it is sufficient if it's 2 levels higher rather than the 3 otherwise
		if (_userTile.getDistanceTo(_tile) == 1 && (tileHeight >= _userTile.Level + 2))
		{
			return true;
		}
		if (_targetTile.getDistanceTo(_tile) == 1 && (tileHeight >= _targetTile.Level + 2))
		{
			return true;
		}

		local heightDifference = tileHeight - _userTile.Level + tileHeight - _targetTile.Level;
		return heightDifference >= 3;
	}

	function canSee( _entity, _targetTile )
	{
		local myTile = _entity.getTile();
		local visionRange = _entity.getCurrentProperties().getVision();
		local tileDistance = myTile.getDistanceTo(_targetTile);

		if (tileDistance + _targetTile.Level > visionRange + myTile.Level)	// You can view further downhill and less uphill
		{
			return false;	// Our vision is not enough to see the tile
		}

		return this.hasLineOfSight(myTile, _targetTile);
	}

	function hasLineOfSight( _startTile, _targetTile )
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

	function getLineOfSightPath( _startTile, _targetTile )
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

		return path;
	}
}



