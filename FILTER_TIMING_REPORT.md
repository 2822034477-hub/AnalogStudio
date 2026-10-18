> **状态：已按用户要求撤回。当前网页的新生成代码恢复原一阶 / 二阶实现。下文仅保留为历史实验记录，不代表当前采用的实现。**

# 一阶 / 二阶滤波器内部时序优化报告

日期：2026-10-16。仅更新本地 AnalogStudio，未同步 GitHub。

## 结论

保留原有独立 `_fo` / `_so` 子模块、参数接口、SOS 级联顺序和每拍一个样本的吞吐。一阶仍 1 拍、二阶仍 2 拍；四个二阶节仍 8 拍。原系数、AW 位累加语义、舍入及饱和位置保持一致。

同一器件和约束下，以下四个代表案例全部通过 50 MHz 内部建立、保持和脉宽检查，建立裕度较优化前提高。100 MHz 补测三例全部未通过；不能据此宣称支持 100 MHz。不同目标周期会改变布局布线及 DSP 寄存器映射，改善不保证随时钟约束单调变化。

## 约束和测量方法

- 工具：Vivado 2022.2；器件：xc7a50tfgg484-1。
- 流程：OOC `synth_design → opt_design → place_design → phys_opt_design → route_design`，最大 2 个工具线程。
- 分别以 20 ns（50 MHz）及 10 ns（100 MHz）重新执行完整流程，不以行为仿真的时钟周期推断可实现频率。
- setup / hold 用户不确定度分别 0.200 / 0.050 ns；同一时钟，无 false path、multicycle path 或额外反馈延迟。
- 对比使用相同系数、位宽、顶层和约束，仅改变模块内部实现。
- 每次保存 RTL SHA-256、约束、真实报告和路径指标。原始执行 Tcl 保留；`reproduce.tcl` 只把源码路径改为同目录的实际 RTL，便于复现。

案例模型保留原来的 48 kHz 采样率标签和系数；这里用 50 / 100 MHz 测量 RTL 的实现时序，没有改变系数，也没有内部降采样。实际每拍接收数据时，物理采样率等于输入时钟频率；频率响应应按实际采样率解读。

## 50 MHz 时序裕度

单位均为 ns；WNS 越大，最坏建立路径的裕度越多。WHS 是最坏保持裕度。

| 案例 | 优化前 WNS | 优化后 WNS | 变化 | 优化后 WHS | 结果 |
|---|---:|---:|---:|---:|---|
| 默认一阶低通（B1=0） | 5.262 | 5.298 | +0.036 | 0.911 | 通过 |
| 一阶通用示例（B1≠0） | 5.198 | 5.861 | +0.663 | 0.608 | 通过 |
| 二阶陷波示例 | 4.732 | 4.994 | +0.262 | 0.084 | 通过 |
| 八阶：四个二阶节级联 | 3.193 | 3.639 | +0.446 | 0.133 | 通过 |

四例优化前后 TNS、THS、TPWS 均为 0，建立/保持/脉宽失败端点均为 0；没有未约束内部端点、无时钟寄存器或组合环路，路由错误为 0。详细的 WPWS、端点数量和约束检查见 JSON 与原始报告。

## 资源代价（50 MHz）

| 案例 | LUT：前 → 后 | Fabric FF：前 → 后 | DSP：前 → 后 |
|---|---:|---:|---:|
| 默认一阶低通（B1=0） | 102 → 73 | 16 → 16 | 2 → 2 |
| 一阶通用示例（B1≠0） | 132 → 102 | 16 → 16 | 3 → 3 |
| 二阶陷波示例 | 233 → 177 | 32 → 72 | 5 → 5 |
| 八阶：四个二阶节级联 | 981 → 756 | 152 → 268 | 20 → 20 |

Fabric FF 不含 DSP 内部寄存器。二阶节新增完整精度的历史合并寄存器，使用更多 Fabric FF，换取更少的组合归并逻辑；没有缩减用户指定的累加位宽。零系数及未使用位会由综合器消除。

## 100 MHz 实测

| 案例 | 优化前 WNS / ns | 优化后 WNS / ns | 结果 |
|---|---:|---:|---|
| 一阶通用示例（B1≠0） | -3.261 | -3.322 | 未通过 |
| 二阶陷波示例 | -4.267 | -3.753 | 未通过 |
| 八阶：四个二阶节级联 | -5.179 | -4.510 | 未通过 |

一阶通用示例在 100 MHz 约束下比原实现略差，报告保留该结果。这里的优化以既有 50 MHz 工作点和级联整体行为为验收依据。不要把 `1 / 组合数据路径延迟` 当成最高主频：建立时间、时钟偏斜及不确定度也计入裕度；改变目标周期应重新实现。

