#!/usr/bin/env bash
# 交叉编译 Windows 版 bh3scan（容器内运行 cargo-xwin，本机无需安装 clang/MSVC）
#
# 用法:   ./build-win.sh [额外 cargo 参数...]
# 产物:   target/x86_64-pc-windows-msvc/release/bh3scan.exe
#
# 说明:
#   - 优先使用 podman，其次 docker
#   - cargo registry 通过命名卷 bh3scan-cargo-registry 持久化，
#     重跑时无需重新下载 crates.io 依赖
#   - target/ 挂载自项目目录，构建中间产物在宿主机上增量保留

set -euo pipefail

cd "$(dirname "$0")"

if command -v podman >/dev/null 2>&1; then
    RUNNER=podman
elif command -v docker >/dev/null 2>&1; then
    RUNNER=docker
else
    echo "错误: 未找到 podman 或 docker，请先安装其一" >&2
    exit 1
fi

# 仅在交互终端下分配 TTY，避免 CI/管道环境报 "not a TTY"
TTY_FLAG=()
if [ -t 0 ]; then
    TTY_FLAG=(-t)
fi

echo ">>> 使用 $RUNNER 交叉编译 x86_64-pc-windows-msvc ..."
"$RUNNER" run --rm "${TTY_FLAG[@]}" \
    -v "$(pwd):/io" -w /io \
    -v bh3scan-cargo-registry:/usr/local/cargo/registry \
    messense/cargo-xwin \
    cargo xwin build --release --target x86_64-pc-windows-msvc "$@"

echo
echo ">>> 完成: target/x86_64-pc-windows-msvc/release/bh3scan.exe"
