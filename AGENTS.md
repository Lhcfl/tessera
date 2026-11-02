# tessera

面向多种平铺 Wayland compositor 的统一设置层。

> 现状：从 `~/nixos/home/modules/gui/wm` 原样复制而来，结构与代码未做改动。
> 规划和改造由作者本人进行。

## 文件

```
default.nix     选项定义（funkcia.hm.gui.wm）
keybinding.nix  跨 WM 的语义化 keybinding 定义
niri.nix        niri 后端
umbriel.nix     umbriel 后端
udiskie.nix     会话的可移动设备自动挂载
flake.nix       Home Manager 模块导出
```

## 注意

- 模块通过 `inputs.nix-kdl` 取 KDL 构造器，需要宿主提供 `inputs`
  （`~/nixos` 里是 extraSpecialArgs）。
- `niri.nix` 里 `n (niriKey key) params body` 的 body 是裸节点，nix-kdl 会把它当作
  参数处理，求值时会报 `cannot convert a function to JSON`；body 需要包成 list
  （`[ body ]`）。
- `umbriel.nix` 的 `screenshot` 动作直接读取 `config.funkcia.hm.gui.noctalia.enable`。
