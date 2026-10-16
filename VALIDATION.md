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

# 验证摘要

验证日期：2026-10-11。工作分支 `fix/z-plane-list-interaction`。保留阶段一修改，未 commit、push 或上传 Library。

| 检查 | 当前结果 |
|---|---|
| HTML SHA-256 | `9340e33e8b2fc6535825ca718b1007ec41ca070c23353151ea817003e5e8b019` |
| 确定性构建 | 两次重建逐字节相同；嵌入源码一致 |
| Node 回归 | 13 PASS、0 FAIL、23 SKIP；返回码 2 |
| SOS 独立回归 | 21,039 项检查通过 |
| ModelSim SE-64 2020.4 | 24/24 PASS，全部返回码 0 |
| Vivado XSim 2022.2 | 24/24 PASS，全部返回码 0 |

## 本次实现和实际边界

数字设计支持实系数最高 8 阶 ZPK / 传递函数到最多 4 个一阶/二阶 SOS 节。共轭配对、奇数阶、重根 ZPK、0–8 拍显式延迟（零点数加延迟 ≤ 8）、节峰值增益分配、逐节量化/舍入/饱和和累加器界限统一。高阶传函近重根或求根/回验不可靠时明确报错并建议使用带重数 ZPK，不能静默截断。所有输入、图、统一列表、响应、差分方程、SOS 系数和 RTL 共用模型。

生成 RTL 只有 clk/rst_n/data_in/data_out，输入输出同 IN_WIDTH；clk 行短注释给出设计 Fs，外部保证其频率，内部不分频/计数/门控。输入在接收沿前稳定，接收沿计第1拍；一阶在该沿后输出（1拍），二阶在下一沿后输出（2拍）。各节拍数相加，顶层组合连接不另加寄存级。零阶增益保留1拍采样接口，显式模型延迟 d 再加 d 拍。总拍数 L 对应接收沿后 L−1 个上升沿。rst_n 同步低有效。模块前仅 timescale，没有长篇说明。系数/定点设置为 localparam，IN_WIDTH 为 parameter，非法范围拒绝展开。

## 前版17例记录（历史）

案例：lowpass、saturation、notch、delay、fir、floor、wide、edited、sos4、sos6、sos8、odd5、delay8、sos_delay、repeated8、sos_clip、width18。

17 例 × 2 工具共 34/34 PASS。全部 wrapper 返回码 0，全部日志含 `PASS: four-port SOS, continuous samples, reset, latency`。总 runner 返回码 0。每例连续驱动 128 个符号/满量程/伪随机输入，加流水线与零输入尾部，再复位并重放；逐拍比较 data_out。sos4 由传函求根进入 SOS；odd5 覆盖一阶尾节；delay8 覆盖纯八拍延迟；sos_delay 覆盖级联加模型延迟及 floor；repeated8 覆盖八重实根；width18 实际覆盖模块 IN_WIDTH=18；wide 覆盖超过 JavaScript Number 精确整数范围的累加器。

`tests/sos-golden.cjs` 独立以 BigInt 除法/余数及旧寄存器状态计算每拍结果，不调用产品 runFixed。每例 `golden.json` 保存输入、精确期望、量化整数节、位宽和逐节饱和次数，生成器先与产品参考全等比对，RTL/TB 再在商业仿真器运行。sos_clip 两节分别发生 85、114 次饱和，确实覆盖节间及末级削顶。两种舍入、3–8 阶、负增益、延迟、累加器界限、量化后稳定性变化、全零节拒绝也有独立数值回归。

命令：

```powershell
node tests/generate-vendor-cases.cjs
python run_tests.py --allow-missing-dom
python run_vendor_checks.py --modelsim-bin <已有 ModelSim win64> --vivado-bin <已有 Vivado bin>
python verify_release.py --rebuild
```

原始记录：`vendor-results/results.json`、`vendor-results/<case>-<tool>.log`、`vendor-results/<case>-<tool>-wrapper.log`、`test-results/results.json`。阶段一原始厂商日志保留在 `vendor-results/stage1/`。这些机器日志被 gitignore 排除，源码、可复现示例与去机器路径说明纳入发布清单。

## 阶段一交互修复保留

原因为默认选择模式不添加、正常 ui 快照被误认为草稿而禁用画布、重复根通过求根数组索引无法稳定识别。现在默认空白点击添加，持久 plot 容器捕获指针，完整点击提交并去重；支持拖动、取消、坐标变换、逐点删除及共轭同步。图下列表显示稳定 ID、类型、实部、虚部、共轭组，整对删除明确标注。有效项目恢复可立即编辑，无效草稿保留且禁止旧模型导出。新增高阶联动回归通过。

## 未完成的验证

