import fs from 'node:fs'
import assert from 'node:assert/strict';
import { test } from 'node:test';

const main = (test) => {
    const map = fs
        .readFileSync(test ? './test-data.txt' : './data.txt', 'utf-8')
        .split(/\r?\n/)
        .map(line => line.split(''))

    const toKey = ([x, y]) => `${x},${y}`

    const max = map.length - 1

    const start = [1, max - 1, 1]
    const end = [max - 1, 1, 1]
    const paths = []
    const visited = {}

    const bfsSearch = (node, path, points) => {
        path.push(node)

        if (toKey(node) === toKey(end)) {
            paths.push(path)
            return
        }

        const [x, y, d] = node
        const cells = [
            [x, y + 1, 4],
            [x - 1, y, 3],
            [x + 1, y, 1],
            [x, y - 1, 2],
        ].filter(([x, y]) => map[y][x] !== "#")
        for (let i = 0; i < cells.length; i++) {
            const c = cells[i]
            const [x2, y2, d2] = c

            const updatedPoints = points + (d2 === path.at(-1)[2] ? 1 : 1001)
            if (!path.find(step => step[0] === x2 && step[1] === y2) && (!visited[toKey(c)] || visited[toKey(c)] >= updatedPoints)) {
                visited[toKey(node)] = updatedPoints
                bfsSearch(c, [...path], updatedPoints)
            }
        }
    }

    const print = (path, max) => {
        for (let y = 0; y <= max; y++) {
            const line = []
            for (let x = 0; x <= max; x++) {
                let cell = map[y][x]
                if (path.find(([x2, y2]) => x2 === x && y2 === y)) {
                    cell = 'O'
                }
                line.push(cell)
            }
            console.log(line.join(''))
        }
    }

    const minPoints = bfsSearch(start, [], 0)

    // const calculatePoints = (path) => {
    //     const points = [0, ...path.slice(1).map((step, index) => step[2] === path[index][2] ? 1 : 1001)]
    //     const sum = points.reduce((sum, i) => sum + i, 0)
    //     return sum
    // }
    // const points = paths.map(calculatePoints)
    // const minPoint = Math.min(...points)
    // const minPathIndex = points.findIndex(n => n === minPoint)
    // const minPath = paths[minPathIndex]

    console.log(
        'result',
        minPoints
    )

    // print(path, max)
    return minPoints
}

test('day 16 - part1 - test', () => {
    assert.equal(main(true), 11048)
})

// test('day 16 - part1 - real', () => {
//     assert.equal(main(false), 11048)
// })
// 118428