## 2026-10-16 相位显示与模型 / RTL 延迟区分

单极点截图符合 H(z)=K/(1−pz⁻¹)，其原点零点使奈奎斯特处相位为 0°。
双极点截图额外计入二阶 RTL 的一拍流水线延迟，不能据此判断模拟极点的高频相位。
默认相频、阶跃统一显示 H(z)；上方“响应对象”可切换包含附加延迟的 RTL 视图，
并明确提示当前延迟。视图选择保存到 UI 配置，旧工程默认模型视图。
新增双线性 RC 示例（z=−1 零点）供比较；不修改已有模型、接口或 HDL。
修正 DC/Nyquist 精确端点的三角函数残差：真实零幅值处相位未定义。

验证：**50 PASS / 0 FAIL / 0 SKIP**。新增相位测试含 1,061 项数值 / 向量角比较，
覆盖截图的一阶 / 二阶、模型 / RTL 相频及阶跃、旧工程 / 保存恢复、RC 极限、
系数 / 因子两条求值路径、显式延迟和无效草稿。
原有逐拍实现测试的 6,590 项比较通过；24 组 RTL/TB/运行包与当前生成器一致。
digital-sos.js、数字系统工作台、基本模块生成器、全部仿真示例保持逐字节一致。
相位公式与范例说明见 PHASE_RESPONSE_GUIDE.md；完整证据见 phase-display-validation.json
与 test-results/phase-display-node.log。原生浏览器未验证，无新的硬件时序结论。
本次只更新本地，未同步 GitHub。以下保留历史记录。

---

## 本地工作台编辑与优化撤回（2026-10-16）

digital-system.js 对工程编辑使用先验证后提交的命令快照，历史不写入工程文件，最多 50 步 / 8 MB。模块库只重放本命令涉及的名称，保留其他页面后续改动。删除保存设计清理当前引用实例、连线和 layout；普通实例删除保留保存设计。撤销/重做、文件读取 revision/context 失效及工程替换清空历史相互配合。拖动/缩放提交只更新历史按钮和 SVG，保留连接表单。

digital-system-canvas.js 提供模块/连线选择、宽透明接线命中区域、键盘选择和右键上下文回调；剪贴板保存经校验的完整设计包，跨工程粘贴沿用 moduleName，实例名追加 _2 并处理重名和 64 字符边界。文档级快捷键在编辑区、隐藏分支和对话框中不拦截；destroy 清理菜单与监听。

上一轮时序优化已按用户要求撤回。digital-sos.js 与 24 份 RTL 恢复到 before-filter-retiming-backup 字节版本。digital-modules.js 的 withdrawnFilter 仅校验历史保存包，新生成始终走恢复后的 DigitalSOS；显式重新保存使用原结构。tests/fixtures/digital-sos-withdrawn.js 及 run_retiming_* 仅用于复现已撤回实验。FILTER_TIMING_REPORT.md 与 filter-retiming-validation.json 已标记 withdrawn，不代表当前采用的结构。

49 个源码/数值/jsdom 回归通过；XSim 基础模块、4,000 拍去直流与重复滤波器实例检查通过。没有新的原生浏览器或实现时序验证。详见 system-editing-validation.json。

---

## 本地 FO/SO 内部重定时（2026-10-16）

digital-sos.js 保留 legacyVerilog 用于旧保存包严格校验；verilog 生成同一顶层/级联和独立 FO/SO helper，只替换内部数据通路。一阶 history 保存 B1 输入乘积，P_A1 与输出同时保存新反馈乘积。二阶 history 保存 B1*x+B2*x1-A2*y1 的 AW 位结果，当前输出归并缩减为三项，仍输出 y2。三项减法通过移位进位向量的最低位补 1，避免额外常数压缩层；舍入/饱和代码原样保留。

tests/digital-retiming.cjs 检查旧包、原始生成器基线和顶层/时序契约。run_retiming_sim.ps1 使用现有 XSim 检查完整滤波器和独立 helper；run_retiming_timing.py 执行 OOC 实现。报告和可复现 RTL/XDC/Tcl/路径/资源证据见 FILTER_TIMING_REPORT.md、filter-retiming-validation.json、timing-evidence/。47 个回归全部通过。保持本地更新，未同步 GitHub。

---

## 本地基础模块生成器精简（2026-10-16）

digital-modules.js 的 primitive 按数学数值范围计算运算所需精度，不修改用户端口。赋值自然完成普通扩展及按输出位宽取位；仅在右移前保留完整运算结果、最近值舍入的进位、混合符号转换或饱和比较复用时生成中间量。同格式直通、单位增益和量化器只生成赋值。增益约去二次幂因子，常数使用实际宽度，寄存输出直接使用 output reg；积分器以该输出寄存器保存状态。

legacyPrimitive 仅用于校验已有 v1 设计包：load 必须精确匹配新生成器或旧生成器，不能接受任意替换的 Verilog。载入旧包保留原源码，只有明确重新保存才使用新生成器。系统工作台的模块定义、实例和接口规则保持不变。tests/fixtures/module-generator-v1.js 是旧生成器测试基线。

tests/module-arithmetic-cases.cjs 用 BigInt 数学定义产生 240 组配置和 11,520 个期望值，厂商仿真同时核对新实现与旧实现；run_module_hdl.ps1 同时运行既有 4000 拍去直流和重复滤波器检查。46 个回归套件通过。详细记录见 primitive-concise-validation.json；未做新的综合、时序及硬件验证。

