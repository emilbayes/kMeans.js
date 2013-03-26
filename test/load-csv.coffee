fs = require 'fs'

#http://stackoverflow.com/questions/2970525/javascript-regex-camel-case-sentence-case
camelCase = (str) ->
    str.replace(/(?:^\w|[A-Z]|\b\w)/g, (letter, index) ->
        if index == 0 then letter.toLowerCase() else letter.toUpperCase()
    ).replace /\s+/g, ''

#Can't remember where I got this from. Please add a source if you recognise it
CsvParseLine = (line) ->

    fields = line.split ','

    for field, i in fields

        chunk  = field.replace /^[\s]*|[\s]*$/g, ''
        quote   = ''

        if chunk.charAt(0) is '"' or chunk.charAt(0) is '"'
            quote = chunk.charAt(0)
        if quote isnt "" and quote is chunk.charAt chunk.length - 1
            quote = ""

        if quote isnt ""

            j = i+1

            if j < fields.length
                chunck = fields[j].replace /^[\s]*|[\s]*$/g, ''

            while j < fields.length and quote isnt chunk.charAt chunk.length - 1

                fields[i] += ',' + fields[j]
                fields.splice j, 1
                chunck = fields[j].replace /[\s]*$/g, ''

            if j < fields.length
                fields[i] += ',' + fields[j]
                fields.splice j, 1

    for i in [0...fields.length]

        fields[i] = fields[i].replace /^[\s]*|[\s]*$/g, ''

        if '"' is fields[i].charAt 0
            fields[i] = fields[i].replace /^"|"$/g, ''
        if "'" is fields[i].charAt 0
            fields[i] = fields[i].replace /^'|'$/g, ''

    fields


CsvToJson = (csv, columns) ->
    rows = csv.split /[\r\n]/g

    for i in [0...rows.length]

        if '' is rows[i].replace /^[\s]*|[\s]*$/g, ''
            rows.splice i--, 1

    if rows.length < 2
        throw new Error 'Not enough rows to parse (Must have a header and data row)'

    objArr = []

    rows = (CsvParseLine(row) for row in rows)

    for j in [0...rows[0].length]
        rows[0][j] = camelCase rows[0][j]

    indexes = (rows[0].indexOf(column) for column in columns)

    for i in [1...rows.length]

        if rows[i].length > 0
            objArr.push []

        for j in [0...indexes.length]
            objArr[i - 1][j] = rows[i][indexes[j]]

    objArr

parseCsv = (csv, columnsRange) ->
    rows = csv.split /[\r\n]/g

    for i in [0...rows.length]

        if '' is rows[i].replace /^[\s]*|[\s]*$/g, ''
            rows.splice i--, 1

    if rows.length < 2
        throw new Error 'Not enough rows to parse (Must have a header and data row)'

    columnsRange[0] = Math.max 0, columnsRange[0]
    columnsRange[1] = Math.min rows[1].length, columnsRange[1]

    (CsvParseLine(row)[columnsRange[0]..columnsRange[1]] for row in rows)

module.exports = loadCsv = (file, columnsRange = [0, Infinity]) ->
    contents = fs.readFileSync file
    return parseCsv contents.toString(), columnsRange
