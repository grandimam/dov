package main

import (
    "fmt"
    "os"
    "strconv"
)

func arithmetic(n int64) int64 {
    var a, b int64 = 0, 1
    for index := int64(0); index < n; index++ {
        next := (a + b) % 1000000007
        a, b = b, next
    }
    return a
}

func sieve(n int64) int64 {
    var composite []int64
    for index := int64(0); index <= n; index++ {
        composite = append(composite, 0)
    }
    for p := int64(2); p*p <= n; p++ {
        if composite[p] == 0 {
            for multiple := p*p; multiple <= n; multiple += p {
                composite[multiple] = 1
            }
        }
    }
    var count int64
    for index := int64(2); index <= n; index++ {
        if composite[index] == 0 { count++ }
    }
    return count
}

func allocation(n int64) int64 {
    var checksum int64
    for batch := int64(0); batch < n; batch++ {
        var values []int64
        for index := int64(0); index < 128; index++ {
            values = append(values, (batch + index) % 1000)
        }
        for _, value := range values { checksum += value }
    }
    return checksum
}

func main() {
    n, err := strconv.ParseInt(os.Args[2], 10, 64)
    if err != nil { panic(err) }
    var result int64
    switch os.Args[1] {
    case "arithmetic": result = arithmetic(n)
    case "sieve": result = sieve(n)
    case "allocation": result = allocation(n)
    default: os.Exit(1)
    }
    fmt.Println(result)
}
