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
| 数字设计（单一入口） | 系数/零极点双向同步、z 平面数值/点击/拖动、共轭约束、离散响应、RTL/测试台/仿真 ZIP | 最多 2 阶直接型 I；兼容旧数字正向和逆向 v3 文件；不支持任意高阶 |
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

- `digital-design.js/.css`：数字模型、定点数值与 HDL 生成
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
- 共轭对经过实轴时保留两重根。每类根数最多 2，零点数加显式延迟最多 2，根编辑半径最多 100。原点因子在当前 z⁻¹ 约定中等于 1，不作为可独立编辑根；纯延迟在“额外延迟”中设置。
- 单位圆、稳定/临界/不稳定状态始终标注；滚轮/按钮缩放和拖动画布平移，视图随数字工程保存。
- 修复 ModelSim do 宏源码目录解析、RTL timescale，以及 XSim Windows Tcl 路径反斜杠转义。

未安装 jsdom 时，可显式运行已有依赖允许的测试：

    python run_tests.py --allow-missing-dom

`test-results/results.json` 区分 PASS / FAIL / SKIP；退出码 2 表示存在未运行项目，不能当作完整回归通过。脚本不会安装软件。

使用已有厂商工具复跑（仅 RTL 行为仿真；先在当前 PowerShell 会话设置 MODELSIM_BIN 与 VIVADO_BIN 为本机安装目录）：

    python run_vendor_checks.py --modelsim-bin "$env:MODELSIM_BIN" --vivado-bin "$env:VIVADO_BIN"

重新从当前生成器刷新八个示例的源码和 runner：

    node tests/generate-vendor-cases.cjs

本机交付包保留原始输入与失败历史。Git 仓库仅包含可重复构建所需源码、测试、轻量示例及去个人路径的验证摘要。

## 最终独立核验与交付

已在独立副本重新核验并运行两款仿真器，各 8/8 PASS。恢复未应用草稿后根编辑也会暂停，防止覆盖草稿。完整结果、未测项、失败历史与最终哈希见 `VALIDATION.md`。运行 `python verify_release.py --rebuild` 校验全包，运行 `python package_release.py` 生成固定元数据的源码 ZIP。
