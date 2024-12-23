import fs from 'fs'
import assert from 'node:assert/strict';
import { test } from 'node:test';

const testData = false

const inputTxt = fs.readFileSync(testData ? './test-data.txt' : './data.txt', 'utf-8')

const data = inputTxt.split(/\r?\n/).filter(line => line !== "").map(line => line.split("-"))

const nodeNames = [...new Set(data.flat())]

const nodeMap = {}

nodeNames.forEach(name => {
    nodeMap[name] = {
        name,
        links: []
    }
})

data.forEach(([a, b]) => {
    if (!nodeMap[a].links.find(link => link.name === b)) {
        nodeMap[a].links.push(nodeMap[b])
    }
    if (!nodeMap[b].links.find(link => link.name === a)) {
        nodeMap[b].links.push(nodeMap[a])
    }
})

const results = []

const followLink = (node, result) => {
    if (result.length > 1 && result[0] === result[result.length - 1]) {
        if (result.length === 4) {
            results.push(result)
        }
    } else if (result.length < 4) {
        node.links.forEach(linkedNode => {
            followLink(linkedNode, [...result, linkedNode])
        })
    }
}
nodeNames.forEach(name => {
    followLink(nodeMap[name], [nodeMap[name]])
})

const dedupResults = [...new Set(results.map(result => result.slice(0, -1).sort((a, b) => {
    return a.name > b.name ? 1 : -1
}).map(node => node.name).join(',')))]

const filteredResult = dedupResults.filter(result => result.split(',').some(pc => pc.startsWith('t')))

console.log(
    "result",
    filteredResult,
    filteredResult.length
)
// 1323

test('day 23 - part1', () => {
    assert.equal(filteredResult.length, testData ? 7 : 1323)
})
