extern crate reqwest;

use std::io::Read;

fn main() {
    let mut res = reqwest::get("https://www.google.com/robots.txt").expect("failed to fetch");
    let mut body = String::new();
    res.read_to_string(&mut body);
}
