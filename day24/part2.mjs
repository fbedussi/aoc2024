import fs from 'fs'
import assert from 'node:assert/strict';
import { test } from 'node:test';

const main = (testData) => {
    const inputTxt = fs.readFileSync(testData ? './test-data.txt' : './data.txt', 'utf-8')

    const lines = inputTxt.split(/\r?\n/)
    const emptyLineIndex = lines.findIndex(line => line === '')

    const data1 = lines.slice(0, emptyLineIndex).map(line => line.split(': ')).map(([key, val]) => [key, BigInt(val)])
    const data2 = lines.slice(emptyLineIndex + 1).map(line => line.split(' -> ').reverse())

    const gates = {}

    data1.forEach(([k, v]) => {
        gates[k] = function () { return [k] }
    })

    data2.forEach(([k, v]) => {
        const [k1, operator, k2] = v.split(' ')

        gates[k] = () => [gates[k1]()].concat(gates[k2]()).flat()
    })

    const result = Object.keys(gates)
        .filter(key => key.startsWith('z'))
        .sort()
        .reverse()
        .reduce((result, key) => {
            result[key] = gates[key]()
            return result
        }, {})

    console.log(
        "result",
        testData ? "test" : "real",
        result
    )

    return result
}

test('day 23 - part1 - test', () => {
    assert.equal(main(true), 2024)
})

// test('day 23 - part1 - real', () => {
//     assert.equal(main(false), 2024)
// })
