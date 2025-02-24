import time

data = list(range(1000000))
start_time = time.time()
999999 in data  # リストの検索
print("リスト検索時間:", time.time() - start_time)
print(f"リスト検索時間: {(time.time() - start_time)*1000:.2f} ミリ秒")

set_data = set(data)
start_time = time.time()
999999 in set_data  # セットの検索
print("セット検索時間:", time.time() - start_time)
print(f"セット検索時間: {(time.time() - start_time)*1000:.2f} ミリ秒")