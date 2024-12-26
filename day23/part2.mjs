import fs from 'fs'
import assert from 'node:assert/strict';
import { test } from 'node:test';

const main = (testData) => {
    const inputTxt = fs.readFileSync(testData ? './test-data.txt' : './data.txt', 'utf-8')

    const data = inputTxt.split(/\r?\n/).filter(line => line !== "").map(line => line.split("-"))

    const nodeNames = [...new Set(data.flat())]

    const nodeMap = nodeNames.reduce((result, name) => {
        result[name] = {
            name,
            links: []
        }
        return result
    }, {})

    data.forEach(([a, b]) => {
        if (!nodeMap[a].links.find(link => link.name === b)) {
            nodeMap[a].links.push(nodeMap[b])
        }
        if (!nodeMap[b].links.find(link => link.name === a)) {
            nodeMap[b].links.push(nodeMap[a])
        }
    })

    const nodeCount = nodeNames
        .reduce((result, nodeName) => {
            result[nodeName] = [nodeName, ...nodeMap[nodeName].links.map(link => link.name)].sort()
            return result
        }, {})

    const similarity = (arr1, arr2) => arr1.filter(el => arr2.includes(el)).length

    const frequencyMap = nodeNames.reduce((result, nodeName) => {
        result[nodeName] = nodeNames
            .filter(nodeName2 => nodeName2 !== nodeName)
            .map(nodeName2 => [nodeName2, similarity(nodeCount[nodeName], nodeCount[nodeName2])])
        return result
    }, {})


    const sets = nodeNames.map(nodeName => {
        const freq = frequencyMap[nodeName].map(([_, n]) => n)
        const max = Math.max(...freq)
        const numberOfMax = freq.filter(f => f === max).length
        if (numberOfMax === max - 1) {
            return [nodeName, max]
        } else {
            return
        }
    })
        .filter(Boolean)
        .sort(([_, c1], [__, c2]) => c2 - c1)

    const max = Math.max(...sets.map(([, c]) => c))

    const largestSet =
        sets
            .filter(([_, n]) => n === max)
            .map(([a, _]) => a)
            .sort()
            .join(',')

    console.log(
        "result",
        testData ? "test" : "real",
        largestSet,
    )

    return largestSet
}

test('day 23 - part2 - test', () => {
    assert.equal(main(true), 'co,de,ka,ta')
})

test('day 23 - part2 - real', () => {
    assert.equal(main(false), 'er,fh,fi,ir,kk,lo,lp,qi,ti,vb,xf,ys,yu')
})