## 一阶实现

令 x[n] 是当前输入，y[n] 是当前数学输出；Q 表示原有的系数小数位缩放、舍入和输出饱和。采用完整乘积寄存器：

```text
history[n] = B1*x[n-1]
P_A1[n]    = A1*y[n-1]
acc[n]     = B0*x[n] + history[n] - P_A1[n]
y[n]       = Q(acc[n])

时钟沿更新：
history[n+1] = B1*x[n]
P_A1[n+1]    = A1*y[n]
输出寄存器   = y[n]
```

反馈乘积与输出状态同时更新，仍只有一个样本的递归延迟。B1 乘法移到历史寄存器之前，A1 乘法移到乘积寄存器之前。没有给反馈方程增加一拍。

## 二阶实现

把较早的输入与第二反馈项提前合并，存入 AW 位 `history`：

```text
history[n] = B1*x[n-1] + B2*x[n-2] - A2*y[n-2]
acc[n]     = B0*x[n] + history[n] - A1*y[n-1]
y[n]       = Q(acc[n])

时钟沿更新：
history[n+1] = B1*x[n] + B2*x[n-1] - A2*y[n-1]
x1           = x[n]
y1           = y[n]
y2           = 旧 y1
模块输出      = y2
```

当前输出路径由五个加减项变成三个项；历史路径也独立合并三个项。两个合并点使用进位保留的三项压缩与一次最终进位传播加法。对 `a+b-c`，压缩后的左移进位向量最低位为 0，直接把补码加 1 放入该位，省去原来的常数补偿压缩层。

历史项只做 AW 位模运算，未提前舍入或饱和。模加减满足结合律，因此最终 acc 与直接式的 AW 位结果相同；Q 的执行位置不变。外部依旧输出 y2，保持原来的二阶 2 拍契约。

## 未采用的二阶乘积寄存方案

额外尝试把 A1、A2 两个乘积都保存到寄存器。孤立二阶节在 50 MHz 的 WNS 为 5.242 ns，比历史项合并方案的 4.994 ns 略高；但八阶级联下降到 1.505 ns，低于优化前的 3.193 ns。因此最终二阶实现采用历史项合并方案，八阶级联 WNS 为 3.639 ns。该实验说明必须检查级联整体，单个模块的最优寄存器位置不保证给整个系统带来同样改善。

## 最终 50 MHz 候选关键路径

| 案例 | 起点 | 终点 | 数据路径延迟 / ns | 逻辑级数 |
|---|---|---|---:|---:|
| 默认一阶低通（B1=0） | `s0/P_A1_reg/CLK` | `s0/P_A1_reg/A[5]` | 10.696 | 16 |
| 一阶通用示例（B1≠0） | `s0/history_reg/CLK` | `s0/P_A1_reg/A[2]` | 10.133 | 17 |
| 二阶陷波示例 | `s0/P_A1/CLK` | `s0/P_A2/A[14]` | 14.360 | 17 |
| 八阶：四个二阶节级联 | `s2/P_A1/CLK` | `s3/P_B0/A[28]` | 15.715 | 17 |

反馈回路中仍存在“乘法、归并、舍入/饱和”的单拍约束，所以此次改善有限。报告中的路径名称是实际综合映射后的 DSP/寄存器引脚，不等同于源码变量的表面边界。

## 数值、延迟与兼容性验证

- XSim 2022.2：24 个完整滤波器与 20 组独立 FO/SO 配置，14,316 次逐拍独立数学期望值及优化前后比较通过；包含两次同步复位。
- 独立算术探针：20 组配置、6,084 次 AW 位历史合并/归并/舍入/饱和检查通过；另有 90,112 次舍入恒等式检查。
- 系统工作台：4,000 拍去直流反馈、4,000 拍同一保存滤波器的两个实例级联及基础模块检查通过。
- 完整 Node / jsdom 回归：47 PASS、0 FAIL、0 SKIP。
- 24 组模型、golden、testbench 和 runner 字节未改，只更新对应 RTL。旧保存滤波器包仍精确校验并保留原 Verilog，明确重新保存才生成新实现。

验证为已测配置/输入的行为检查，未做全系数空间形式证明。真实浏览器 file:// 页面及系统文件选择器未验证。

## 测量范围

这是 OOC 内部时序报告，输入和输出没有板级 input_delay / output_delay，未包含顶层 BUFG/PLL/MMCM、板级时钟树和引脚约束。每例记录了 17 个无 input_delay 的输入及 16 个无 output_delay 的输出；这些边界没有被本报告签核。没有门级 SDF 或实物运行。结果只对应下面的精确系数与位宽，不能保证任意用户设计。

