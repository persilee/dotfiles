# =========================================================
# ~/.config/zsh/flutter.zsh —— Flutter / FVM 环境
# 说明：FVM 4.x（Homebrew 安装），所有 Flutter SDK 版本统一放外置盘
# 加载：在 ~/.config/zsh/.zshrc 的「编程语言环境」段里 source 本文件
# =========================================================

# ---------- SDK 缓存目录（外置盘） ----------
# fvm install / fvm use 下载的每个 Flutter 版本都落在该目录下，
# 不占系统盘；也避免 ~/.fvm 或 ~/Library 里堆积多份 SDK。
# 注意：这里与 `fvm config --cache-path /Volumes/lsy/flutter/SDK` 保持一致，
# 前者保证当前 shell 生效，后者保证 IDE / GUI 工具里的 fvm 也能读到。
export FVM_CACHE_PATH="/Volumes/lsy/flutter/SDK"

# ---------- PATH：FVM 全局默认版本 ----------
# 只有执行过 `fvm global <version>` 才会生成 default 软链；
# 日常在项目里请用 `fvm flutter ...`，不要依赖这个全局入口，
# 否则容易出现「以为用的是项目锁定的版本，实际跑的是全局版本」。
if [[ -d "$FVM_CACHE_PATH/default/bin" ]]; then
  export PATH="$FVM_CACHE_PATH/default/bin:$PATH"
fi

# ---------- 国内镜像（必需） ----------
# 本机到 storage.googleapis.com 只有约 20KB/s，Dart SDK / 引擎产物会下几小时；
# 统一走 Flutter 官方中国镜像，实测 8.5MB/s。
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
export PUB_HOSTED_URL="https://pub.flutter-io.cn"

# ---------- 浏览器：Flutter Web / `flutter run -d chrome` ----------
# Chrome 装在外置盘 /Volumes/lsy/Applications，不在 /Applications，
# flutter doctor 默认找不到，用 CHROME_EXECUTABLE 显式指定
if [[ -x "/Volumes/lsy/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]]; then
  export CHROME_EXECUTABLE="/Volumes/lsy/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
fi

# ---------- 便捷别名 ----------
alias fv='fvm'                 # fvm 本体
alias fl='fvm flutter'         # 项目内 flutter 命令
alias fd='fvm dart'            # 项目内 dart 命令
alias fpub='fvm flutter pub'   # 依赖管理
alias fvmls='fvm list'         # 查看本机已缓存版本