---

## 本地系统图布局更新（2026-10-16）

digital-system-layout.js 提供纯几何布局及绕开膨胀矩形障碍的直角路由；digital-system-canvas.js 提供 SVG 绘制、稳定捕获容器、rAF 预览、拖动/缩放和取消/提交。system.layout 可选字段保存各模块及系统端口的 x/y/w/h，旧项目不含此字段时仍自动排列。删除模块或端口清理对应布局项。布局不参与 HDL 生成，模块定义和系统连接的 Verilog 输出保持一致。

45 个源码/数值/jsdom/回归套件通过，另对更新后的 CTM、捕获释放和删除清理交互用例补跑通过。568 条连线、1814 条正交线段的独立几何检查未发现穿过模块内部的情况。真实浏览器布局及指针效果仍未实测；详细范围见 system-layout-validation.json。

---

## 本地试用：模块设计与系统工作台（2026-10-16）

这部分功能仅更新本机，尚未同步 GitHub 或已发布的 HTML 下载文件。

在数字系统中切换「滤波器设计」「基础模块设计」「系统工作台」。基础模块包含减法器、乘法器、绝对值、常系数增益、量化器 / 格式转换、直通 / 延时和积分滤波器。基础模块可选组合逻辑或寄存输出；积分器固定含状态寄存器。寄存模块统一使用 clk 和同步低有效 rst_n。

1. 在模块页定义接口及参数，点击「保存模块设计」。已有滤波器可在原设计页使用「保存当前滤波器设计」。
2. 保存内容包括配置、接口、延迟和对应 Verilog。模块库可导出含完整 HDL 的设计 JSON，也可导出包含 JSON 与 .v 的 ZIP。
3. 在系统工作台选择已保存模块，填写实例名后导入。重复使用同一设计时模块名不变，实例名独立；生成代码只保留一份相同模块定义。同名而内容不同的 Verilog 不能同时使用，系统不会自动改名。
4. 添加顶层端口，从驱动端选择接收端。位宽、有无符号及小数位必须完全一致，每个输入只有一个驱动；纯组合环路禁止连接。需要格式转换或延时，先独立设计并保存相应模块。
5. 完成所有实例输入和顶层输出的连接后生成系统 Verilog。工程保存包含系统和引用的模块；也可单独导出 / 导入系统 JSON。

浏览器模块库用于复用已保存的设计，系统图通过工程文件保存；浏览器存储受限时请导出设计包。工作台按模块显示延迟，不自动对齐并行路径，也不自动修改接口位宽。

源码入口：digital-modules.js（保存包、接口及 HDL / 系统生成）和 digital-system.js / .css（模块页、库、连接图）。digital-design.js 的 system 扩展随数字工程保存，旧数字工程继续可用；滤波器数值核心和已有 HDL 生成器未修改。生成的系统把所有信号声明放在实例化之前，支持含寄存器的反馈路径。

本机 XSim 回归可使用已有工具运行：

```powershell
.\run_module_hdl.ps1 -VivadoBin <已有Vivado的bin目录>
```

以下保留前序版本记录。

---

## 当前公开分发版本（2026-10-16）

使用者下载 AnalogStudio.html 即可离线打开。原有 K 控件位于幅频曲线正下方；数值核心和 HDL 生成结构恢复为原有实现。当前 41 个源码 / 数值 / jsdom / 回归套件全部通过，24 组已有 RTL / TB / runner 与生成器一致。以下按阶段保留的跳过数、旧 HTML 哈希和未提交状态属于历史记录；当前验证范围见 README.md、VALIDATION.md 和发布清单。

---

## 2026-10-13 数字设计紧凑布局修复

实际源码根因：原 dd-plots 两列网格把相频卡与高大的根编辑卡放在同一行，默认 stretch 拉高较短卡片；dd-layout 左侧 290px 参数栏和 1600px 页面上限进一步挤压绘图区。mode-hint / selection / error 还以固定 60–78px 高度保留空白，隐藏错误用 visibility 而非移出排版。SVG 固定 viewBox 与 height:auto 缺少独立高度控制。

现在幅频独占顶部整行，主图优先，小窗宽度最多 300px。下方使用两个互不等高的纵向容器：左侧相频、阶跃；右侧默认折叠的模型/定点参数，以及 z 平面和其下方可编辑列表。页面可用宽度提高到 1880px。1050px 以下按编辑区、相频、阶跃堆叠；760px 以下小窗也位于主图下方。图标题、单位、图例和按钮紧凑排列；方程/SOS、位宽建议和长说明改为折叠内容。没有缩小正文掩盖留白，表单/正文保持 13px、图标题 14px，SVG 坐标文字 12px。

各图可独立收起/显示并通过右下角调整高度，宽度适应所在列；幅频和相频/阶跃有复位按钮。主图/小窗频率联动、蓝色浮点/橙色虚线量化、0 dB/单位增益 1 和交越列表均保留。ResizeObserver 用实际容器宽高重绘 SVG；拖动坐标换算匹配新视口。相频/阶跃使用独立的数字显示控制器 digital-response-plot.js，只绘制原模型提供的数据，不重算信号。Ctrl＋滚轮只作用于所在图；普通滚轮仍滚动页面。Space＋拖动临时平移，输入框内空格不触发平移；z 平面在添加模式下按 Space 拖动不会添加根。

