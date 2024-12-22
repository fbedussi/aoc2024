import fs from 'fs'
import assert from 'node:assert/strict';
import { test } from 'node:test';

const testData = true

const inputTxt = fs.readFileSync(testData ? './test-data.txt' : './data.txt', 'utf-8')

const lines = inputTxt.split(/\r?\n/).filter(line => line !== "").map(Number)

const mix = (n1, n2) => n1 ^ n2

const prune = (n) => n % 16777216

const calculate = (iterations) => (n) => {
    for (let i = 0; i < iterations; i++) {
        const n1 = prune(mix(n * 64, n))
        const n2 = prune(mix(Math.floor(n1 / 32), n1))
        n = prune(mix(n2 * 2048, n2))
        console.log(i + 1, n)
    }
    return n
}


calculate(10)(123)

// test('123', () => {
//     assert.equal(calculate(10)(123), 5908254)
// assert.equal(calculate(1)(15887950), 16495136)
// assert.equal(calculate(1)(16495136), 527345)
// assert.equal(calculate(1)(527345), 704524)
// assert.equal(calculate(1)(704524), 1553684)
// })
// console.log(
//     "result",
//     lines
//         .map(calculate(2000))
//         .reduce((tot, n) => tot + n)
// )