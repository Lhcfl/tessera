{
  lib,
  ...
}:
let
  inherit
    (import ../lib {
      inherit lib;
      pkgs = null;
      name = "window-rule";
    })
    mkOption
    mkNullableOption
    ;

  anchor =
    with lib.types;
    enum [
      "center"
      "top_left"
      "top_right"
      "bottom_left"
      "bottom_right"
      "top"
      "bottom"
      "left"
      "right"
    ];

  sizePx =
    with lib.types;
    submodule {
      options = {
        width = mkNullableOption {
          applies = [ "umbriel" ];
          type = int;
          description = "Width in logical pixels.";
        };
        height = mkNullableOption {
          applies = [ "umbriel" ];
          type = int;
          description = "Height in logical pixels.";
        };
      };
    };

  sizeFraction =
    with lib.types;
    submodule {
      options = {
        width = mkNullableOption {
          applies = [ "umbriel" ];
          type = float;
          description = "Fraction of the output's usable width.";
        };
        height = mkNullableOption {
          applies = [ "umbriel" ];
          type = float;
          description = "Fraction of the output's usable height.";
        };
      };
    };

  position =
    with lib.types;
    submodule {
      options = {
        x = mkNullableOption {
          applies = [
            "niri"
            "umbriel"
          ];
          type = int;
          description = "Horizontal offset in logical pixels, measured from the anchor.";
        };
        y = mkNullableOption {
          applies = [
            "niri"
            "umbriel"
          ];
          type = int;
          description = "Vertical offset in logical pixels, measured from the anchor.";
        };
        anchor = mkNullableOption {
          applies = [
            "niri"
            "umbriel"
          ];
          type = anchor;
          description = "Position anchor; defaults to the center.";
        };
      };
    };

  gradient =
    with lib.types;
    submodule {
      options = {
        from = mkNullableOption {
          applies = [ "niri" ];
          type = str;
          description = "Start color.";
        };
        to = mkNullableOption {
          applies = [ "niri" ];
          type = str;
          description = "End color.";
        };
        angle = mkNullableOption {
          applies = [ "niri" ];
          type = number;
          description = "CSS-like angle in degrees; defaults to 180.";
        };
        "in" = mkNullableOption {
          applies = [ "niri" ];
          type = str;
          description = ''Gradient interpolation color space, such as "srgb-linear" or "oklch longer hue".'';
        };
        relative_to = mkNullableOption {
          applies = [ "niri" ];
          type = enum [
            "window"
            "workspace-view"
          ];
          description = "Render the gradient relative to the window or to the whole workspace view.";
        };
      };
    };

  ring =
    with lib.types;
    submodule {
      options = {
        on = mkNullableOption {
          applies = [ "niri" ];
          type = bool;
          description = "Force-enable the focus ring or border for this window.";
        };
        off = mkNullableOption {
          applies = [ "niri" ];
          type = bool;
          description = "Disable the focus ring or border for this window. `on` takes precedence.";
        };
        width = mkNullableOption {
          applies = [ "niri" ];
          type = number;
          description = "Thickness in logical pixels.";
        };
        active_color = mkNullableOption {
          applies = [ "niri" ];
          type = str;
          description = "Color around the active window.";
        };
        inactive_color = mkNullableOption {
          applies = [ "niri" ];
          type = str;
          description = "Color around other windows.";
        };
        urgent_color = mkNullableOption {
          applies = [ "niri" ];
          type = str;
          description = "Color around windows requesting attention.";
        };
        active_gradient = mkNullableOption {
          applies = [ "niri" ];
          type = gradient;
          description = "Gradient around the active window; takes precedence over active_color.";
        };
        inactive_gradient = mkNullableOption {
          applies = [ "niri" ];
          type = gradient;
          description = "Gradient around other windows; takes precedence over inactive_color.";
        };
        urgent_gradient = mkNullableOption {
          applies = [ "niri" ];
          type = gradient;
          description = "Gradient around windows requesting attention; takes precedence over urgent_color.";
        };
      };
    };

  tabIndicator =
    with lib.types;
    submodule {
      options = {
        on = mkNullableOption {
          applies = [ "niri" ];
          type = bool;
          description = "Force-enable the tab indicator.";
        };
        off = mkNullableOption {
          applies = [ "niri" ];
          type = bool;
          description = "Disable the tab indicator.";
        };
        hide_when_single_tab = mkNullableOption {
          applies = [ "niri" ];
          type = bool;
          description = "Hide the indicator for tabbed columns with a single window.";
        };
        place_within_column = mkNullableOption {
          applies = [ "niri" ];
          type = bool;
          description = "Place the indicator inside the column instead of overlaying adjacent columns.";
        };
        gap = mkNullableOption {
          applies = [ "niri" ];
          type = number;
          description = "Gap between the indicator and the window in logical pixels; may be negative.";
        };
        width = mkNullableOption {
          applies = [ "niri" ];
          type = number;
          description = "Indicator thickness in logical pixels.";
        };
        length = mkNullableOption {
          applies = [ "niri" ];
          type = submodule {
            options = {
              total_proportion = mkNullableOption {
                applies = [ "niri" ];
                type = float;
                description = "Indicator length relative to the window size.";
              };
            };
          };
          description = "Indicator length.";
        };
        position = mkNullableOption {
          applies = [ "niri" ];
          type = enum [
            "left"
            "right"
            "top"
            "bottom"
          ];
          description = "Indicator position relative to the window.";
        };
        gaps_between_tabs = mkNullableOption {
          applies = [ "niri" ];
          type = number;
          description = "Gap between individual tabs in logical pixels.";
        };
        corner_radius = mkNullableOption {
          applies = [ "niri" ];
          type = number;
          description = "Rounded corner radius for tabs in logical pixels.";
        };
        active_color = mkNullableOption {
          applies = [ "niri" ];
          type = str;
          description = "Color for the active tab.";
        };
        inactive_color = mkNullableOption {
          applies = [ "niri" ];
          type = str;
          description = "Color for inactive tabs.";
        };
        urgent_color = mkNullableOption {
          applies = [ "niri" ];
          type = str;
          description = "Color for tabs requesting attention.";
        };
        active_gradient = mkNullableOption {
          applies = [ "niri" ];
          type = gradient;
          description = "Gradient for the active tab; takes precedence over active_color.";
        };
        inactive_gradient = mkNullableOption {
          applies = [ "niri" ];
          type = gradient;
          description = "Gradient for inactive tabs; takes precedence over inactive_color.";
        };
        urgent_gradient = mkNullableOption {
          applies = [ "niri" ];
          type = gradient;
          description = "Gradient for tabs requesting attention; takes precedence over urgent_color.";
        };
      };
    };

  backgroundEffect =
    with lib.types;
    submodule {
      options = {
        xray = mkNullableOption {
          applies = [ "niri" ];
          type = bool;
          description = "Enable or disable the xray background effect.";
        };
        noise = mkNullableOption {
          applies = [ "niri" ];
          type = float;
          description = "Amount of pixel noise added to the background.";
        };
        saturation = mkNullableOption {
          applies = [ "niri" ];
          type = float;
          description = "Background color saturation, where 1.0 is normal.";
        };
      };
    };

  cornerRadius = with lib.types; either number (listOf number);

  popups =
    with lib.types;
    submodule {
      options = {
        opacity = mkNullableOption {
          applies = [ "niri" ];
          type = float;
          description = "Popup surface opacity from 0.0 to 1.0.";
        };
        geometry_corner_radius = mkNullableOption {
          applies = [ "niri" ];
          type = cornerRadius;
          description = "Popup corner radius: one value or four CSS-order values.";
        };
        background_effect = mkNullableOption {
          applies = [ "niri" ];
          type = backgroundEffect;
          description = "Background effect for this window's popups.";
        };
      };
    };

  columnSize =
    with lib.types;
    submodule {
      options = {
        fixed = mkNullableOption {
          applies = [ "niri" ];
          type = int;
          description = "Fixed size in logical pixels.";
        };
        proportion = mkNullableOption {
          applies = [ "niri" ];
          type = float;
          description = "Fraction of the output's usable size.";
        };
      };
    };

  matchBlock =
    with lib.types;
    submodule {
      options = {
        app_id = mkNullableOption {
          applies = [
            "niri"
            "umbriel"
          ];
          type = str;
          description = "Match the application ID with a regular expression.";
        };
        title = mkNullableOption {
          applies = [
            "niri"
            "umbriel"
          ];
          type = str;
          description = "Match the window title.";
        };
        xdg_tag = mkNullableOption {
          applies = [ "umbriel" ];
          type = str;
          description = "Match a client-defined XDG toplevel tag.";
        };
        content_type = mkNullableOption {
          applies = [ "umbriel" ];
          type = enum [
            "none"
            "photo"
            "video"
            "game"
          ];
          description = ''Match "none", "photo", "video", or "game".'';
        };
        is_focused = mkNullableOption {
          applies = [
            "niri"
            "umbriel"
          ];
          type = bool;
          description = "Match current focus state.";
        };
        is_urgent = mkNullableOption {
          applies = [ "niri" ];
          type = bool;
          description = "Match windows requesting the user's attention.";
        };
        is_floating = mkNullableOption {
          applies = [
            "niri"
            "umbriel"
          ];
          type = bool;
          description = "Match current floating state.";
        };
        is_maximized_to_edges = mkNullableOption {
          applies = [ "umbriel" ];
          type = bool;
          description = "Match current maximized-to-edges state.";
        };
        is_pinned = mkNullableOption {
          applies = [ "umbriel" ];
          type = bool;
          description = "Match current pinned state.";
        };
        is_scratchpad = mkNullableOption {
          applies = [ "umbriel" ];
          type = bool;
          description = "Match current scratchpad state.";
        };
        is_alone = mkNullableOption {
          applies = [ "umbriel" ];
          type = bool;
          description = "Match whether this is the only tiled window.";
        };
        is_only_window = mkNullableOption {
          applies = [ "umbriel" ];
          type = bool;
          description = "Match whether this is the only window on its workspace, floating ones included.";
        };
        is_dialog = mkNullableOption {
          applies = [ "umbriel" ];
          type = bool;
          description = "Match whether the application named a parent window for it.";
        };
        is_cast_target = mkNullableOption {
          applies = [
            "niri"
            "umbriel"
          ];
          type = bool;
          description = "Match while a screencast or screenshot is capturing this window.";
        };
        at_startup = mkNullableOption {
          applies = [
            "niri"
            "umbriel"
          ];
          type = bool;
          description = "Match during or after the first 60 seconds.";
        };
      };
    };

  matchType = lib.types.nullOr (lib.types.either matchBlock (lib.types.listOf matchBlock));