根编辑的固定提示占位已移除；错误、选择信息和会换行的模式提示位于画布下方，不会在拖动开始时移动画布。坐标输入与整体 K 收在紧邻图的可展开区，根列表紧随画布反馈；长表格只在自己的容器内滚动。

验证：完整可用回归 **17 PASS / 0 FAIL / 23 SKIP**，run_tests.py 返回码 2。新增 digital-layout.cjs 验证独立视图/尺寸/隐藏、Ctrl 缩放、Space 平移、输入隔离、取消/失焦/捕获、ResizeObserver 重绘和销毁清理；digital-root-events 验证实际数字控制器接入、根编辑/列表不退化以及添加模式下临时平移不增根。既有 110 组单位增益检查、15 模型 6,590 项显示延迟比较继续通过。UI 回归使用最小事件节点和结构约束，不属于浏览器布局或截图证据。

数字数值核心和交越求解器与修改前逐字一致；全部 data-dd 输入属性保持一致。245 个受保护文件哈希未变，包括 digital-sos.js、digital-width.js、plot-domains.js、simulation-runners.js、timing-validation.json 及全部仿真例。RTL、定点位宽/时序、厂商仿真输入和原 Vivado 工程未修改；本轮未重跑硬件仿真。23 组 jsdom 测试仍因依赖缺失跳过，未安装任何软件。

参考图接收限制：Library 第一次返回云工作区路径，经本机检查不存在；仅重试一次显式 Windows 目录后，官方传输辅助程序因 Windows 没有 os.setxattr 而失败，最终文件仍不存在。因此本执行器未看到参考图像素，只依据用户描述和实际源码修改。现有浏览器工具尝试及一次恢复重试均返回 `trusted Node process exited unexpectedly; kernel reset, rerun your request`；未生成真实宽/窄视口截图，布局、原生拖动/缩放和滚动仍待原生 UI 核验，未绕过限制。

可复核入口：打开 AnalogStudio.html，分别在 1440px、1024px、390px 宽度查看；展开/折叠右侧参数不应拉高左列卡片，缩放/拖动/调整某图高度不应改变另一图，0 dB 小窗与主图频率仍同步。当前构建 HTML SHA-256：`faace7fcd3048482e4df07534673a30b6012cf1f24825e8030a13046fc6fa2af`；源码及 323 个发布文件已同步，verify_release.py --rebuild 确定性验证通过。日志见 test-results/stage8-node.log、stage8-build.log、stage8-release.log、stage8-summary.json。工作分支 fix/z-plane-list-interaction，保留已有修改，未 commit、push 或上传 Library。

---

以下保留前序阶段记录。

## 2026-10-12 数字幅频单位增益标注与联动小窗

数字幅频主图增加清晰的 0 dB 参考线；蓝色圆圈 F / 橙色方块 Q 分别标注浮点与量化系数的单位增益点，下方列出频率及穿越、触碰或端点类型。整段单位增益、没有交越、响应未定义和无法可靠确认分别提示，不用最近绘图采样点代替交越。量化曲线仍是量化系数的线性响应，不代表饱和非线性。

主图旁的小窗默认 −1 至 +1 dB，窄屏位于下方。主图与小窗共用频率范围；主图 Ctrl＋滚轮或按钮缩放、拖动平移，普通滚轮滚动页面，点击频率可定位。幅值比模式参考值为 1，小窗范围为 10^(-1/20) 至 10^(1/20)，保持等效 ±1 dB。取消拖动、失焦、模型更新、无效草稿及项目替换均清理或恢复视图；视图操作不改变模型或定点设置。

独立模块 digital-magnitude.js 从当前 binary64 系数精确构造 |B|²−|A|² 的整数多项式，以 x=cos(ω) 表示；BigInt 平方自由化与 Sturm 隔离能发现同一采样间隔中的多个根和不变号触碰。分母单位圆根单独列为未定义，不作交越。候选频率再由产品真实频响求值及有括区间的细化核验；仅有限且残差 ≤ 1e-7 dB 的候选被标记。隔离预算或数值核验不足时显示未可靠确认，不承诺任意病态输入都能给出交越。

本轮 tests/digital-magnitude.cjs 的 110 组/项检查通过：解析 2/8 交越、窄峰双交越、精确触碰及近似未触碰、端点、纯延迟/全通、接近但不等于单位增益、未定义点、独立量化交越、dB/幅值比、共享视窗、Ctrl-only 滚轮、拖动取消和清理。digital-root-events 另验证实际数字控制器接入、无效输入清空、导入失败原子性、单位切换不改模型。控制器使用最小 DOM 替身，不属于浏览器视觉或真实指针验证。

完整可用回归 **16 PASS / 0 FAIL / 23 SKIP**，run_tests.py 返回码 2；23 组因缺少 jsdom 跳过，没有安装依赖。本轮真实浏览器工具尝试失败，恢复重试后仍报告 `trusted Node process exited unexpectedly; kernel reset, rerun your request`。因此布局、原生指针及真实页面滚动仍未实测；没有绕过工具限制。

