# AnalogStudio

离线单文件模拟电路与数字滤波器设计工具。下载 `AnalogStudio.html`，用浏览器打开即可使用。

## 下载与使用

1. [下载可直接使用的 AnalogStudio.html](https://github.com/2822034477-hub/AnalogStudio/releases/latest/download/AnalogStudio.html)。
2. 保存到电脑后双击，用 Chrome 或 Edge 打开。
3. 开始设计；工程保存、导入和导出按网页中的提示操作。

使用网页不需要安装 Python、Node.js、Vivado 或 ModelSim，也不需要启动服务器。脚本、样式和图形均包含在 HTML 文件内，基础计算和绘图可离线使用；点击外部资料链接时才需要联网。

也可点击仓库右上角 **Code → Download ZIP**，解压后打开根目录中的 `AnalogStudio.html`。GitHub 文件预览显示的是源代码，需要先下载到本机再打开。

## 功能

- 模拟电路与 LTI 网络分析，传递函数、响应及原理图展示。
- 统一数字设计入口：z⁻¹ 系数或零极点输入，最高八阶实系数系统。
- z 平面点击、拖动、实轴单点、共轭对与重复根编辑。
- 幅频、相频、阶跃响应，以及浮点和定点系数对比。
- **整体增益 K 位于幅度曲线正下方**；调整输出比例时，保留原有因子模型和代码生成方式。
- 一阶/二阶 SOS 定点级联、位宽建议、四端口 Verilog、自检 testbench 与仿真脚本导出。
- 工程保存/恢复、模型导入/导出与旧数字工程兼容。

## 已有 Verilog 开发环境时

1. 打开网页的数字设计，设置采样率、系数或零极点，以及定点参数。
2. 导出 `digital_filter.v` 和 `digital_filter_tb.sv`；也可导出仿真 ZIP，获得同一模型的 RTL、testbench 和仿真脚本。
3. 使用现有 ModelSim / XSim 运行对应脚本，或将 RTL 和 testbench 加入自己的仿真工程。脚本使用本机已有工具；具体说明见导出包中的 `SIMULATION_README.txt`。
4. 接入 FPGA 工程时，按生成文件的接口和 Fs 注释连接时钟、复位及数据，结合目标器件重新检查时序。

顶层四端口为 `clk`、`rst_n`、`data_in`、`data_out`；每个时钟上升沿接收一个样本，输入输出共享 `IN_WIDTH`，`rst_n` 是同步低有效复位。各模型的实现延迟在网页和生成文件中标注。仓库的 `examples/simulation/` 包含 24 组可复现示例，可直接用于已有仿真环境。

## 验证状态

2026-10-16 版本：41 个源码、数值、jsdom 和回归套件全部通过，0 FAIL、0 SKIP；24 组已有 RTL / testbench / runner 与当前生成器逐字节一致。原有 SOS 数值计算和代码生成结构保持不变。

当前单文件 SHA-256：`f1cd0041963113285acf9ba9d9be37d06c0ad9363b0d837313aaf352c53c6785`。

已有 ModelSim 2020.4 / Vivado XSim 2022.2 示例仿真证据各 24/24 PASS；代表 FO/SO/SOS8 在 xc7a50tfgg484-1 上通过 50 MHz OOC 内部时序，100 MHz 未通过。这些结果仅对应已验证的示例配置，板级 I/O、完整时钟树和实物行为未验证。本次没有重跑厂商 HDL 仿真或实现时序，原生浏览器布局和系统文件选择器仍有未测项。详情见 [VALIDATION.md](VALIDATION.md) 和 [gain-ui-validation.json](gain-ui-validation.json)。

## 开发与测试

仅使用网页无需执行以下命令。修改源码时需要已有 Python 3.10+ 和 Node.js；构建不需要第三方 Python 包。

```powershell
git clone https://github.com/2822034477-hub/AnalogStudio.git
cd AnalogStudio
python verify_release.py --rebuild
python run_tests.py --allow-missing-dom
```

缺少 jsdom 时 DOM 测试会明确跳过。需要完整回归时，运行 `npm ci --prefix testdeps`，再运行 `python run_tests.py`。测试退出码：0 全部通过，1 有失败，2 有跳过。Node 版本要求见 [开发说明](DEVELOPER_README.md)。

修改源模块后执行 `python rebuild.py` 更新单文件页面，再更新 `delivery-manifest.json` 中的哈希并运行校验。不要只修改生成的 HTML。

- `digital-design.js`、`digital-root-editor.js`：数字模型和交互界面。
- `digital-sos.js`、`digital-width.js`：SOS 实现、HDL 与位宽建议。
- `digital-magnitude.js`、`digital-response-plot.js`：幅频交越与响应图。
- `AnalogStudio.pre-workspace.html`、`AnalogStudio.folder-hierarchy.html`：构建及兼容性测试基线。
- `tests/`、`audit_expanded/`、`testdeps/`：回归和测试依赖清单。
- `examples/simulation/`：24 组轻量 HDL 仿真示例。

工具许可证、凭据、依赖目录、原始日志和仿真缓存不纳入仓库。同步步骤见 [SYNC.md](SYNC.md)。
