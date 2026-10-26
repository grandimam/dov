from std.sys import argv
from std.collections import List


def arithmetic(n: Int) -> Int:
    var a = 0
    var b = 1
    for _ in range(n):
        var next_value = (a + b) % 1000000007
        a = b
        b = next_value
    return a


def sieve(n: Int) -> Int:
    var composite = List[Int]()
    for _ in range(n + 1):
        composite.append(0)
    var p = 2
    while p * p <= n:
        if composite[p] == 0:
            var multiple = p * p
            while multiple <= n:
                composite[multiple] = 1
                multiple += p
        p += 1
    var count = 0
    for index in range(2, n + 1):
        if composite[index] == 0:
            count += 1
    return count


def allocation(n: Int) -> Int:
    var checksum = 0
    for batch in range(n):
        var values = List[Int]()
        for index in range(128):
            values.append((batch + index) % 1000)
        for index in range(len(values)):
            checksum += values[index]
    return checksum


def main() raises:
    var args = argv()
    var n = Int(args[2])
    if args[1] == "arithmetic":
        print(arithmetic(n))
    elif args[1] == "sieve":
        print(sieve(n))
    elif args[1] == "allocation":
        print(allocation(n))
    else:
        raise Error("unknown workload")
