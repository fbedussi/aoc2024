import fs from 'fs'

const test = true

const inputTxt = fs.readFileSync(test ? './test-data.txt' : './data.txt', 'utf-8')

const map = inputTxt.split(/\r?\n/).map(line => line.split(''))

const findCell = (v) => {
    const y = map.findIndex(row => row.some(cell => cell === v))
    const x = map[y].findIndex(cell => cell === v)
    return [x, y]
}

const toKey = ([x, y]) => `${x}_${y}`

const bfsSearch = (map, start) => {
    const marked = {}
    const nodeFrom = {}

    const q = []
    marked[toKey(start)] = true
    q.push(start)

    while (q.length) {
        const [x, y] = q.pop()
        const cells = [
            [x + 1, y],
            [x, y + 1],
            [x - 1, y],
            [x, y - 1]
        ].filter(([x, y]) => map[y]?.[x] && map[y][x] !== '#')
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

console.log('end', findCell('E'))

console.log(
    'result',
    bfsSearch(map, findCell('S'))
)