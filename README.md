# AnalogStudio

离线单文件模拟电路与数字滤波器设计工具。打开 `AnalogStudio.html` 即可使用，不依赖在线脚本。

数字系统使用统一的“数字设计”入口：传递函数 z⁻¹ 系数和零极点共用一个模型，支持 z 平面实轴单点/共轭对、数值输入、点击和拖动，以及差分方程、响应、定点 Verilog 和自检测试台生成。兼容旧数字工程，硬件实现仍限制为二阶直接型 I。

## 构建与测试

需要已有的 Python 3.10+ 和 Node.js。构建本身不需要第三方 Python 包。

```powershell
python verify_release.py --rebuild
python run_tests.py --allow-missing-dom
```

测试退出码：`0` 全部通过，`1` 有失败，`2` 有跳过。缺 jsdom 时不会自动安装依赖。需要完整 DOM 回归时，在明确决定安装后运行 `npm ci --prefix testdeps`，然后执行 `python run_tests.py`。锁文件所需 Node 版本见 [开发说明](DEVELOPER_README.md)。

源码修改后运行 `python rebuild.py` 更新 HTML，再运行测试；`delivery-manifest.json` 记录的是导入版本，发布新版本时应重新生成文件清单和哈希。请修改源模块，不要仅手改生成的 HTML。

## 内容

- `digital-design.js`、`digital-root-editor.js`：数字模型、HDL 生成和 z 平面交互。
- `project-manager*.js`、`branch-manager-patches.py`：工程保存和旧分类迁移。
- `AnalogStudio.folder-hierarchy.html`、`AnalogStudio.pre-workspace.html`：构建及兼容性测试所需基线，不能删除。
- `tests/`、`audit_expanded/`：回归；`testdeps/`：测试依赖清单和锁文件。
- `simulation-runners.js`、`run_vendor_checks.py`、`examples/simulation/`：仿真脚本与八个轻量 HDL 示例。

已有 ModelSim / XSim 可按各示例的 `SIMULATION_README.txt` 执行自检。安装路径只通过本机会话参数传入，不写入源码；不自动安装工具或修改许可证。

## 验证状态

导入版本 HTML SHA-256：`2afedf5a451dcc813c1609e4f1457b3099346bcc579d93a629527291709a0200`。

已有真实 RTL 行为仿真：ModelSim 2020.4 和 Vivado XSim 2022.2 各 8/8 PASS。可用回归 10 PASS、0 FAIL、23 SKIP；完整 DOM、原生浏览器/目录选择和真实文件夹保存流程仍有未测项。详见 [验证摘要](VALIDATION.md)。未验证综合、FPGA 时序/资源或硬件行为。

这是私有源码仓库；未添加开源许可证。依赖目录、许可证/凭据、个人路径、原始日志、仿真缓存和交付压缩包均不入库。同步步骤见 [SYNC.md](SYNC.md)。
