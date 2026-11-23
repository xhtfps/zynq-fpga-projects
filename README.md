# ZYNQ FPGA 入门工程集

正点原子领航者 ZYNQ（XC7Z020）的 Verilog 入门工程集：从点灯到按键、时钟、FIFO、双口 RAM，逐个工程递进，适合当作“每节课一个可上板验证的最小工程”。

## 1. 目录一览

| 目录 | 内容 |
| --- | --- |
| `led_twinkle/` | 计数器分频闪烁灯（时序入门） |
| `breath_led/` | PWM 呼吸灯 |
| `key_led/` | 按键消抖 + 灯态切换 |
| `key_beep/` | 按键控制蜂鸣器 |
| `ip_clk_wiz/` | 时钟 IP（MMCM/PLL）产生多频时钟 |
| `ip_fifo/` | FIFO IP 读写与空满标志 |
| `ip_1port_ram/` | 单口 RAM IP 读写验证 |

## 2. 环境

| 项 | 要求 |
| --- | --- |
| 开发板 | 正点原子领航者 ZYNQ（XC7Z020） |
| 工具 | Vivado 2019.1 及以上（无 Vivado 无法综合） |
| 仿真 | Vivado Simulator（`sim_1` 一键跑） |
| 下载 | JTAG（板载下载器），下载 `.bit` 后观察现象 |

## 3. 快速开始与关键实现

1. 打开对应目录下的 `.xpr`，Vivado 自动加载工程。
2. `Run Synthesis` → `Run Implementation` → `Generate Bitstream`。
3. 打开 Hardware Manager，Program Device 下载 `.bit`，按工程说明操作按键观察现象。
4. 关键点：所有工程共用 50 MHz 板载时钟，改分频先算清计数值（`cnt_max = f_clk / (2*f_out)`）。
5. 按键必须消抖（20 ms 计数器），否则一次按下会触发多次状态切换。

## 4. 常见问题

- **综合报找不到 IP**：IP 目录（`*.xci`）未随仓库同步，先在 Vivado 里重新生成 IP。
- **下载后无现象**：确认约束文件里的引脚与板子原理图一致，特别是 LED/按键的 bank 电压。
- **时序不收敛**：小工程一般不会，若出现先检查未约束的跨时钟路径。
- **工程打不开提示版本不符**：Vivado 版本差异导致，用高版本打开后重新 Generate。

## 5. 维护说明

- 只交源码、约束与 IP 配置；综合产物与 `.bit` 不入库，见 [`EXCLUDED_FILES.md`](EXCLUDED_FILES.md)。
- 与 `zynq-navigator-board` 的分工：本仓库是自己写的 FPGA 工程，后者是厂商资料镜像（含 Vitis/Linux 教程）。
- 引用自正点原子教程的结构版权归原作者。
