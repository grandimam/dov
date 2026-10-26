use std::env;

fn arithmetic(n: i64) -> i64 {
    let (mut a, mut b) = (0_i64, 1_i64);
    for _ in 0..n {
        let next = (a + b) % 1_000_000_007;
        a = b;
        b = next;
    }
    a
}

fn sieve(n: i64) -> i64 {
    let mut composite: Vec<i64> = Vec::new();
    for _ in 0..=n { composite.push(0); }
    let mut p = 2_i64;
    while p * p <= n {
        if composite[p as usize] == 0 {
            let mut multiple = p * p;
            while multiple <= n {
                composite[multiple as usize] = 1;
                multiple += p;
            }
        }
        p += 1;
    }
    let mut count = 0_i64;
    for index in 2..=n {
        if composite[index as usize] == 0 { count += 1; }
    }
    count
}

fn allocation(n: i64) -> i64 {
    let mut checksum = 0_i64;
    for batch in 0..n {
        let mut values: Vec<i64> = Vec::new();
        for index in 0..128 { values.push((batch + index) % 1000); }
        for value in &values { checksum += value; }
    }
    checksum
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let n: i64 = args[2].parse().unwrap();
    let result = match args[1].as_str() {
        "arithmetic" => arithmetic(n),
        "sieve" => sieve(n),
        "allocation" => allocation(n),
        _ => std::process::exit(1),
    };
    println!("{result}");
}
