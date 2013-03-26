Simple Javascript implementation of the k-means algorithm, for node.js and the browser
===============================================================================

##Installation

    npm install kmeans

##Example (JS)

    var data = [[1, 2, 3], ... , [69, 10, 25]];

    var km = new kMeans({
        K: 8
    });

    km.cluster(data);
    while (km.step()) {
        km.findClosestCentroids();
        km.moveCentroids();

        console.log(km.centroids, km.clusters);

        if(km.hasConverged) break;
    }

    console.log('Finished in:', km.currentIteration, ' iterations');
    console.log(km.centroids, km.clusters);