246 个保护文件（含全部既有仿真样例、digital-sos.js、digital-width.js、digital-root-editor.js、plot-domains.js、simulation-runners.js、timing-validation.json）哈希未变。位宽/参数输入区及 evaluate、step、implementationResponse、evaluateImplementation、generateVerilog 函数未变。本轮没有重跑厂商仿真或实现时序；前序 ModelSim/XSim 与 50 MHz OOC 证据的输入保持不变。未接触原 Vivado 工程。

本轮日志：test-results/stage7-node.log、stage7-release.log、stage7-summary.json。HTML SHA-256：`de8bb8609bfb7e12867614080bc5e2a9d3b20de852cf9a3f4c4380546fe0a651`。源码、生成 HTML 和 321 文件发布清单同步，verify_release.py --rebuild 验证确定性重建。仍在本地分支 fix/z-plane-list-interaction，未 commit、push 或上传 Library。

---

以下保留前序阶段记录。

## 2026-10-11 两曲线显示

相频与阶跃只显示蓝色「浮点＋实现延迟」和橙色虚线「定点＋实现延迟」，删除独立绿线与未附加实现延迟的参考线。幅频仍为浮点与量化系数两条；纯延迟不改变幅度。定点相频是量化系数的线性响应，不能解释成含饱和非线性的固定频响；定点阶跃继续使用实际逐节舍入和饱和结果。

H(z) 自身的零极点相位与显式 z^-d 已在频响及差分模型内。两条曲线均只再附加 pipelineDelay = 各节寄存拍数之和 − 1，不使用包含 d 的总 edgeOffset 再移一次。FO/零阶增益附加0拍，单SO附加1拍，级联按实际节拍数相加。零增益相位保持未定义，阶跃保持零。量化改变有效系数阶数时仍沿用原有RTL节的实现拍数。

digital-design.js 的 evaluateImplementation 默认仍返回量化系数实现响应；新增 quantized:false 选择浮点响应。step 保持原 values/points 含义，为浮点也提供 clockValues/clockPoints；绘图只使用两条 clockPoints，同拍误差按显示窗口比较。digital-sos.js、RTL生成、位宽输入控件、模型/定点参考、24例RTL/TB/golden及50MHz时序证据保持字节一致。本轮未重跑厂商仿真/布局布线，之前验证的硬件输入没有变化。

tests/digital-display-timing.cjs：15个模型、6,590项比较/断言，独立逐拍浮点寄存器机器与BigInt定点golden，覆盖FO/SO、3/5奇数阶、4/6/8级联、纯增益、纯延迟、SO显式延迟、零/负增益、削顶、量化降阶与量化首项为零。控制器SVG回归确认两条曲线的数量/颜色/虚线、显式延迟不重复以及零增益相位不伪造为0度；这是最小DOM替身测试，不是浏览器验证。

完整可用回归15 PASS / 0 FAIL / 23 SKIP，脚本rc=2表示缺jsdom的23组未运行。本轮实际尝试真实浏览器，运行时仍失败：`MXC launcher: cannot locate required Windows platform directory: HRESULT 0x80070003`。未安装软件、未绕过限制，原生视觉/UI未测。

---

以下保留前序阶段记录。

## 2026-10-11 RTL 关键路径优化与 50 MHz 验收

最终实现使用完整 signed 乘积、AW 位进位保留归并、并行 floor/ceil 舍入饱和分支。反馈和 x/y 寄存器更新未改变；FO1/SO2、四端口、每拍吞吐、复位和逐位数值契约不变。最近舍入的负数半值仍远离零，floor 与 CF=0/1 保持原行为。没有插入反馈延迟，没有内部时钟处理，也没有缩减用户配置的乘积/累加器位宽。

Vivado 2022.2，xc7a50tfgg484-1，OOC 综合→opt→place→route；同一份最终 RTL 分别以 10 ns 与 20 ns 重新执行全流程，setup/hold 用户不确定度 0.200/0.050 ns，没有 false/multicycle path。三个代表模型均通过 **50 MHz 内部时序**，100 MHz 均失败；不保证任意系数或位宽。

| 案例 | 100 MHz WNS / TNS (ns) | 50 MHz WNS / TNS (ns) | 50 MHz WHS / THS (ns) | 50 MHz LUT / Fabric FF / DSP |
|---|---:|---:|---:|---:|
| lowpass | -3.037 / -117.493 | 5.262 / 0.000 | 1.346 / 0.000 | 102 / 16 / 2 |
| notch | -4.330 / -235.501 | 4.732 / 0.000 | 0.139 / 0.000 | 233 / 32 / 5 |
| sos8 | -5.176 / -1413.149 | 3.193 / 0.000 | 0.063 / 0.000 | 981 / 152 / 20 |

全部输入输出 16 位，系数 18 位 / 15 小数位、数据 14 小数位。lowpass/notch 节宽16、累加40、延迟1/2拍；sos8 四个二阶节，节宽20、累加44、总8拍。精确系数、指标、关键路径与输入/报告 SHA-256 在 timing-validation.json。Fabric FF 不包含 DSP 内部寄存器；BRAM 均为0。

50 MHz 三例 TNS/THS=0、setup/hold/pulse 违例端点=0、路由错误=0，无未约束内部端点。每例17个输入（含同步 rst_n）没有 input_delay、16个输出没有 output_delay；没有顶层 BUFG/PLL/MMCM 或板级引脚/时钟树约束。OOC 的时钟/分区端口警告保留，因此这不是板卡签核、门级/SDF 仿真或硬件实测。clk 直接采样：真正用50MHz驱动且每拍输入时，物理采样率就是50MHz；原示例48kHz注释和系数没有因时序实验而更改。

