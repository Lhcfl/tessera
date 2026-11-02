{ lib, ... }: with lib.types; {
  workspace-id = oneOf [
    str
    int
  ];

  direction = enum [
    "Left"
    "Right"
    "Up"
    "Down"
  ];

  step = enum [
    "Previous"
    "Next"
  ];

  unit = submodule { options = { }; };
}