# Description

Completely rewrite the vanilla calculation for line of sight as well as what is considered cover.
In general it's now a bit easier to look around cover and uphill but it is harder to look over/behind hills.
You can now hide behind hills from enemy archers or at least use them as cover.

# List of all Changes

## Major Changes

### Custom Line of Sight (Setting)
Replace the vanilla LOS calculation with a custom one:
- It's now easier to look uphill and around obstacles
- You can even look over obstacles if you are high enough up.
- However hills between you and your target block the vision better
- A hill that is 2 levels higher than you and adjacent to you will be counted as blocking vision
- A hill that is 2 levels higher than your target and adjacent to your target will be counted as blocking vision

### Custom Cover calculation (Setting)
Replace the vanilla calculation for when something is considered cover.
- Any tile that is 2 level higher than you now counts as cover.
- Any tile that is 2 levels lower than you will never count as cover, even if there is a tree or other obstacle on it.
- For all other tiles the normal vanilla rules apply where obstacles and entities will count as cover, except allies at a range of 2 tiles only

### Preview blocked tiles (Setting)
When previewing movement during battle, all covering tiles next to your destination is now highlighted.

### Vision Matrix Cache (Setting)
Enables a dynamically populated matrix that stores Line of Sight (LOS) data between hex tiles. It is filled during combat as LOS checks are made, allowing for faster lookups in subsequent checks.
This feature is only effective when vision-blocking elements remain static on the map. Disable this option if you expect dynamic changes, like new obstacles appearing during combat, as it may lead to inaccurate results.

## Fixes

- Requires **Custom Line of Sight**: Fix 2-tile melee attacks sometimes not being able to target an enemy who is 2 tiles away, when there is a hill adjacent to you and the target

## Debug

### Tile Debug Info (Setting)
When hovering over a tile on the battlefield, display a lot additional information about it like Coordinates and Properties.

### LOS Path (Setting)
When hovering over a tile on the battlefield, highlight all tiles that belong to the direct path from the active entity to that tile. Tiles which block vision for this path are marked red while all other tiles are marked white.

# Requirements

- Modding Standards and Utilities (MSU)

# Known Issues:
- The feature **Preview blocked tiles** will never highlight the tile that the active entity is standing on. So when you move downhills 2 levels landing on an adjacent tile to your starting position, the preview will be inaccurate

# Compatibility

- Is safe to remove from- and add to any existing savegames

# License

This mod is licensed under the **Zero-Money License**, which is a custom license based on the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) License with additional restrictions, see LICENSE.txt.

## Key Differences from CC BY-NC-SA 4.0:

- **No Donations:** Explicitly prohibits soliciting or accepting any form of financial contributions related to the mod.