最终24个原有模型在 ModelSim 2020.4 与 XSim 2022.2 各24/24 PASS，逐拍 golden、模型、参数覆盖及测试台与优化前逐字节相同。新增 digital-rtl-arithmetic.cjs：90,112 个独立舍入恒等式检查；实际生成 FO/SO 上20组配置、6,084个边界/随机算术探针，两款工具均 rc=0/PASS。探针只验证组合乘积归并、舍入和饱和，原24例另行验证乘法、逐拍输出和复位。未安装软件，jsdom 23组完整DOM测试仍跳过，原生浏览器未测试。

算术探针复跑：`node tests/digital-rtl-arithmetic.cjs <独立输出目录>`，然后在该目录用已安装工具运行生成的 run_modelsim.bat / run_xsim.bat。其专用 PASS 标记是 `PASS: combinational arithmetic probes`，不得当成顺序时序检查。历史报告保留；本节及 timing-validation.json 是当前 RTL 的验证范围。


---

以下保留前序阶段记录。

# AnalogStudio：Windows / Codex 开发交接包

## 从哪里开始

- `AnalogStudio.html`：可直接打开的完整单文件应用，不依赖在线脚本。
- `examples/simulation/lowpass/`：低通数字模型的 RTL、SystemVerilog 测试台和 ModelSim / Vivado XSim 脚本。
- `examples/simulation/saturation/`：真正触发输出饱和的独立测试例。
- 每个仿真例的 `SIMULATION_README.txt` 包含可交给本地 Codex 的具体任务。

本包不会自动安装软件或运行仿真。先确认电脑上已经安装的 Python、Node.js、ModelSim / Questa 或 Vivado 工具位置。示例脚本只能在已安装的对应工具可调用时运行。

## 当前功能与边界

| 工程分支 | 已实现 | 明确边界 |
|---|---|---|
| 模拟正向 | 11 类基础单元、层级串并联、权重、s 域黑箱、频率/极点/反馈分析 | 理想连续时间模型 |
| 模拟逆向 | s 平面实根/共轭对编辑、目标响应、受限电路候选、元件和连接清单 | 目标最多 8 阶；候选限支持的 RC、理想运放低通和受约束 Sallen–Key；不是任意电路综合 |
| 数字设计（单一入口） | 系数/零极点双向同步、z 平面数值/点击/拖动、共轭约束、离散响应、RTL/测试台/仿真 ZIP | 最多 8 阶 SOS 级联；兼容旧数字正向和逆向 v3 文件；不支持任意高阶 |
| 混合正向 | Tustin 映射后与数字滤波器级联、显式采样周期和采样响应 | 总阶数最多 4；含条件检查；不含 ADC/DAC 非理想特性、混叠折叠、实际重建保持或混合量化 |
| 混合逆向 / 板级 | 保持不可用 | 未实现，不会以空白工作台伪装可用 |

保存位置为“选定父文件夹 / 工程名 /”。独立黑箱放在其中的 `black box` 子文件夹，工程 JSON 和生成代码/ZIP 放在工程文件夹。浏览器通常只提供所选文件夹名及已知相对路径，应用不伪造绝对路径。重新打开网页或回导工程后，需要重新选择本次会话的保存位置。目录与同名文件覆盖都有明确确认。

## 重建单文件应用

需要 Python 3.10 或以上，不需要第三方 Python 包。在本目录运行：

    python rebuild.py --verify

也可使用 Windows Python Launcher：

    py -3 rebuild.py --verify

`--verify` 会比较重新生成的 HTML 与本次发布记录的 SHA-256。修改源代码后可运行不带 `--verify` 的重建，再运行测试。不要手工修改生成的 `project-manager.js` 或 `AnalogStudio.html` 后又重建；相应修改应进入补丁脚本或独立源模块。

### 构建关系

1. `project-manager.folder-hierarchy.js` 是目录/层级版本的工程模块基线。
2. `branch-manager-patches.py` 应用分支 schema、通用生成文件保存等改动，读取 `generated-artifact-save.js`，生成 `project-manager.js`。
3. `integrate-expanded.py` 从 `AnalogStudio.folder-hierarchy.html` 基线出发，内嵌仿真脚本生成器、数字模块、逆向/混合模块、分支桥接、工程模块以及样式。
4. `AnalogStudio.pre-workspace.html` 仅用于旧数学核心不变性回归；不是当前应用入口。

关键编辑入口：

- `digital-sos.js`：八阶求根/回验、SOS、定点逐节参考和四端口 RTL；`digital-design.js/.css`：数字模型、输入同步、响应与界面
- `digital-response-plot.js`：相频/阶跃独立视口、尺寸观察、缩放平移及图卡折叠
- `digital-magnitude.js`：数字幅频单位增益方程、交越标注、共享频率小窗和视图交互
- `digital-root-editor.js`：实轴/共轭零极点控制器、选择/点击/拖动、缩放/平移与视图保存
- `inverse-mixed.js/.css`：模拟逆向、受限候选与混合正向
- `simulation-runners.js`：Windows runner 和安全 ZIP 生成
- `engineering-branches.js/.css`：分支挂载、隔离、域标签及跨工程异步失效
- `generated-artifact-save.js`、`branch-manager-patches.py`：保存、权限、覆盖、v2/v3 工程流程
- 目录/层级基础源码位于基线 HTML 中；额外保留 `hierarchy-patches.py`、`hierarchy.css`、`blackbox-ui.js` 便于追踪该部分实现。

