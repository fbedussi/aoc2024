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
        return false
    }

    return matches.some(match => {
        const remaining = result.substring(match.length)
        return isFeasible(remaining)
    })
}

const isFeasible = (result) => {
    if (result === "") {
        return true
    }

    if (cache[result] !== undefined) {
        console.log('cache')
        return cache[result]
    } else {
        const matches = patterns.filter(pattern => result.startsWith(pattern))
        const isValid = checkMatches(matches, result)
        cache[result] = isValid
        return isValid
    }
}

console.log(
    "result",
    desired.filter(desired => {
        console.log(desired)
        return isFeasible(desired)
    }).length
)