# ==================================================
#  KoolDots (2026)
#  Project URL: https://github.com/LinuxBeginnings
#  License: GNU GPLv3
#  SPDX-License-Identifier: GPL-3.0-or-later
# ==================================================
{ inputs, ... }:
{
  # Keep global nixpkgs.overlays empty to ensure 100% binary cache hits from cache.nixos.org
  nixpkgs.overlays = [ ];
}