模拟正向保持 portable v2；新增分支使用 v3 的专用 `design`。窗口几何等浏览器偏好不混入模拟工程设计。尚未完成的表单输入会作为明确的编辑草稿保留；模型/代码生成不能把无效草稿当作有效模型。

## 自动测试

已附 `testdeps/package.json` 与锁文件，不附 `node_modules`。锁定的 jsdom 需要 Node `^22.22.2`、`^24.15.0` 或 `>=26`；推荐使用已有的兼容版本。依赖不会自动安装。

如决定安装锁定的测试依赖，显式运行：

    npm ci --prefix testdeps

随后运行：

    python run_tests.py

测试包括解析数值对照、黑箱与层级、目录状态机、真实应用事件链的 DOM 模拟、旧分支及统一数字入口的往返/恢复/错误回滚、未完成草稿、异步导入失效、生成文件保存和 ZIP CRC。若已有 Icarus Verilog，数字测试会尝试其编译/仿真；没有时明确报告未安装。独立 Tcl 语法检查也可能因 `tclsh` 不在 PATH 而明确跳过，不会自动安装。

这些测试不替代 Windows 原生浏览器布局、真实文件夹选择器/权限弹窗或商业 HDL 工具验证。2026-10-11 本次修改已使用 ModelSim 2020.4 和 Vivado XSim 2022.2 各通过 8 个代表性自检模型。详见 VALIDATION.md；详细运行日志仅保留在本机交付包，不入库。本机缺少 jsdom，23 组完整 DOM 回归未运行；浏览器控制运行时故障，原生界面与目录选择未测。未验证综合、FPGA 时序、资源占用或板级行为。

## 建议交给本地 Codex 的检查顺序

1. 核验当前目录和 `delivery-manifest.json`；重建并比对 HTML 哈希。
2. 检查已有工具，不擅自更换软件版本或安装软件。
3. 跑测试并记录原始输出；区分通过、失败和缺工具导致的跳过。
4. 进入 `examples/simulation/lowpass`，按 `SIMULATION_README.txt` 用已有 ModelSim 或 Vivado XSim 运行，再运行 saturation 例。
5. 记录工具版本、编译与仿真退出状态、明确 PASS 行和日志；有失败先修复再回归，不能只凭生成源码宣称仿真通过。
6. 在本地浏览器走完“选择父文件夹 → 新建工程 → 保存工程 → 保存黑箱 → 同名取消/覆盖 → 撤销权限 → 重新授权”的完整流程；确认实际磁盘目录与显示路径相符。
7. 在常用窗口宽度核查拓扑旁层级面板、逐层导入与切换、数值控制区和所有新增工作台。原始文件夹选择失败的具体环境触发条件此前未能在原生环境重现，应重点复核。


## 2026-10-11 数字设计更新

- 数字工程统一保存为 `classification.direction: "design"`；读入旧 `forward` / `reverse` 数字 v3 工程后规范化分类，保留模型与编辑草稿。模拟/混合分支不改变分类。
- 有效系数或零极点输入实时更新同一个模型、响应、差分方程和代码生成输入。输入无效时保留草稿，清空响应并阻止根编辑/代码导出；不会用隐藏的旧输入覆盖当前输入。
- 蓝色因子根可选择、数值更新、点击放置或拖动；实根只沿实轴移动，非实根连同共轭一起移动/删除。选择后可用删除键。紫色表示选中，橙色为量化根，灰色为阶次补齐原点根。
- 共轭对经过实轴时保留两重根。每类根数最多 8，零点数加显式延迟最多 8，根编辑半径最多 100。原点因子在当前 z⁻¹ 约定中等于 1，不作为可独立编辑根；纯延迟在“额外延迟”中设置。
- 单位圆、稳定/临界/不稳定状态始终标注；Ctrl+滚轮/按钮缩放和拖动画布平移，视图随数字工程保存。
- 修复 ModelSim do 宏源码目录解析、RTL timescale，以及 XSim Windows Tcl 路径反斜杠转义。

未安装 jsdom 时，可显式运行已有依赖允许的测试：

    python run_tests.py --allow-missing-dom

`test-results/results.json` 区分 PASS / FAIL / SKIP；退出码 2 表示存在未运行项目，不能当作完整回归通过。脚本不会安装软件。

使用已有厂商工具复跑（仅 RTL 行为仿真；先在当前 PowerShell 会话设置 MODELSIM_BIN 与 VIVADO_BIN 为本机安装目录）：

    python run_vendor_checks.py --modelsim-bin "$env:MODELSIM_BIN" --vivado-bin "$env:VIVADO_BIN"

重新从当前生成器刷新十七个示例的源码和 runner：

    node tests/generate-vendor-cases.cjs

本机交付包保留原始输入与失败历史。Git 仓库仅包含可重复构建所需源码、测试、轻量示例及去个人路径的验证摘要。

## 最终独立核验与交付

