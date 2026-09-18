# Goodix 27c6:5e0a fingerprint support, consumed from the driver flake.
# Driver sources, packaging and module options live in the goodix repo;
# this wrapper only picks your local policy:
#   - pamServices = true: fingerprint for login/sudo/sddm/hyprlock/swaylock
#     (the module sets it as the explicit default; per-service settings win)
#   - dllFile defaults to the engine bundled in the flake's windows_driver/
{ inputs, ... }: {
  imports = [ inputs.goodix.nixosModules.default ];
  services.fprintd.goodix.pamServices = true;
}
