Definitions
-----------

n: Features  
m: Datapoints  
K: Clusters  
X: m×n dataset  


    class kMeans

####initialize
Initialize a new k-means clustering object.
Pass the following options, and proceed to clustering.
Options:

* `K` (Integer) *Default: 5*  
  The number of clusters.

* `maxIterations` (Integer) *Default: 100*  
  The number of iterations before the algorithm stops.

* `enableConvergenceTest` (Boolean) *Default: true*  
  Enable convergence test. This test can be computationally intensive, but 
  might also save many iterations.

* `tolerance` (Float) *Default: 1e-9*  
  Floating point value for the convergence tolerance.

* `initialize` (Function)  
  The function used to initialize the centroids.  
  *Default:* The Forgy method, which chooses K random datapoints, as the 
  initial centroids. You can also write your own, with the following signature 
  fn(X, K, m, n), where:

  * `X` (2D Array): The set of datapoints. Remember this is passed by reference 
    and is therefore **mutable**.
  * `K` (Integer): The number of centroids to initialize.
  * `m` (Integer): The number of datapoints in `X`.
  * `n` (Integer): The number of features of each datapoint in `X`.

* `distanceMetric` (Function)
  The function used to measure the distance between centroids and points in its 
  cluster.  
  **Default** is the sum of the squared error. Other metrics might be 
  manhattan distance or minkowski distance.



        constructor: (options = {}) ->
            @K = options.K ? 5
            @maxIterations = options.maxIterations ? 100
            @enableConvergenceTest = options.enableConvergenceTest ? true
            @tolerance = options.tolerance ? 1e-9
            @initialize = options.initialize ? kMeans.initializeForgy
            @distanceMetric = options.distanceMetric ? @sumSquared

            if not (1 <= @K < Infinity)
                throw "K must be in the interval [1, Infinity)"
            if not (1 <= @maxIterations < Infinity)
                throw "maxIterations must be in the interval [1, Infinity)"

####cluster
Initialize clustering over dataset `X`.
`X` should be a m×n matrix of m data rows and n feature columns.

        cluster: (@X) ->
            @prevCentroids = []
            @clusters = []
            @currentIteration = 0

            [@m, @n] = [@X.length, @X[0].length]

            if not @m? or not @n? or @n < 1
                throw "Data must be of the format [[x_11, ... , x_1n], ... , [x_m1, ... , x_mn]]"

            @centroids = @initialize(@X, @K, @m, @n)

            if @centroids.length != @K or @centroids[0].length != @n
                throw "`initialize` must return a K×n matrix"

####step
Used when custom logic is interleaved within the clustering process.
See `autoCluster(X)` method below for an example

        step: ->
            @currentIteration++ < @maxIterations


####autoCluster
Cluster dataset `X` by means of the standard algorithm:
1. Find closest centroid for each datapoint and assign it to the centroids cluster
2. Move the centroid to the mean of its cluster
3. *Optional* Check for convergence, by measuring the distance moved
   by the centroid since the last iteration

        autoCluster: (X) ->
            @cluster X

            while @step()
                @findClosestCentroids()
                @moveCentroids()

                break if @hasConverged()

####initializeForgy
The Forgy method uses K random data points as initial centroids. Accessed as 
`kMeans.initializeForgy`  
*O(K)*

        @initializeForgy: (X, K, m, n) ->
            X[Math.floor Math.random() * m] for k in [0...K]

####initializeInRange
This initialization places K centroids at random, within the range of the data points.
Accessed as `kMeans.initializeInRange`  
*O(n·m+K·n)*

        @initializeInRange: (X, K, m, n) ->
            
            min = Infinity for i in [0...n]
            max = -Infinity for i in [0...n]

            for x in X
                for d, i in x
                    min[i] = Math.min min[i], d
                    max[i] = Math.max max[i], d

            (for k in [0...K]
                (for d in [0...n]
                    Math.random() * (max[d] - min[d]) + min[d]
                )
            )

####findClosestCentroids
Assign each datapoint to the cluster of its closest centroid.
This is done by adding the datapoint's index to an array of clusters,
where the index of each cluster corrosponds to the index of the centroid for
that cluster.

        findClosestCentroids: ->
            if @enableConvergenceTest
                @prevCentroids = (r.slice(0) for r in @centroids) #Clone optimization


Datapoints will be assigned to clusters to optimize the move step
however, this means that it will be hard to find out which cluster a specific
datapoint belongs to, without probing every element of every cluster

            @clusters = ([] for i in [0...@K])

            for x, i in @X
                cMin = 0
                xMin = Infinity
                for c, j in @centroids
                    min = @distanceMetric c, x

                    if min < xMin
                        cMin = j
                        xMin = min

                @clusters[cMin].push i

####moveCentroids
Iterate through each cluster and move it's centroid to the mean of all
the datapoints in that cluster.

        moveCentroids: ->
            for cl, i in @clusters
                continue if cl.length < 1 #Avoid division by 0

                for j in [0...@n]
                    sum = 0
                    for d in cl
                        sum += @X[d][j]
                    @centroids[i][j] = sum/(cl.length)

####hasConverged
Check whether any of the elements of the absolute difference between the
previous centroid positions and the current are greater than a set tolerance.
In case they're none are greater, then the algorithm has converged.

        hasConverged: ->
            return false if not @enableConvergenceTest

            for i in [0...@n]
                for j in [0...@m]
                    absDelta = Math.abs @prevCentroids[i][j] - @centroids[i][j]
                    return true if @tolerance > absDelta

            return false

####sumSquared
The default distance metric used by the `findClosestCentroids` step. Takes the
square of the euclidian distances between points. A custom metric can be used by
changing the `options.distanceMetric` when initializing kMeans.

        sumSqured: (X, Y) ->
            sum = 0
            n   = X.length

            while n--
                sum += (Y[n] - X[n]) * (Y[n] - X[n])

            sum



Check whether module.exports or exports are present, otherwise attach the class
to the window object.

    if module?.exports? or exports?
        module.exports = exports = kMeans
    else
        window.kMeans = kMeans
