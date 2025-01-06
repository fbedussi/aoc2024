import fs from 'fs'

const main = (test) => {
    const map = fs
        .readFileSync(test ? './test-data.txt' : './data.txt', 'utf-8')
        .split(/\r?\n/)
        .map(line => line.split(''))

    const toKey = ([x, y]) => `${x},${y}`

    const bfsSearch = (map, start) => {
        const marked = {}
        const nodeFrom = {}

        const q = []
        marked[toKey(start)] = true
        q.push(start)

        while (q.length) {
            const [x, y] = q.shift()
            const cells = [
                [x, y + 1],
                [x - 1, y],
                [x + 1, y],
                [x, y - 1],
            ].filter(([x, y]) => x >= 0 && x <= max && y >= 0 && y <= max && !obstacles[toKey([x, y])])
            cells.forEach(c => {
                if (!marked[toKey(c)]) {
                    nodeFrom[toKey(c)] = [x, y]
                    marked[toKey(c)] = true
                    q.push(c)
                }
            })
        }

        return nodeFrom
    }

    const pathTo = (nodeFrom, start, end) => {
        if (!nodeFrom[toKey(end)]) {
            throw new Error('Unreachable')
        }

        const path = []
        let node = end
        while (toKey(node) !== toKey(start)) {
            path.push(node)
            node = nodeFrom[node]
        }

        // path.push(start)
        path.reverse()
        return path
    }

    const print = (path, max) => {
        for (let y = 0; y <= max; y++) {
            const line = []
            for (let x = 0; x <= max; x++) {
                let cell = '.'
                if (obstacles[toKey([x, y])]) {
                    cell = '#'
                }
                if (path.find(([x2, y2]) => x2 === x && y2 === y)) {
                    cell = 'O'
                }
                line.push(cell)
            }
            console.log(line.join(''))
        }
    }

    const path = pathTo(bfsSearch(obstacles, max, [0, 0]), [0, 0], [max, max])
    console.log(
        'result',
        path.length
    )
}

test('day 16 - part1 - test', () => {
    assert.equal(main(true), 11048)
})

// test('day 16 - part1 - real', () => {
//     assert.equal(main(false), 11048)
// })

// print(path, max)