#!/bin/bash

# デフォルト値
EXECUTABLE=""
RUN_COUNT=10
OUTPUT_FILE="output.csv"
OUTPUT_DIR="dist"

# 使用方法
usage() {
  echo "Usage: $0 -e <executable> [-c <run_count>] [-o <output_file>]"
  echo "  -e: 実行するファイルのパス (必須)"
  echo "  -c: 実行回数 (デフォルト: 10)"
  echo "  -o: 出力CSVファイル名 (デフォルト: output.csv)"
  exit 1
}

# gtime のコマンドが存在するか確認
if ! command -v gtime &> /dev/null; then
  echo "gtime コマンドが見つかりません。GNU time が必要です。"
  echo "Homebrew で gnu-time をインストールしてください。"
  echo "brew install gnu-time"
  exit 1
fi

# 引数の解析
while getopts "e:c:o:" opt; do
  case $opt in
    e) EXECUTABLE="$OPTARG" ;;
    c) RUN_COUNT="$OPTARG" ;;
    o) OUTPUT_FILE="$OPTARG" ;;
    *) usage ;;
  esac
done

# 実行ファイルが指定されていない場合はエラー
if [[ -z "$EXECUTABLE" ]]; then
  echo "Error: 実行ファイルが指定されていません"
  usage
fi

# 値を保存する配列を初期化
real_time_list=()
user_time_list=()
sys_time_list=()
memory_list=()
cpu_usage_list=()

if [ ! -d "$OUTPUT_DIR" ]; then
  mkdir $OUTPUT_DIR
fi

# CSVのヘッダーを書き込み
echo "# Elapsed Time(sec),System Time(sec),User Time(sec),CPU Usage(%),MaxMemory(MB)" > "$OUTPUT_DIR/$OUTPUT_FILE"

# 指定回数実行
for (( i=1; i<=RUN_COUNT; i++ )); do
  # /usr/bin/timeで実行し、出力を解析
  OUTPUT=$(gtime -f "%e %U %S %M" "$EXECUTABLE" 2>&1 >/dev/null)

  # 出力結果を分割して取得
  REAL_TIME=$(echo "$OUTPUT" | awk '{print $1}')    # 経過時間 (Elapsed time)
  USER_TIME=$(echo "$OUTPUT" | awk '{print $2}')    # ユーザーモード時間 (User CPU time)
  SYS_TIME=$(echo "$OUTPUT" | awk '{print $3}')     # システムモード時間 (System CPU time)
  MEMORY=$(echo "$OUTPUT" | awk '{print $4}')       # メモリ最大使用量 (Maximum resident set size)
  MEMORY_MB=$(echo "scale=2; $MEMORY / 1024" | bc)

  # CPU利用率を計算
  CPU_USAGE=$(echo "scale=2; ($USER_TIME + $SYS_TIME) / $REAL_TIME * 100" | bc)

  # 結果を配列に格納
  real_time_list+=("$REAL_TIME")
  user_time_list+=("$USER_TIME")
  sys_time_list+=("$SYS_TIME")
  memory_list+=("$MEMORY_MB")
  cpu_usage_list+=("$CPU_USAGE")

  # 結果をCSVに追加
  echo "$REAL_TIME,$USER_TIME,$SYS_TIME,$CPU_USAGE,$MEMORY_MB" >> "$OUTPUT_DIR/$OUTPUT_FILE"
done

echo "結果が $OUTPUT_FILE に保存されました。"

# 平均を計算する関数
calculate_mean() {
  local values=("$@")  # 配列引数
  local sum=0
  local count=${#values[@]}
  
  # 平均を計算
  for v in "${values[@]}"; do
    sum=$(echo "$sum + $v" | bc)
  done
  local mean=$(echo "scale=2; $sum / $count" | bc)

  # 結果を返す
  printf "%.2f" "$mean"
}

# 各値の平均を計算
real_mean=$(calculate_mean "${real_time_list[@]}")
user_mean=$(calculate_mean "${user_time_list[@]}")
sys_mean=$(calculate_mean "${sys_time_list[@]}")
memory_mean=$(calculate_mean "${memory_list[@]}")
cpu_mean=$(calculate_mean "${cpu_usage_list[@]}")

# 結果を表示
echo "==== 平均結果 ===="
echo "経過時間 (REAL_TIME): 平均 $real_mean 秒"
echo "ユーザーモード時間 (USER_TIME): 平均 $user_mean 秒"
echo "システムモード時間 (SYS_TIME): 平均 $sys_mean 秒"
echo "メモリ使用量 (MEMORY): 平均 $memory_mean MB"
echo "CPU利用率 (CPU_USAGE): 平均 $cpu_mean %"