已在独立副本重新核验并运行两款仿真器，各 8/8 PASS。恢复未应用草稿后根编辑也会暂停，防止覆盖草稿。完整结果、未测项、失败历史与最终哈希见 `VALIDATION.md`。运行 `python verify_release.py --rebuild` 校验全包，运行 `python package_release.py` 生成固定元数据的源码 ZIP。

## 阶段一：点击放置与统一列表

`digital-root-editor.js` 默认 `tool: add`；pointerdown 在持久 plot 容器捕获指针，pointerup 提交空白点击，随后 click 去重。拖动/取消不添加根；click-only 事件仍可添加。坐标优先使用 SVG screen CTM，缺失时按 viewBox 居中留白换算。单位圆、轴线和量化/补齐根禁用命中，clipPath ID 按编辑器实例区分。

编辑器使用 `editor.rootGroups` 保存可选的因子 ID、坐标和 pair 状态，不依赖二次方程求根顺序。两个独立实重根拥有不同 ID，共轭对退化到实轴仍保留两点一组。模型系数仍是权威数据，恢复时校验元数据重建系数；不一致时重新识别，不能借元数据覆盖模型。旧项目无此字段时自动创建 ID。

`digital-design.js` 的 replace 只挂起无效或与存储模型不一致的未应用草稿；带有正常 ui 字段的有效项目恢复后立即绘图并允许编辑。图、列表、双输入形式、响应、方程与导出继续共用同一系数模型。

`tests/digital-root-events.cjs` 明确为最小 DOM 替身控制器回归，新增点击去重/取消、CTM/留白、重复根编号、列表委托、共轭同步、快照恢复与上限反馈。`tests/digital-design-dom.cjs` 补充真实 DOM 列表事件用例，但 jsdom 未安装时仍跳过，不能声称已运行。当前锁定 jsdom 30.1.2；仅在用户确认局部 `npm ci --prefix testdeps` 方案后安装。

## 当前实现：八阶 SOS / 四端口契约

`digital-sos.js` 提供确定性的共轭配对、一阶/二阶打包、按极点半径排序、零点节匹配和增益分配。高阶传函采用缩放 Aberth 迭代并做系数重建回验，800 次上限、最多 3 次确定性初值；根间距小于相对 1e-6 的高阶 TF 判为近重根并拒绝。ZPK 不需要重新估计重数，通过可选 `model.factors` 保存原始因子；进入模型时验证与系数一致。仅改增益、延迟或单侧系数时保留另一侧有效因子。

最高阶数为 8，实系数、每类根半径 ≤ 100、归一化系数绝对值 ≤ 1e6；零点数加显式延迟 ≤ 8。SOS 至多 4 节，奇数阶保留一阶节。增益按 1025 个单位圆采样点估算节峰值并均衡，末节补偿乘积误差并回验整个传递函数；这不是对窄峰或任意输入无削顶的保证。单位圆采样点奇异、无法可靠求根/重建、系数溢出、非零节分子全部量化为零、累加器位宽不足均报错，不截断。

位宽范围：输入/输出 IN_WIDTH 8–24 位，节间 IN_WIDTH–32 位，系数 8–30 位，累加器 20–64 位。所有数据节点保持 DATA_FRAC 小数位；每节 nearest 半值远离零或 floor，随后饱和到该节输出宽度，反馈使用饱和值。末节饱和到 IN_WIDTH。系数采用定点 signed localparam；IN_WIDTH 是模块 parameter，节间与累加器位宽按原配置的裕量随之变化，DATA_FRAC 和系数精度不变。非法参数覆盖在 elaboration 阶段进入 INVALID_IN_WIDTH_CONFIGURATION 分支而失败。18 位参数覆盖已在双工具实测。

端口仅 clk、rst_n、signed data_in、reg signed data_out。clk 就是采样时钟，每上升沿接收新样本，不分频、不门控、不设 valid/ready/enable。Fs 在 clk 行短注释中给出，修改注释不能重新设计滤波器。rst_n 是同步低有效复位，采样前至少保持一个有效时钟沿；复位同时清空所有节、显式延迟和输出。

输入在接收沿前稳定，接收沿计第1拍；一阶在该沿后输出（1拍），二阶在下一沿后输出（2拍）。各节拍数相加，顶层组合连接不另加寄存级。零阶增益保留1拍采样接口，显式模型延迟 d 再加 d 拍。总拍数 L 对应接收沿后 L−1 个上升沿。 `filterLatency` 为各节拍数之和，`latency=filterLatency+d`，`edgeOffset=latency−1`，`pipelineDelay=filterLatency−1`。`runFixed.raw` 按目标 H(z) 对齐（含 d）；`clockRaw` 在其前补 pipelineDelay 个零，测试台比较后者。高阶浮点频响使用因子、时域使用 SOS，避免高阶多项式抵消造成与节模型不一致。

旧 v1 数字模型和 v3 forward/reverse 工程继续读取。旧输出位宽不同于输入的工程保留原配置及浮点结果，但定点/RTL 明确阻止；在输入位宽栏重新设置统一 IN_WIDTH 后再导出，不默默改变旧定点语义。新增 sectionBits 缺省为旧输入/输出的最大位宽。

`tests/sos-golden.cjs` 是独立的逐时钟 BigInt 参考，使用除法/余数舍入和旧/新寄存器状态，不调用产品定点运行器。`tests/digital-sos.cjs` 检查 3–8 阶 TF/ZPK、增益符号、两种舍入、节间宽度、累加器界限、重根、延迟、频响/浮点时域以及近单位圆精度。`tests/generate-vendor-cases.cjs` 为 17 个案例导出 model/RTL/TB/golden/参数覆盖设置；生成前独立比较 golden 与产品 clockRaw，build-consistency 再验 golden 与产物字节一致。

