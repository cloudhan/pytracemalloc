import tracemalloc

# allocate some memory
x = range(10000)

snapshot = tracemalloc.take_snapshot()
