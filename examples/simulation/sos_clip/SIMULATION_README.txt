AnalogStudio 数字滤波器：本地仿真 / Codex 任务说明
================================================

此包只是生成的源码与运行脚本，不代表已在 ModelSim、Questa 或 Vivado 中仿真通过。
浏览器不会调用本机 EDA 软件；只有本机真正运行后，才能给出仿真结果。

文件与接口
- RTL：digital_filter.v；顶层模块：digital_filter
- 自检 testbench：digital_filter_tb.sv；顶层：digital_filter_tb
- 仿真激励时钟周期 10 ns；同步低有效 rst_n 复位；每个上升沿接收输入。实际 clk 频率由外部匹配 RTL 注释的 Fs。
- 只有 clk/rst_n/data_in/data_out 四端口；接收沿计第1拍，一阶1拍、二阶2拍，级联相加；顶层不加寄存级。零阶增益1拍；显式延迟另加。
- RTL 的 LATENCY_CYCLES 给出总拍数，EDGE_OFFSET 给出相对接收沿的后续沿数；复位清空所有状态和填充输出。
- TB 在下降沿驱动，在上升沿后 1 ns 检查，避免与非阻塞赋值竞争。
- 黄金输出来自导出模型的定点整数参考：包含满量程输入、符号、连续采样、流水延迟和复位。
- 是否真正发生输出饱和取决于此模型的系数与位宽；不能把满量程输入等同于饱和覆盖。

Windows 运行
1. 完整解压到一个可写目录，保持所有文件在同一级；不要直接在 ZIP 预览窗口中运行。
2. 使用已安装、已有合法许可的工具命令行。不会自动安装软件、修改许可或索取凭据。
3. ModelSim / Questa：确认 vsim 可用后，运行 run_modelsim.bat。
   日志：modelsim_run.log；编译库：analogstudio_modelsim_build。
4. Vivado XSim：使用现有 Vivado 命令提示符，确认 xvlog、xelab、xsim 可用，运行 run_xsim.bat。
   日志：analogstudio_xsim_build\xsim_run.log；中间文件保存在该目录。
5. 通过条件：脚本退出码为 0，且本轮日志含以下精确文本：
   PASS: four-port SOS, continuous samples, reset, latency
   非零退出码、找不到 PASS、编译/展开失败或任一 mismatch 都不能报告通过。
   启动失败时日志可能尚未生成；请保留命令行错误。
6. 脚本复用专用构建目录并覆盖本轮日志；请勿在该目录放手工源码。并行运行请用不同解压目录。

交给本地 Codex 的任务（在解压目录中打开任务）
请先只读确认本机可用的 ModelSim/Questa 或 Vivado/XSim 路径与版本。
仅使用现有工具运行本包对应 .bat；不要安装工具、改变许可/权限或访问无关文件。
记录实际命令、工具版本、编译/展开/运行退出码及日志中的 PASS/FAIL。
如果工具不存在、不可用或许可受限，请准确报告阻塞，不要用浏览器/JavaScript 结果冒充 HDL 仿真。
若需改动，先说明问题；保留原源码与改动 diff，并在重新运行后附日志。
最终回复：实际仿真器与版本、测试模块、通过/失败/未运行、日志路径、发现的问题。

验证范围
这是 RTL 行为仿真，不等同于综合、时序收敛、FPGA 资源评估、CDC 或实物验证。
本包仅针对导出的模型；不是全部可能系数/位宽组合的形式验证。
无需 FPGA 器件库：导出 RTL 仅使用通用寄存器、算术及控制逻辑。

命令依据与版本说明
命令形式依据 AMD UG900 2025.2 / 2023.2，以及官方 ModelSim 文档和 Intel 示例。
尚未声称在任一厂商/版本上实测；本机以已安装版本的帮助及实际日志为准。
https://docs.amd.com/r/2025.2-English/ug900-vivado-logic-simulation/xelab-xvhdl-and-xvlog-xsim-Command-Options
https://docs.amd.com/r/2023.2-English/ug900-vivado-logic-simulation/Using-a-tclbatch-File
https://www.intel.com/content/www/us/en/docs/programmable/691269/22-3-2-0-0/simulating-the-design-example-testbench.html
https://ww1.microchip.com/downloads/aemDocuments/documents/FPGA/swdocs/modelsim/modelsim_user_2024_2.pdf
