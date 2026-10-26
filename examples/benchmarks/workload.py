"""Plain CPython: same loop algorithms, without NumPy or a JIT."""
import sys


def arithmetic(n):
    a, b = 0, 1
    for _ in range(n):
        next_value = (a + b) % 1_000_000_007
        a, b = b, next_value
    return a


def sieve(n):
    composite = []
    for _ in range(n + 1):
        composite.append(0)
    p = 2
    while p * p <= n:
        if composite[p] == 0:
            multiple = p * p
            while multiple <= n:
                composite[multiple] = 1
                multiple += p
        p += 1
    count = 0
    for index in range(2, n + 1):
        if composite[index] == 0:
            count += 1
    return count


def allocation(n):
    checksum = 0
    for batch in range(n):
        values = []
        for index in range(128):
            values.append((batch + index) % 1000)
        for value in values:
            checksum += value
    return checksum


if __name__ == "__main__":
    workloads = {"arithmetic": arithmetic, "sieve": sieve, "allocation": allocation}
    print(workloads[sys.argv[1]](int(sys.argv[2])))