当前真实 RTL 仿真为 ModelSim 2020.4 与 XSim 2022.2 各 24/24，细节及限制以 VALIDATION.md 为准。先前阶段一八例证据作为历史保留在本地 `vendor-results/stage1/`。

## 交互与位宽建议实现

`digital-root-editor.js` 的 pointermove 只缓存最后坐标并安排一个 requestAnimationFrame，修改已有标记 transform、列表及坐标输入，不写 factors/model、不分析根、不替换 SVG 或列表。pointerup 一次提交；取消、blur、lostpointercapture、Esc、setModel/replace/destroy 撤销预览并取消帧任务。内部 onModel 回调里的 setModel 不再次绘图，消除双重重绘。提示区域固定高度，focus 使用 preventScroll。

整体 K 复用模型因子增益，零增益时可选 factors 保留零点形状与 delaySamples；数学 analysis 不把保留布局报告成零传递函数的有限零点。普通旧模型继续兼容。系数模式复用零增益元数据，快照/重开/模式切换后仍可恢复负或正 K。

`digital-width.js` 独立提供纯函数 advise：浮点 SOS 轨迹、量化系数舍入但不饱和的估计轨迹，加现有 BigInt 定点运行器的原始累加峰值和实际饱和输出。后者不替代前两者，防止用削顶峰值低估范围。裕量转换为 10^(dB/20)；有符号数据位宽保留正端点及既有小数位约束。建议累加器还取拟议位宽下的现有全范围乘加下界，不按小阶跃缩窄理论界限。

有限窗口收敛判据是至少 32 样本、末尾 1/8 样本均接近各节理论直流终值，容差 max(终值0.5%、峰值0.01%、2 LSB)。浮点与量化结构都需严格稳定，未饱和估计都需满足判据；否则仅显示观测，不给可应用建议。输出过冲相对浮点理论终值；终值为零时不报告百分比。报告明确有限窗口局限，不作任意输入溢出保证，不自动改配置。

UI阶段当时保持了17例 RTL/TB/golden 字节一致；现已进入下述共享模块阶段并重跑24例双工具仿真。未做新滤波器100 MHz综合/布局布线。

## 共享 FO/SO 实现与验证

`digital-sos.js` 的 timing() 给出每节 order/latency 和总拍数；低阶也先提取显式 z^-d，避免把纯延迟当滤波节阶数。order=max(分子阶数,分母阶数)，一阶/二阶分别1/2拍；零阶倍乘复用无反馈的一阶采样接口1拍。配对和增益分配保持原版，因此某些奇数阶传函可组成全二阶节（原 odd5 案例是3个二阶节、总6拍），界面显示实际节拍数，不把传函阶数冒充硬件延迟。odd3/odd5_fo 分别覆盖1+2与1+2+2拍。

顶层只连接共享 `_fo` / `_so` 实例和必要的显式模型延迟寄存器，data_out 用组合赋值，没有附加顶层寄存级。FO 输出 y1，SO 输出 y2；y1 每拍更新为舍入饱和后的当前递推值，y2 每拍更新为旧 y1。a1 乘旧 y1、a2 乘旧 y2，所以外部输出第二拍不会改变分母递推。算术保持完整乘积、明确符号扩展、feedforward/feedback 分组加法、扩展一位舍入和输出饱和。

每次复位至少覆盖一个上升沿，清空全部 x/y 和显式延迟状态；填充周期按准确 golden 为0，无 valid/ready、无停顿，之后每拍一份样本。testbench 在下降沿驱动，上升沿后1ns检查全部拍，包括填充和再次复位。四端口短注释包含 Fs；仿真时钟10ns只是激励设置，不是100MHz布局布线达标证据。

`tests/digital-latency.cjs` 覆盖独立阶跃/脉冲/连续输入、逐节和总拍数、纯增益/延迟、混合奇数阶、实现线性相位和顶层无额外寄存级。`tests/sos-golden.cjs` 以独立旧/新寄存器状态和输出等待槽计算每拍，不调用产品流水延迟补零逻辑。`test-results/rtl-unshifted-compatibility.json` 记录17例前后数值序列全等；新版本24例的 RTL/TB 哈希随每个厂商结果记录，避免混用历史日志。

旧 v1 项目传递函数和量化数值不变，但重新导出的实现输出时刻采用新约定；不能当作旧版绝对时刻兼容。绿色相位基于量化系数的线性模型乘 z^(-pipelineDelay)，幅值不变；绿色阶跃使用实际定点 clockValues（含逐节饱和）。

当前反馈路径仍需在一个周期完成乘加、舍入和饱和，SO的第二寄存级不缩短 y1→y1 反馈关键路径。100MHz需后续经用户确定器件和独立执行目录后做真实实现，不因行为仿真通过而声称正裕度。用户提供的 Vivado 工程集合保持只读，未打开工程、未运行综合或布局布线。

原有整体增益 K 控件现位于幅频曲线正下方；仍使用原有因子增益和 SOS / Verilog 生成方式，没有新增后置乘法器或 outputGain 工程字段。
