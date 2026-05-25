#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -z "${JAVA_HOME:-}" ]]; then
  if [[ -d /Library/Java/JavaVirtualMachines/jdk-1.8.jdk/Contents/Home ]]; then
    export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-1.8.jdk/Contents/Home
    export PATH="$JAVA_HOME/bin:$PATH"
  fi
fi

MODULES=(
  "eureka-server"
  "config-server"
  "demo-service"
  "gateway-server"
)

if [[ "${1:-}" == "build" ]]; then
  ./mvnw clean package -DskipTests
  exit 0
fi

if [[ "${1:-}" == "stop" ]]; then
  pkill -f "spring-cloud-demo/.*/target/.*\.jar" || true
  exit 0
fi

echo "Building all modules..."
./mvnw clean package -DskipTests -q

PIDS=()
cleanup() {
  for pid in "${PIDS[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
}
trap cleanup EXIT INT TERM

start_module() {
  local module="$1"
  local jar
  jar="$(ls "$ROOT_DIR/$module/target/"*.jar 2>/dev/null | grep -v '\.original$' | head -1)"
  if [[ -z "$jar" ]]; then
  echo "Jar not found for $module"
    exit 1
  fi
  echo "Starting $module ..."
  java -jar "$jar" &
  PIDS+=("$!")
  sleep 8
}

start_module eureka-server
start_module config-server
start_module demo-service
start_module gateway-server

echo
echo "All services started."
echo "Eureka:  http://localhost:8761"
echo "Config:  http://localhost:8888/demo-service/default"
echo "Gateway: http://localhost:8080/api/demo/hello"
echo
echo "Press Ctrl+C to stop all services."

wait
