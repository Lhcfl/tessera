# tessera

面向多种平铺 Wayland compositor 的统一会话设置层，以 Home Manager（和 Hjem）模块
的形式发布。

名字取自马赛克里的一小块砖：既指 *tiling*，也指许多小块拼成一个整体。

本文件记录**现有实现**的结构与约定，不是设计提案。改代码前先读这里。

## 目录

```
flake.nix                 导出 homeModules / hjemModules
modules/
  home-manager.nix        把 tessera.*.out 映射到 home.file
  hjem.nix                把 tessera.*.out 映射到 hjem（尚未验证，见“已知问题”）
src/
  default.nix             汇总 options 与 backends
  options/
    default.nix           tessera.settings.*：会话语义
    keybinding.nix        tessera.settings.keybinding + 动作词汇表
  backends/
    niri.nix              渲染成 KDL
    umbriel.nix           渲染成 TOML 形状的 attrset
  lib/
    default.nix           各 backend 共用：match / percentage / mkDestination / …
    types.nix             共用类型：workspace-id / direction / step / unit
```

## 数据流

```
tessera.settings.*  ──┐
                      ├─> backend 渲染 ─> tessera.<backend>.out.{target,text,source}
tessera.<backend>.{provide,includes} ──┘
                                              │
                          modules/*.nix ──────┴─> home.file / hjem files
```

backend **不写文件**，只产出 `out`（目标路径 + 内容）和 `includes`（额外的
`include` 条目）。落盘由 `modules/` 里那一层负责，这样同一份渲染结果可以接到
Home Manager 或别的文件系统抽象上。

## 选项

### 会话（`tessera.settings`）

- `general.autostart`：会话启动命令，`listOf str`，backend 用 shell 执行。
- `environment`：会话环境变量，`attrsOf str`。
- `input.follow-mouse` / `input.follow-mouse-max-scroll` / `input.mouse-follows-focus`
- `layout.preset-column-widths`：`resize-preset` 循环的宽度比例。
- `keybinding`：`attrsWith`，键名 → `{ actions, allow-when-locked, title }`；
  `actions` 是 `attrTag`，因此**一个键恰好一个动作**，这是类型层面保证的。

### 动作词汇表

动作名取 umbriel `umbriel msg` 的名字，并写成 `对象-动词`：umbriel 里拆成
`window-focus-left` / `workspace-previous` 之类的，在 tessera 里是带载荷的一个动作。

| 动作 | 载荷 | 说明 |
| --- | --- | --- |
| `spawn` | `str` | 按 shell 执行 |
| `workspace-switch` | `workspace-id` | 切到指定 workspace |
| `workspace-focus` | `step` | 上一个/下一个 workspace |
| `workspace-move` | `direction` | 移动当前 workspace |
| `window-focus` | `direction` | 按方向聚焦 |
| `window-move` | `direction` | 按方向移动窗口 |
| `window-move-to-workspace` | `workspace-id` | |
| `column-focus-tab` | `step` | 上一个/下一个 tab |
| `window-close` / `window-toggle-floating` / `window-toggle-pinned` | `unit` | |
| `window-toggle-maximize` / `window-toggle-fullscreen` | `unit` | |
| `window-cycle-primary-extent` | `unit` | 对应原来的 `resize-preset` |
| `column-toggle-tabbed` | `unit` | |
| `window-toggle-scratchpad` / `scratchpad-toggle` | `unit` | |
| `cheatsheet-toggle` / `session-quit` | `unit` | |
| `screenshot` | `unit` | tessera 扩展，不是 umbriel 的动作 |

`direction` ∈ `Left/Right/Up/Down`，`step` ∈ `Previous/Next`（见 `src/lib/types.nix`）。

载荷可以是字面值，也可以是**函数**，函数会收到 backend 的 context。context 由
`tessera.<backend>.provide` 决定：

- niri：`{ workspace.empty.id = 255; }`
- umbriel：`{ workspace.empty.id = 64; }`

所以跨 compositor 写 `workspace-switch = ctx: ctx.workspace.empty.id`。

### 每个 backend（`tessera.<backend>`）

- `enable`：`mkEnableOption`。
- `provide`：`mkProvideContextOptions`，目前只有 `workspace.empty.id`。
- `out = mkDestination`：`target`（相对 HOME 的路径）、`text`（KDL 文本，可空）、
  `source`（`types.path`，默认是 `pkgs.writeText` 的 `text`）。
- `includes`：`listOf { optional, source }`，渲染成 compositor 的 include。
- umbriel 额外有 `settings`（`toml.type`）：最终的 TOML 结构，`out.source` 由它
  `toml.generate` 而来。用户可以覆盖其中任意字段。

