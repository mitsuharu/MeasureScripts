import random
import time

def bubble_sort(arr):
    n = len(arr)
    for i in range(n):
        for j in range(0, n - i - 1):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]

def quick_sort(arr):
    if len(arr) <= 1:
        return arr
    pivot = arr[len(arr) // 2]
    left = [x for x in arr if x < pivot]
    middle = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]
    return quick_sort(left) + middle + quick_sort(right)

arr = [random.randint(0, 100000) for _ in range(10000)]

start_time = time.time()
bubble_sort(arr.copy())
print("バブルソート時間:", time.time() - start_time)
print(f"バブルソート時間: {(time.time() - start_time)*1000:.2f} ミリ秒")

start_time = time.time()
quick_sort(arr.copy())
print("クイックソート時間:", time.time() - start_time)
print(f"クイックソート時間: {(time.time() - start_time)*1000:.2f} ミリ秒")

start_time = time.time()
arr.copy().sort()
print("標準ソート時間:", time.time() - start_time)
print(f"標準ソート時間: {(time.time() - start_time)*1000:.2f} ミリ秒")