## 精确案例参数

### 默认一阶低通（B1=0）

输入/输出 16 位，系数 18 位 / F=15，节间 16 位，累加器 40 位，nearest 舍入；总 1 拍。

```text
节 1: B=[6554], A=[32768, -26214]
```

### 一阶通用示例（B1≠0）

输入/输出 16 位，系数 18 位 / F=15，节间 16 位，累加器 40 位，nearest 舍入；总 1 拍。

```text
节 1: B=[6554, 3277], A=[32768, -26214]
```

### 二阶陷波示例

输入/输出 16 位，系数 18 位 / F=15，节间 16 位，累加器 40 位，nearest 舍入；总 2 拍。

```text
节 1: B=[31269, -44222, 31269], A=[32768, -44024, 29573]
```

### 八阶：四个二阶节级联

输入/输出 16 位，系数 18 位 / F=15，节间 20 位，累加器 44 位，nearest 舍入；总 8 拍。

```text
节 1: B=[15343, 5830, 1672], A=[32768, -13107, 1707]
节 2: B=[11193, 5596, 1241], A=[32768, -19661, 3757]
节 3: B=[10977, 1537, 1557], A=[32768, -26214, 6607]
节 4: B=[7950, 2067, 948], A=[32768, -32768, 10256]
```

## 报告与复现文件

结构化指标、端点检查、精确参数及文件 SHA-256 见 [filter-retiming-validation.json](filter-retiming-validation.json)。在对应证据目录运行本机已有的 Vivado：`vivado -mode batch -source reproduce.tcl -notrace`。不安装或更改工具及许可证。

