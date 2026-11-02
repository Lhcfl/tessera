{ lib, ... }:
let
  inherit
    (import ../lib {
      inherit lib;
      pkgs = null;
      name = "options";
    })
    mkOption
    mkNullableOption
    ;
  t = lib.types;
in
{
  options.tessera.settings.appearance = {
    prefer_no_csd = mkNullableOption {
      applies = [
        "niri"
        "umbriel"
      ];
      type = t.bool;
      description = "Advertise a preference for server-side decorations.";
    };
    border_width = mkNullableOption {
      applies = [
        "niri"
        "umbriel"
      ];
      type = t.ints.between 0 100;
      description = "Inner border width in logical pixels.";
    };
    outer_border_width = mkNullableOption {
      applies = [ "umbriel" ];
      type = t.ints.between 0 100;
      description = "Outer border width in logical pixels.";
    };
    corner_radius = mkNullableOption {
      applies = [ "umbriel" ];
      type = t.ints.between 0 100;
      description = "Window corner radius in logical pixels.";
    };

    blur = mkOption {
      applies = [
        "niri"
        "umbriel"
      ];
      default = { };
      description = "Global blur settings.";
      type = t.submodule {
        options = {
          enabled = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.bool;
            description = "Enable blur rendering.";
          };
          optimized = mkNullableOption {
            applies = [ "umbriel" ];
            type = t.bool;
            description = "Share one cached background blur across surfaces on an output.";
          };
          passes = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.ints.between 0 8;
            description = "Blur passes.";
          };
          radius = mkNullableOption {
            applies = [ "umbriel" ];
            type = t.ints.between 0 100;
            description = "Blur radius.";
          };
          offset = mkNullableOption {
            applies = [ "niri" ];
            type = t.float;
            description = "Niri blur offset.";
          };
          noise = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.float;
            description = "Noise overlay from 0.0 to 1.0.";
          };
          brightness = mkNullableOption {
            applies = [ "umbriel" ];
            type = t.float;
            description = "Brightness multiplier from 0.0 to 2.0.";
          };
          contrast = mkNullableOption {
            applies = [ "umbriel" ];
            type = t.float;
            description = "Contrast multiplier from 0.0 to 2.0.";
          };
          saturation = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = t.float;
            description = "Saturation multiplier from 0.0 to 2.0.";
          };
        };
      };
    };
  };
}
