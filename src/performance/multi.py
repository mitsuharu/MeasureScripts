import multiprocessing
import time

# n秒待つだけの関数
def task(n):
    time.sleep(n)
    print(f"Task {n} done")

if __name__ == '__main__':

    # 直列処理
    start_time = time.time()
    task(2); task(2); task(2); task(2);
    print("直列処理時間:", time.time() - start_time)

    # 並列処理
    start_time = time.time()

    # 4つのプロセスを作成
    processes = [
        multiprocessing.Process(target=task, args=(2,)) for _ in range(4)
    ]

    # 各プロセスを開始
    for p in processes:
        p.start()

    # すべてのプロセスが終了するのを待つ
    for p in processes:
        p.join()

    # print("並列処理時間:", time.time() - start_time)
    print(f"並列処理時間: {(time.time() - start_time):.2f} 秒")