## 实现约定

1. **`match` 查表**：`match = str: defs: defs.${str} or defs.default;`，backend 里
   按动作名/枚举值分派，和原 `~/nixos` 代码的写法保持一致。
2. **nix-kdl 的 body 必须是 list**。`n` 把任何 attrset 当参数，所以
   `n key params body` 里裸的节点会被塞进 `properties` 并在序列化时报
   `cannot convert a function to JSON`。当前用 `mapAttrsToList` 得到 list 正好规避。
3. **`toml.type` 是递归的**（`attrsOf` 套 `either`），而 `config.tessera.umbriel.settings`
   属于模块配置，`pushDownProperties` 会下钻到任意深度（包括列表），所以
   `lib.mkDefault` / `lib.mkIf` / `lib.mkMerge` 在那里都能正常工作。反之，
   **作为函数参数传入的普通 attrset**（例如 `toml.generate "…" { … }`）不是模块
   配置，组合器会被原样序列化成 `_type = "…"`。
4. **include 的相对路径**：`niri.nix`/`umbriel.nix` 生成的 include 用相对路径
   （如 `tessera/…` 或用户给的 `customize.kdl`），相对的是 compositor 自己的配置
   目录，因此 `out` 必须落在 `~/.config/<compositor>/` 下。
5. `mkDestination` 里声明 `pkgs`/`config` 参数的 submodule 用的是 Home Manager 的
   模块参数；在裸 `evalModules` 里手搓测试环境时，需要自己提供 `_module.args.pkgs`。

## 已知问题 / 待办

- `modules/hjem.nix` 用的是 `config.file`；Hjem 的用户级选项是 `files`，且文件
  子模块不一定有 `target`。这个 output 尚未验证。
- `mkIncludes.source` 只接受 `str`；要支持 `source = ./x.kdl` 需放宽类型
  （`either str path`）。
- niri 的 include 恒写出 `optional=false`，可用
  `lib.optionalAttrs item.optional { optional = true; }` 精简。
- 空值会留下噪音：`[environment]`、`[include] files = []`。
- `umbriel` 的 `screenshot` 硬编码 `noctalia msg screenshot-fullscreen`，没有
  noctalia 时是死键；可用 `tessera.umbriel.settings.keybinds.<key>.action` 覆盖。
- `spawn` 的动作类型是 `str`；旧配置里的 `actions.spawn = [ … ]` 需要改成字符串，
  `actions.spawn-sh` 已不存在。
- statix 仍报 `src/backends/niri.nix` 里 `{ optional = item.optional; }` 应写成
  `{ inherit (item) optional; }`。
- `flake.nix` 导出的 `homeModules`、`hjemModules` 不是 flake 已知的 output，
  `nix flake check` 会给出 warning（不影响使用）。

## 验证

```fish
nix flake check path:$PWD
statix check .
```

端到端（真实 Home Manager）：

```nix
let
  nf = builtins.getFlake "path:/home/linca/nixos";
  hm = nf.inputs.home-manager;
  tessera = builtins.getFlake "path:/home/linca/Projects/tessera";
in
(hm.lib.homeManagerConfiguration {
  pkgs = nf.inputs.nixpkgs.legacyPackages.x86_64-linux;
  modules = [
    tessera.homeModules.default
    {
      home.username = "linca";
      home.homeDirectory = "/home/linca";
      home.stateVersion = "25.11";
      tessera.niri.enable = true;
      tessera.umbriel.enable = true;
      tessera.settings.keybinding."Mod+Q".actions.close-window = { };
    }
  ];
}).config.home.file
```

检查渲染结果：`config.home.file.niri.text`，以及
`config.home.file.umbriel.source`（是个 derivation，需要 build 后看内容）。

## 宿主接入

```nix
{
  imports = [ inputs.tessera.homeModules.default ];

  tessera.niri.enable = true;
  tessera.umbriel.enable = true;
  tessera.settings.keybinding = {
    "Mod+Q".actions.close-window = { };
    "Mod+N".actions.focus-workspace = ctx: ctx.workspace.empty.id;
  };
}
```

`flake.nix` 通过 `_module.args` 把 `nix-kdl` 传给模块，所以宿主不需要额外
`extraSpecialArgs`；若宿主同时也定义了 `_module.args.nix-kdl` 会冲突。

## 来源

从 `~/nixos/home/modules/gui/wm` 抽离而来，随后重构成了
options / backends / lib 三层。`~/nixos` 侧尚未迁移。