- 默认一阶低通（B1=0） · 优化前 · 50 MHz：[时序汇总](timing-evidence/lowpass-before-chosen-20ns/timing_summary.rpt)、[建立路径](timing-evidence/lowpass-before-chosen-20ns/internal_setup.rpt)、[资源](timing-evidence/lowpass-before-chosen-20ns/utilization_routed.rpt)、[实际 RTL](timing-evidence/lowpass-before-chosen-20ns/digital_filter.v)、[复现 Tcl](timing-evidence/lowpass-before-chosen-20ns/reproduce.tcl)。
- 默认一阶低通（B1=0） · 优化后 · 50 MHz：[时序汇总](timing-evidence/lowpass-after-chosen-20ns/timing_summary.rpt)、[建立路径](timing-evidence/lowpass-after-chosen-20ns/internal_setup.rpt)、[资源](timing-evidence/lowpass-after-chosen-20ns/utilization_routed.rpt)、[实际 RTL](timing-evidence/lowpass-after-chosen-20ns/digital_filter.v)、[复现 Tcl](timing-evidence/lowpass-after-chosen-20ns/reproduce.tcl)。
- 一阶通用示例（B1≠0） · 优化前 · 50 MHz：[时序汇总](timing-evidence/fo-before-20ns/timing_summary.rpt)、[建立路径](timing-evidence/fo-before-20ns/internal_setup.rpt)、[资源](timing-evidence/fo-before-20ns/utilization_routed.rpt)、[实际 RTL](timing-evidence/fo-before-20ns/digital_filter.v)、[复现 Tcl](timing-evidence/fo-before-20ns/reproduce.tcl)。
- 一阶通用示例（B1≠0） · 优化后 · 50 MHz：[时序汇总](timing-evidence/fo-after-chosen-20ns/timing_summary.rpt)、[建立路径](timing-evidence/fo-after-chosen-20ns/internal_setup.rpt)、[资源](timing-evidence/fo-after-chosen-20ns/utilization_routed.rpt)、[实际 RTL](timing-evidence/fo-after-chosen-20ns/digital_filter.v)、[复现 Tcl](timing-evidence/fo-after-chosen-20ns/reproduce.tcl)。
- 二阶陷波示例 · 优化前 · 50 MHz：[时序汇总](timing-evidence/so-before-20ns/timing_summary.rpt)、[建立路径](timing-evidence/so-before-20ns/internal_setup.rpt)、[资源](timing-evidence/so-before-20ns/utilization_routed.rpt)、[实际 RTL](timing-evidence/so-before-20ns/digital_filter.v)、[复现 Tcl](timing-evidence/so-before-20ns/reproduce.tcl)。
- 二阶陷波示例 · 优化后 · 50 MHz：[时序汇总](timing-evidence/so-after-chosen-20ns/timing_summary.rpt)、[建立路径](timing-evidence/so-after-chosen-20ns/internal_setup.rpt)、[资源](timing-evidence/so-after-chosen-20ns/utilization_routed.rpt)、[实际 RTL](timing-evidence/so-after-chosen-20ns/digital_filter.v)、[复现 Tcl](timing-evidence/so-after-chosen-20ns/reproduce.tcl)。
- 八阶：四个二阶节级联 · 优化前 · 50 MHz：[时序汇总](timing-evidence/sos8-before-20ns/timing_summary.rpt)、[建立路径](timing-evidence/sos8-before-20ns/internal_setup.rpt)、[资源](timing-evidence/sos8-before-20ns/utilization_routed.rpt)、[实际 RTL](timing-evidence/sos8-before-20ns/digital_filter.v)、[复现 Tcl](timing-evidence/sos8-before-20ns/reproduce.tcl)。
- 八阶：四个二阶节级联 · 优化后 · 50 MHz：[时序汇总](timing-evidence/sos8-after-chosen-20ns/timing_summary.rpt)、[建立路径](timing-evidence/sos8-after-chosen-20ns/internal_setup.rpt)、[资源](timing-evidence/sos8-after-chosen-20ns/utilization_routed.rpt)、[实际 RTL](timing-evidence/sos8-after-chosen-20ns/digital_filter.v)、[复现 Tcl](timing-evidence/sos8-after-chosen-20ns/reproduce.tcl)。
- 一阶通用示例（B1≠0） · 优化前 · 100 MHz：[时序汇总](timing-evidence/fo-before-chosen-10ns/timing_summary.rpt)、[建立路径](timing-evidence/fo-before-chosen-10ns/internal_setup.rpt)、[资源](timing-evidence/fo-before-chosen-10ns/utilization_routed.rpt)、[实际 RTL](timing-evidence/fo-before-chosen-10ns/digital_filter.v)、[复现 Tcl](timing-evidence/fo-before-chosen-10ns/reproduce.tcl)。
- 一阶通用示例（B1≠0） · 优化后 · 100 MHz：[时序汇总](timing-evidence/fo-after-chosen-10ns/timing_summary.rpt)、[建立路径](timing-evidence/fo-after-chosen-10ns/internal_setup.rpt)、[资源](timing-evidence/fo-after-chosen-10ns/utilization_routed.rpt)、[实际 RTL](timing-evidence/fo-after-chosen-10ns/digital_filter.v)、[复现 Tcl](timing-evidence/fo-after-chosen-10ns/reproduce.tcl)。
- 二阶陷波示例 · 优化前 · 100 MHz：[时序汇总](timing-evidence/so-before-chosen-10ns/timing_summary.rpt)、[建立路径](timing-evidence/so-before-chosen-10ns/internal_setup.rpt)、[资源](timing-evidence/so-before-chosen-10ns/utilization_routed.rpt)、[实际 RTL](timing-evidence/so-before-chosen-10ns/digital_filter.v)、[复现 Tcl](timing-evidence/so-before-chosen-10ns/reproduce.tcl)。
- 二阶陷波示例 · 优化后 · 100 MHz：[时序汇总](timing-evidence/so-after-chosen-10ns/timing_summary.rpt)、[建立路径](timing-evidence/so-after-chosen-10ns/internal_setup.rpt)、[资源](timing-evidence/so-after-chosen-10ns/utilization_routed.rpt)、[实际 RTL](timing-evidence/so-after-chosen-10ns/digital_filter.v)、[复现 Tcl](timing-evidence/so-after-chosen-10ns/reproduce.tcl)。
- 八阶：四个二阶节级联 · 优化前 · 100 MHz：[时序汇总](timing-evidence/sos8-before-chosen-10ns/timing_summary.rpt)、[建立路径](timing-evidence/sos8-before-chosen-10ns/internal_setup.rpt)、[资源](timing-evidence/sos8-before-chosen-10ns/utilization_routed.rpt)、[实际 RTL](timing-evidence/sos8-before-chosen-10ns/digital_filter.v)、[复现 Tcl](timing-evidence/sos8-before-chosen-10ns/reproduce.tcl)。
- 八阶：四个二阶节级联 · 优化后 · 100 MHz：[时序汇总](timing-evidence/sos8-after-chosen-10ns/timing_summary.rpt)、[建立路径](timing-evidence/sos8-after-chosen-10ns/internal_setup.rpt)、[资源](timing-evidence/sos8-after-chosen-10ns/utilization_routed.rpt)、[实际 RTL](timing-evidence/sos8-after-chosen-10ns/digital_filter.v)、[复现 Tcl](timing-evidence/sos8-after-chosen-10ns/reproduce.tcl)。
