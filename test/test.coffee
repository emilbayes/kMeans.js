kMeans = require '../kMeans'
loadCsv = require './load-csv'

describe 'kMeans', ->
    describe 'clustering', ->
        it 'should find 5 clusters with the specified centroids', ->
            EPSILON = 1e-2
            means = [
                        [ 100,  100]
                        [-100,  100]
                        [-100, -100]
                        [ 100, -100]
                        [   0,    0]
                    ]

            km = new kMeans
                K: 5
                initialize: ->
                    means

            X = ( (+c for c in r) for r in loadCsv('test/testData-K5.csv', [1, 2])[1..])

            km.autoCluster X

            for mu, i in means
                for dim, j in mu
                    km.centroids[i][j].should.be.within dim - EPSILON, dim + EPSILON


            console.log km.centroids, (c.length for c in km.clusters)
