# AnalogStudio

离线单文件模拟电路、数字滤波器与系统工作台。下载 `AnalogStudio.html`，用 Chrome / Edge 打开即可使用，不需要安装 Python、Node.js、Vivado 或 ModelSim，也不需要启动服务器。

## 下载与使用

1. [下载可直接使用的 AnalogStudio.html](https://github.com/2822034477-hub/AnalogStudio/releases/latest/download/AnalogStudio.html)。
2. 保存到电脑后双击，用 Chrome 或 Edge 打开。
3. 工程保存、导入和导出按网页中的提示操作；点击外部资料链接时才需要联网。

也可点击仓库右上角 **Code → Download ZIP**，解压后打开根目录中的 `AnalogStudio.html`。GitHub 文件预览显示的是源代码，需要先下载到本机再打开。

## 功能

### 模拟电路

- 19 个连续时间单元：一阶/二阶有源滤波、积分与微分、增益、文氏桥、RLC 二阶低通，以及新增的 8 个 RLC 电压分压网络。
- RLC 网络：串联/并联 RL、RC、LC、RLC，统一 `H(s) = Znet / (Rs + Znet)`，带源电阻 `Rs`、参数扫描、原理图和零极点分析。
- 传递函数、幅频/相频、阶跃响应、零极点图与参数联动。
- 组合测试台：串联/并联组合、黑箱模型、零极点与反馈实验。

### 数字设计

- z⁻¹ 系数或零极点输入，最高八阶实系数系统。
- z 平面点击、拖动、实轴单点、共轭对与重复根编辑。
- 零极点坐标可在**直角坐标 Re/Im**与**极坐标 r/θ**之间切换；拖动和数值输入都按当前定点 `coefficientFraction` 就近舍入到 `2^-F` 网格。
- SOS 零极点配对：先选最靠近单位圆的极点组，再选复平面距离最近的零点组；最终按极点半径升序级联。
- 一阶/二阶 SOS 定点级联、位宽建议、四端口 Verilog、自检 testbench 与仿真运行包导出。
- 浮点/定点幅频、相频、阶跃对比，以及 RTL 实现延迟视图。

### 系统工作台

- 滤波器、基础模块、DDS、偏移二进制转换、常数激励的保存、导入与连线。
- 端口格式按 `s.[2:14]` / `us.[2:14]` / `us[16:0]` 显示；连接只要求位宽相同。
- 点击端口即可连线：先点驱动端，再点位宽相同的接收端；选中的驱动端会变色。
- DDS 正弦模式默认输出 I/Q 两路正交；波表使用块 RAM（`rom_style="block"`）。
- 基础模块支持饱和保护：超范围时钳位到最大/最小值，而不是回绕。

### 工程

- 工程保存/恢复、模型导入/导出、旧工程迁移。
- 数字模块设计包、完整系统 JSON、仿真 ZIP 导出。
- 旧版只含 11 个模拟单元的工程，校验时自动补齐 8 个 RLC 默认实验。

## 最近更新

### 2026-11-18 · 零极点坐标制与定点量化

- 零极点编辑新增直角坐标 / 极坐标切换，坐标面板和列表同步换算。
- 拖动、点击放置和数值输入统一按 `coefficientFraction` 的 `2^-F` 网格就近舍入，避免出现定点无法表示的任意小数。
- 极坐标输入先换算为 Re/Im，再按同一定点网格量化。

### 2026-11-16 · SOS 零极点配对

- 极点组按剩余组中半径最大（最靠近单位圆）优先选择。
- 零点组按复平面根集距离最小选择；共轭对展开为 ±im，实根对做 2×2 最小匹配。
- 每选一对生成一节，最后按极点半径升序级联。
- 重新生成 24 组示例 RTL/TB/runner/golden；ModelSim `sos8` 自检通过。

### 2026-10-26 · RLC 网络

- 新增 8 个 RLC 串联/并联电压分压模块。
- 模拟单元总数 11 → 19。
- 旧工程自动补齐新单元默认实验。

### 2026-10-20 · 系统工作台与模块扩展

- 新增 DDS 波形发生器（正弦/方波/三角、频率控制字、I/Q 正交输出、BRAM 波表）。
- 新增偏移二进制 ↔ 有符号转换模块（正向/逆向，翻转最高位）。
- 系统端口新增常数激励，生成 `localparam`，不占顶层端口。
- 端口格式改为 `s.[W-F:F]` / `us.[W-F:F]` / `us[W:0]` 记法。
- 系统连接只比较位宽；端口点击变色并可直接连线。
- 基础模块新增饱和保护选项。

更早的滤波器时序、系统编辑、相位响应等记录见 [CHANGELOG.md](CHANGELOG.md)。

## 验证状态

- `run_tests.py`：**50/50 PASS**，0 FAIL，0 SKIP。
- `verify_release.py`：**527 个文件**哈希通过。
- `build-consistency`：**24 组**示例 RTL / testbench / runner / golden 与当前生成器一致。
- ModelSim 2020.4：新 SOS 配对后的 `sos8` 自检 **PASS**。
- 当前单文件 SHA-256：`c3387b7a502b786e9428b3e52eb51bbe21bb123d573ef4db4b81ca71b14550f4`。

已有 ModelSim 2020.4 / Vivado XSim 2022.2 示例仿真证据覆盖历史版本；代表 FO/SO/SOS8 在 xc7a50tfgg484-1 上通过 50 MHz OOC 内部时序，100 MHz 未通过。板级 I/O、完整时钟树和实物行为未验证。详情见 [VALIDATION.md](VALIDATION.md)。

## 开发与测试

仅使用网页无需执行以下命令。修改源码时需要 Python 3.10+ 和 Node.js；构建不需要第三方 Python 包。

```powershell
git clone https://github.com/2822034477-hub/AnalogStudio.git
cd AnalogStudio
python verify_release.py --rebuild
python run_tests.py --allow-missing-dom
```

缺少 jsdom 时 DOM 测试会明确跳过。需要完整回归时，运行 `npm ci --prefix testdeps`，再运行 `python run_tests.py`。测试退出码：0 全部通过，1 有失败，2 有跳过。Node 版本要求见 [开发说明](DEVELOPER_README.md)。

修改源模块后执行 `python rebuild.py` 更新单文件页面，再更新 `delivery-manifest.json` 中的哈希并运行校验。不要只修改生成的 HTML。

### 目录

- `digital-design.js`、`digital-root-editor.js`：数字模型和交互界面。
- `digital-sos.js`、`digital-width.js`：SOS 配对/实现、HDL 与位宽建议。
- `digital-magnitude.js`、`digital-response-plot.js`：幅频交越与响应图。
- `digital-modules.js`、`digital-system*.js`：基础模块、DDS、系统工作台与画布。
- `AnalogStudio.pre-workspace.html`、`AnalogStudio.folder-hierarchy.html`：构建及兼容性测试基线。
- `tests/`、`audit_expanded/`、`testdeps/`：回归和测试依赖清单。
- `examples/simulation/`：24 组轻量 HDL 仿真示例。

工具许可证、凭据、依赖目录、原始日志和仿真缓存不纳入仓库。同步步骤见 [SYNC.md](SYNC.md)。

## 文档

- [系统工作台操作说明](SYSTEM_WORKBENCH_GUIDE.md)
- [相位与实现延迟](PHASE_RESPONSE_GUIDE.md)
- [验证记录](VALIDATION.md)
- [开发说明](DEVELOPER_README.md)
- [更新记录](CHANGELOG.md)
