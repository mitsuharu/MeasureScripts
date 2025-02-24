from functools import reduce

data = [1, 2, 3, 4, 5]
result = reduce(lambda x, y: x + y, data)
print(result)

data = [1, 2, 3, 4, 5]
result = sum(data)
print(result)
