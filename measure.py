
# pip install psutil
# python measure.py

import psutil
import subprocess
import time
import argparse

def monitor_process(executable_path):
    # 測定対象のプログラムを開始
    process = subprocess.Popen([executable_path], stdout=subprocess.PIPE)

    # 初期値を取得
    initial_cpu = psutil.cpu_percent(interval=0.1)  # 実行前のCPU使用率
    initial_memory = psutil.virtual_memory().used  # 実行前のメモリ使用量 (バイト)

    # 最大値を記録するための変数
    max_cpu_usage = 0
    max_memory_usage = 0

    start_time = time.time()

    # プロセスが終了するまでモニタリング
    while process.poll() is None:
        # 現在のCPUとメモリの使用量を取得
        cpu_usage = psutil.cpu_percent(interval=0.1)
        memory_info = psutil.virtual_memory().used

        # 最大値を更新
        max_cpu_usage = max(max_cpu_usage, cpu_usage)
        max_memory_usage = max(max_memory_usage, memory_info)

        # オプション: リアルタイムで表示 (必要に応じて削除可能)
        # print(f"CPU Usage: {cpu_usage}%, Memory Usage: {(memory_info - initial_memory) / (1024 ** 2):.2f} MB")

    end_time = time.time()

    # 実行時間を計算
    execution_time = end_time - start_time

    # 結果を表示
    print("\n--- Monitoring Results ---")
    print(f"Execution time: {execution_time:.2f} seconds")
    print(f"Maximum CPU Usage: {max_cpu_usage:.2f}%")
    print(f"Maximum Memory Usage: {(max_memory_usage - initial_memory) / (1024 ** 2):.2f} MB")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Monitor CPU and memory usage of an executable.")
    
    # `-e` or `--exe` のオプション (実行ファイルのパス)
    parser.add_argument("-e", "--exe", required=True, help="Path to the executable file")
    
    # `-c` or `--count` のオプション (数値)
    parser.add_argument("-c", "--count", type=int, required=False, help="Number of iterations")

    # 引数をパース
    args = parser.parse_args()

    # 受け取った値の表示
    print(f"Executable Path: {args.exe}")
    print(f"Count: {args.count}")

    monitor_process(args.exe)
