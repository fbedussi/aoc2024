import fs from 'fs'

const test = false

const inputTxt = fs.readFileSync(test ? './test-data.txt' : './data.txt', 'utf-8')

const lines = inputTxt.split(/\r?\n/)

const patterns = lines[0].split(", ")
const desired = lines.slice(2)

const cache = {}

const checkMatches = (matches, result) => {
    console.log(matches, result)
    if (matches.length === 0) {
        return 0
    }

    return matches.reduce((tot, match) => {
        const remaining = result.substring(match.length)
        return tot + isFeasible(remaining)
    }, 0)
}

const isFeasible = (result) => {
    if (result === "") {
        return 1
    }

    if (cache[result] !== undefined) {
        return cache[result]
    } else {
        const matches = patterns.filter(pattern => result.startsWith(pattern))
        const ways = checkMatches(matches, result)
        cache[result] = (cache[result] || 0) + ways
        return ways
    }
}

console.log(
    "result",
    desired.map(desired => {
        console.log(desired)
        return isFeasible(desired)
    }).reduce((tot, n) => tot + n, 0)
)
// 761826581538190