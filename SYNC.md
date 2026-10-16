# 本机与云端同步

唯一远端：`https://github.com/2822034477-hub/AnalogStudio.git`，公开，默认分支 `main`。

在工程目录打开终端，开始工作前先检查状态并取回更新：

```powershell
git status --short
git pull --ff-only
```

有本地未提交修改时先整理并提交；遇到分支分叉或冲突时停下来处理，不使用强制推送或重置覆盖另一端。

修改源模块后运行构建与可用测试，再检查将要同步的文件：

```powershell
python rebuild.py
python run_tests.py --allow-missing-dom
git diff --stat
git diff
git add -A
git diff --cached --stat
git commit -m "Describe the change"
git push
```

测试返回码 `2` 表示存在跳过，不能记录成完整通过。发布新版本前更新 `delivery-manifest.json` 并运行 `python verify_release.py --rebuild`。

本机仓库使用现有 GitHub CLI 登录状态进行 HTTPS 认证；仓库配置中不保存令牌值。不在此仓库提交 `.env`、令牌、工具许可证、私人目录信息、生成日志或仿真缓存；`.gitignore` 提供常见排除规则，每次仍需检查暂存区。

另一台已配置 Git/GitHub 访问权限的环境可运行：

```powershell
git clone https://github.com/2822034477-hub/AnalogStudio.git
cd AnalogStudio
python verify_release.py --rebuild
```

双方交替使用 pull → 编辑/验证 → commit → push 即可。未配置定时同步、自动部署或自动安装依赖。

公开分发：使用者可下载 Releases 中的 AnalogStudio.html，或下载仓库 ZIP 并解压；打开 HTML 不需要安装开发依赖。
