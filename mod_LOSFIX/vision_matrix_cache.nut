/*
This class tries to save the calculation results so that future lookups are faster.
This only works if the levels of tiles on the battlefiels never change and objects which block vision never spawn or are removed or move.

In Vanilla Sunken Library fight the level of tiles can raise and fall therefor making this class already useless.
*/

::modLOSFIX.VisionMatrixCache <- {
	MapSize = null,
	MaximumTiles = null,
	LOSMatrix = [],	// Matrix between two tile ids. Each cell contains null by default and is then filled with either true or false

	// Initialize the internal LOSMatrix.
	// Must be called once at the start of every combat
	// Must be called if the Vision Matrix Cache is enabled mid-fight
	function initializeMatrix( _defaultValue = null )
	{
		this.MapSize = ::Tactical.getMapSize();
		this.MaximumTiles = this.MapSize.X * this.MapSize.Y;
		this.LOSMatrix = array(MaximumTiles, []);
		for (local i = 0; i < this.MaximumTiles; ++i)
		{
			this.LOSMatrix[i] = array(MaximumTiles, _defaultValue);
		}
	}

	// Returns whether the two given tiles can theoretically see each other
	// Unknown combination are calculated and written into an internal LOSMatrix
	// The lookup of known combination is very fast
	function hasLineOfSight(_originTile, _targetTile)
	{
		local originId = ::modLOSFIX.VisionMatrixCache.__getID(_originTile);
		local targetId = ::modLOSFIX.VisionMatrixCache.__getID(_targetTile);

		if (::modLOSFIX.VisionMatrixCache.LOSMatrix[originId][targetId] == null)
		{
			if (::modLOSFIX.Logic.__hasLineOfSight(_originTile, _targetTile))
			{
				::modLOSFIX.VisionMatrixCache.LOSMatrix[originId][targetId] = true;
				::modLOSFIX.VisionMatrixCache.LOSMatrix[targetId][originId] = true;
				return true;
			}
			else
			{
				::modLOSFIX.VisionMatrixCache.LOSMatrix[originId][targetId] = false;
				::modLOSFIX.VisionMatrixCache.LOSMatrix[targetId][originId] = false;
				return false;
			}
		}

		return ::modLOSFIX.VisionMatrixCache.LOSMatrix[originId][targetId];
	}

	// Translate coordinates into a single unique ID starting at 0
	function __getID( _tile )
	{
		return (_tile.SquareCoords.Y * this.MapSize.X) + _tile.SquareCoords.X;
	}

	function matrixIndexToTile( _matrixIndex )
	{
		return ::Tactical.getTileSquare(_matrixIndex % this.MapSize.X, ::Math.floor(_matrixIndex / this.MapSize.X));
	}

	// Calculating a full matrix at once is not advisable because it takes really a long time, its purely theoretical
	// With a _maxDistance of 5 I need around 9 seconds to generate one
	// With a _maxDistance of 10 I need around 55 seconds to generate one
	function precalculateMatrix( _maxDistance = 5 )
	{
		local timer = ::MSU.Utils.Timer("LOSFIX_Benchmark");
		for (local x = 0; x < this.MapSize.X; ++x)
		{
			for (local y = 0; y < this.MapSize.Y; ++y)
			{
				local originTile = ::Tactical.getTileSquare(x, y);
				local originId = this.__getID(originTile);

				for (local a = 0; a < this.MapSize.X; ++a)
				{
					for (local b = 0; b < this.MapSize.Y; ++b)
					{
						local targetTile = ::Tactical.getTileSquare(a, b);
						if (targetTile.isSameTileAs(originTile)) continue;
						if (originTile.getDistanceTo(targetTile) >= _maxDistance) continue;

						local targetId = this.__getID(targetTile);

						if (::modLOSFIX.Logic.hasLineOfSight(originTile, targetTile))
						{
							this.LOSMatrix[originId][targetId] = true;
						}
						else
						{
							this.LOSMatrix[originId][targetId] = false;
						}
					}
				}
			}
		}
		::logWarning("Total time for matrix generation: " + timer.silentStop() / 1000 + " seconds");
	}
}