- 23 个 jsdom DOM 套件跳过；未安装依赖。新增 DOM 列表用例也属于此跳过范围。
- 原生浏览器检查仍失败：Windows platform directory 缺失，HRESULT 0x80070003。控制器最小 DOM 替身不算真实浏览器验证；可见布局、真实指针捕获、文件选择/保存流程仍待原生 UI 验证。
- 旧数学测试的 Icarus 子检查及独立 tclsh 检查缺工具跳过；与本次已完成的 ModelSim/XSim 实测分别记账。
- 未验证 FPGA 综合、时序、资源、CDC 或实物；有限输入及有限频率采样不构成全部系数/位宽的形式证明。

## UI / K / 位宽建议阶段记录（历史）

可用回归为 12 PASS、0 FAIL、23 SKIP，测试脚本返回码 2 表示存在跳过。控制器替身覆盖 Ctrl-only wheel、拖动中零次模型发布/根分析/HTML替换、rAF合并、松手一次提交、取消/失焦/捕获丢失/项目替换恢复、共轭预览同步、K=0保存恢复负增益和显式延迟、位宽建议不改配置。替身不能证明实际页面布局或浏览器指针捕获正确。

新增 digital-width 回归含 92 次数值比较及边界检查：各节浮点独立递推、BigInt累加峰值、削顶不能低估无饱和峰值、输入超范围、正负/零幅度、零直流终值、量化不稳定、慢极点未收敛、短窗口、裕量/样本边界和超支持位宽。原有 SOS 20,977 检查继续通过。

本阶段没有重跑厂商仿真：build-consistency 验证 17 个已有 RTL/TB/runner 与当前生成器逐字节一致，golden 再独立核对；既有 ModelSim/XSim 34 PASS 属于前一阶段证据。该阶段尚未修改 FO1/SO2 时序；下述新版已经单独完成逐拍厂商回归。真实浏览器、jsdom、100 MHz实现时序仍未验证。

## 当前共享 FO/SO 版本：48/48 真实仿真通过

24例：原17例，加 latency_fo、latency_so、odd3、odd5_fo、width8、width24、zero_gain。ModelSim SE-64 2020.4 与 Vivado XSim 2022.2 各24/24，所有 wrapper 返回码0，runner返回码0；日志同时含 PASS 与本例 TIMING 总拍数/边沿偏移。边界实际覆盖 IN_WIDTH=8、18、24；包含一阶/二阶、4/6/8阶、奇数混合节、正负增益、K=0、重根、显式延迟、两种舍入、节间/末级饱和与再次复位。

明确约定：输入在接收沿 E0 前有效，E0 计第1拍。一阶 E0 后输出（1拍）；二阶 E1 后输出（2拍）；四个二阶 E7 后输出（8拍）；顶层无附加寄存级。纯增益仍是1拍采样接口；纯八拍模型延迟加该接口为9拍、E8后输出。这样以接收沿后样本编号观察，H(z) 的附加延迟为各节拍数之和减1，不把历史状态、寄存级数和后续边沿数混写。

测试证据：`vendor-results/results.json` 含每例工具、命令、返回码及当前 RTL/TB SHA-256；对应 `<case>-<tool>.log` 含逐拍检查结论。旧17例日志完整保留于 `vendor-results/stage2-sos/`，没有用旧 PASS 替代新运行。新旧17例去掉输出对齐差异后逐样本数值全等，证据 `test-results/rtl-unshifted-compatibility.json`。

Node 13 PASS、0 FAIL、23 SKIP，rc=2。独立 SOS 21,039检查，独立时序1,289检查，位宽92检查；24个 RTL/TB/runner 与当前生成器一致，golden再独立验证。真实浏览器/jsdom仍未验证。未运行 FPGA 综合、布局布线或100MHz时序；此次10ns testbench周期不构成正WNS证明。只读 Vivado 工程目录未被修改或运行。


## 2026-10-16：原有 K 控件位置调整与实现恢复

原有整体增益 K 输入框和 ±0.1 按钮移到幅频曲线正下方，位于交越频率列表上方，无需展开模型参数或根坐标设置。保留原有增益事件处理、工程格式、SOS 数值计算与 Verilog / testbench 生成方式，撤销新增 outputGain 字段和后置输出乘法器。

本次 41 个源码 / 数值 / jsdom / 回归套件全部通过，0 FAIL、0 SKIP。专门核对了 K 加倍时各频点复响应加倍（幅度增加约 6.0206 dB）、零极点及根视图不变、正负/零 K、保存恢复、草稿禁用、导出与销毁重建。原有数学和代码生成部分与修改前源码一致；digital-sos.js、digital-magnitude.js、digital-width.js 逐字节恢复；24 组已有 RTL/TB/runner 与恢复后的生成器逐字节相符。

上文旧阶段的 jsdom 跳过记录是历史记录，本次已复用已安装的 jsdom 30.1.2 完成全部套件。原生 file:// 浏览器观察受工具协议策略限制，因此没有真实浏览器布局、操作系统选择器或截图验证结论。本次未重跑厂商 HDL 仿真和实现时序；已有厂商证据只对应原来的示例配置。详细记录见 gain-ui-validation.json。
