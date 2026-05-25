#!/usr/bin/env bash
# 在终端展示各服务启动成功日志（Maven 风格摘要 + 关键行）

set -eo pipefail

LOG_DIR="${LOG_DIR:-/tmp/spring-cloud-demo}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

show_service() {
  local key="$1"
  local port="$2"
  local app="$3"
  local log="$LOG_DIR/${key}.log"

  echo "[INFO] --- ${key} (port ${port}) ---"

  if [[ ! -f "$log" ]]; then
    echo "[WARN] 日志不存在: $log"
    return 1
  fi

  local started tomcat
  started=$(grep -E "Started ${app}" "$log" 2>/dev/null | tail -1 || true)
  tomcat=$(grep -E "Tomcat started|Netty started" "$log" 2>/dev/null | tail -1 || true)

  if [[ -n "$started" ]]; then
    echo "[INFO] $started"
    [[ -n "$tomcat" ]] && echo "[INFO] $tomcat"
    if lsof -i ":$port" -sTCP:LISTEN >/dev/null 2>&1; then
      echo "[INFO] 端口 ${port} 监听中 — 运行正常"
      return 0
    fi
    echo "[WARN] 端口 ${port} 未监听 — 进程可能已退出"
    return 1
  fi

  echo "[ERROR] 未找到启动成功标记 (Started ${app})"
  tail -5 "$log" | sed 's/^/[ERROR] /'
  return 1
}

echo ""
echo "================================================================================"
echo "  Spring Cloud Demo — 服务启动日志"
echo "  项目: $ROOT_DIR"
echo "  日志目录: $LOG_DIR"
echo "================================================================================"
echo ""

ok=0
fail=0

for item in "eureka:8761:EurekaServerApplication" "config:8888:ConfigServerApplication" "demo:8081:DemoServiceApplication" "gateway:8080:GatewayServerApplication"; do
  IFS=':' read -r key port app <<< "$item"
  if show_service "$key" "$port" "$app"; then
    ok=$((ok + 1))
  else
    fail=$((fail + 1))
  fi
  echo ""
done

echo "================================================================================"
if [[ $fail -eq 0 ]]; then
  echo "[INFO] BUILD SUCCESS — 全部 4 个服务启动成功"
  echo "[INFO] 网关接口: http://localhost:8080/api/demo/hello"
  echo "[INFO] 直连接口: http://localhost:8081/hello"
  echo "[INFO] Eureka:    http://localhost:8761"
else
  echo "[WARN] 部分服务未就绪 (成功: $ok, 异常: $fail)"
  echo "[INFO] 实时日志: tail -f $LOG_DIR/*.log"
fi
echo "================================================================================"
echo ""

if [[ "${1:-}" == "-f" ]]; then
  echo "[INFO] 跟踪实时日志 (Ctrl+C 退出)..."
  tail -f "$LOG_DIR"/*.log
fi