in
{
  options.tessera.settings.window-rule = mkOption {
    applies = [
      "niri"
      "umbriel"
    ];
    default = { };
    description = ''
      window rule settings. every rule should have a unique name.

      Window rules apply settings to matching applications. Every matching
      rule contributes its values; when two set the same field, the later
      rule wins.
    '';
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          order = mkOption {
            type = lib.types.raw;
            default = x: x;
            description = ''
              One of `lib.mkBefore`, `lib.mkAfter`, or `lib.mkOrder <number>`.
            '';
          };

          match = mkOption {
            applies = [
              "niri"
              "umbriel"
            ];
            default = null;
            description = ''
              match rules. A single block, a list of blocks, or null to match
              every window.

              The list is combined with OR: the rule matches when any block
              matches. Within one block all selectors are combined with AND.
              Selectors are optional; a block with none matches every window.
              Regular expressions match any part of a value, so use `^` and `$`
              for an exact match.
            '';
            type = matchType;
          };
        }
        // (with lib.types; {
          # Settings applied when a window opens.
          default_output = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = str;
            description = "Open on a connector or monitor name.";
          };
          default_workspace = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = either int str;
            description = "Open on a one-based position (int) or exact, case-sensitive workspace name (str).";
          };
          default_scratchpad = mkNullableOption {
            applies = [ "umbriel" ];
            type = str;
            description = ''Store in the implicit ("default") or a configured scratchpad.'';
          };
          default_fullscreen = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = bool;
            description = "Open fullscreen.";
          };
          default_floating = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = bool;
            description = "Force floating or tiling.";
          };
          default_maximize = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = bool;
            description = "Open maximized within normal layout bounds.";
          };
          default_maximize_to_edges = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = bool;
            description = "Open maximized without gaps, struts, or borders.";
          };
          default_focused = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = bool;
            description = "Override whether the new window takes focus. Use true to focus and reveal a floating window above fullscreen.";
          };
          default_pinned = mkNullableOption {
            applies = [ "umbriel" ];
            type = bool;
            description = "Open pinned above normal windows.";
          };

          default_scrolling_column = mkNullableOption {
            applies = [ "umbriel" ];
            type = str;
            description = "Join matching windows into one named scrolling column.";
          };
          default_scrolling_column_order = mkNullableOption {
            applies = [ "umbriel" ];
            type = int;
            description = "Set order inside a named scrolling column.";
          };
          default_column_display = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = enum [
              "tabbed"
              "normal"
            ];
            description = ''Show the column the window opens in as "tabbed" or "normal".'';
          };

          default_floating_size_px = mkNullableOption {
            applies = [ "umbriel" ];
            type = sizePx;
            description = "Floating logical-pixel size, such as { width = 800; height = 600; }. Takes precedence over default_floating_size.";
          };
          default_floating_size = mkNullableOption {
            applies = [ "umbriel" ];
            type = sizeFraction;
            description = "Floating size as a fraction of the output's usable area.";
          };
          default_scrolling_extent_px = mkNullableOption {
            applies = [ "umbriel" ];
            type = int;
            description = "Initial logical-pixel extent along the scrolling strip, up to 4 viewports. Takes precedence over default_scrolling_extent.";
          };
          default_scrolling_extent = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = float;
            description = "Initial fractional extent along the scrolling strip, from 0.1 to 4.0.";
          };
          default_position = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = position;
            description = "Floating position from a named anchor.";
          };

          default_window_height = mkNullableOption {
            applies = [ "niri" ];
            type = columnSize;
            description = "Default height for the new window.";
          };

          attach_to_parent = mkNullableOption {
            applies = [ "umbriel" ];
            type = bool;
            description = "Attach a modal dialog to its parent. Set false to keep it an ordinary window that the placement settings above can place.";
          };

          # Settings updated while a window is open.
          opacity = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = float;
            description = "Surface opacity from 0.0 to 1.0.";
          };
          blur = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = bool;
            description = "Enable or disable window blur, including translucent Umbriel title bars.";
          };
          blur_popups = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = bool;
            description = "Apply blur to descendant XDG popups.";
          };
          blur_ignore_alpha = mkNullableOption {
            applies = [ "umbriel" ];
            type = float;
            description = "Skip blur below an alpha threshold, from 0.0 to 1.0.";
          };
          blur_optimized = mkNullableOption {
            applies = [ "umbriel" ];
            type = bool;
            description = "Override the global optimized-blur choice.";
          };
          confine_pointer = mkNullableOption {
            applies = [ "umbriel" ];
            type = bool;
            description = "Keep the pointer inside this window while it has keyboard focus.";
          };
          allow_shortcuts_inhibit = mkNullableOption {
            applies = [ "umbriel" ];
            type = bool;
            description = "Allow client-requested keyboard shortcut inhibition.";
          };
          block_capture = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = bool;
            description = "Omit this window from screenshots and recordings.";
          };
          background_render = mkNullableOption {
            applies = [ "umbriel" ];
            type = bool;
            description = "Keep this window drawing while hidden.";
          };
          focus_on_activate = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = bool;
            description = "Override activation focus for this window.";
          };
          vrr = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = enum [
              "disabled"
              "always"
              "fullscreen"
            ];
            description = "Override the focused output's VRR policy.";
          };
          tearing = mkNullableOption {
            applies = [ "umbriel" ];
            type = bool;
            description = "Request or veto asynchronous presentation.";
          };
          hdr = mkNullableOption {
            applies = [ "umbriel" ];
            type = enum [
              "off"
              "on"
              "auto"
              "fullscreen"
            ];
            description = "Override the focused output's HDR policy.";
          };

          border_color_focused = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = str;
            description = "Override colors.border.focused.";
          };
          border_color_unfocused = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = str;
            description = "Override colors.border.unfocused.";
          };
          border_color_outer = mkNullableOption {
            applies = [ "umbriel" ];
            type = str;
            description = "Override colors.border.outer.";
          };
          border_width = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = ints.between 0 100;
            description = "Override appearance.border_width.";
          };
          outer_border_width = mkNullableOption {
            applies = [ "umbriel" ];
            type = ints.between 0 100;
            description = "Override appearance.outer_border_width.";
          };
          corner_radius = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = ints.between 0 100;
            description = "Override appearance.corner_radius.";
          };
          shadow = mkNullableOption {
            applies = [
              "niri"
              "umbriel"
            ];
            type = bool;
            description = "Override appearance.shadow.enabled.";
          };
          title_bar = mkNullableOption {
            applies = [ "umbriel" ];
            type = enum [
              "on"
              "negotiated"
              "forced"
              "off"
            ];
            description = "Override appearance.title_bar.mode.";
          };

          title_bar_buttons = mkNullableOption {
            applies = [ "umbriel" ];
            type = listOf (enum [
              "minimize"
              "maximize"
              "close"
            ]);
            description = "Title bar buttons for this window, from the title outward. Overrides appearance.title_bar.buttons.";
          };

          border_effect = mkNullableOption {
            applies = [ "umbriel" ];
            type = str;
            description = ''Replace effects.border with a border preset or pool, or "off" to disable it.'';
          };
          window_effect = mkNullableOption {
            applies = [ "umbriel" ];
            type = str;
            description = ''Replace effects.window with a window preset or pool, or "off" to disable it.'';
          };

          scroll_factor = mkNullableOption {
            applies = [ "niri" ];
            type = float;
            description = "Multiplier for all scroll events sent to the window.";
          };
          pinch_sensitivity = mkNullableOption {
            applies = [ "niri" ];
            type = float;
            description = "Multiplier for pinch gestures sent to the window.";
          };
          draw_border_with_background = mkNullableOption {
            applies = [ "niri" ];
            type = bool;
            description = "Draw the focus ring and border as solid rectangles behind the window.";
          };
          focus_ring = mkNullableOption {
            applies = [ "niri" ];
            type = ring;
            description = "Override focus-ring options for this window.";
          };
          tab_indicator = mkNullableOption {
            applies = [ "niri" ];
            type = tabIndicator;
            description = "Override tab-indicator options for this window.";
          };
          clip_to_geometry = mkNullableOption {
            applies = [ "niri" ];
            type = bool;
            description = "Clip the window to its visual geometry, removing client-side shadows and rounding corners.";
          };
          tiled_state = mkNullableOption {
            applies = [ "niri" ];
            type = bool;
            description = "Tell the window that it is tiled.";
          };
          popups = mkNullableOption {
            applies = [ "niri" ];
            type = popups;
            description = "Override properties for this window's popups.";
          };
          min_width = mkNullableOption {
            applies = [ "niri" ];
            type = int;
            description = "Minimum width in logical pixels.";
          };
          max_width = mkNullableOption {
            applies = [ "niri" ];
            type = int;
            description = "Maximum width in logical pixels.";
          };
          min_height = mkNullableOption {
            applies = [ "niri" ];
            type = int;
            description = "Minimum height in logical pixels.";
          };
          max_height = mkNullableOption {
            applies = [ "niri" ];
            type = int;
            description = "Maximum height in logical pixels.";
          };
        });
      }
    );
  };
}
