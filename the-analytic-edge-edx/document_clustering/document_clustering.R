##########################################################
# DOCUMENT CLUSTERING
##########################################################
# Document clustering, or text clustering, is a very popular application of 
# clustering algorithms. A web search engine, like Google, often returns 
# thousands of results for a simple query. This makes it very difficult to 
# browse or find relevant information, especially if the search term has 
# multiple meanings. 

# Clustering methods can be used to automatically group search results 
# into categories, making it easier to find relavent results. 
# The two most common algorithms used for document clustering are Hierarchical 
# and k-means. 

# In this problem, we'll be clustering articles published on Daily 
# Kos (https://www.dailykos.com/), an American political blog that
# publishes news and opinion articles. 

####################################################
# hierarchical clustering
####################################################

# read data
dailykos <- read.csv("dailykos.csv", header = TRUE, sep = ",")

# calculate distance
distance <- dist(dailykos[, 2:ncol(dailykos)])

# create cluster model
dailykos.cluster <- hclust(distance, method = "ward")

# plot dendrogram
plot(dailykos.cluster)

# split in clusters
dailykos.cluster.group <- cutree(dailykos.cluster, k = 7)

# The choices 2 and 3 are good cluster choices according to the dendrogram, 
# because there is a lot of space between the horizontal lines in the 
# dendrogram in those cut off spots 
# Thinking about the application, it is probably better to show the reader 
# more categories than 2 or 3. These categories would probably be too broad 
# to be useful. Seven or eight categories seems more reasonable.

# create 7 datasets with the observations from the clusters
# for 1 subset: subset(dailykos, dailykos.cluster.group == 1)
list.subset <- split(dailykos, dailykos.cluster.group)
for (i in 1:7) {
    print(nrow(list.subset[[i]]))
}
# cluster 1: 1266 observations
# cluster 2: 321 observations
# cluster 3: 374 observations
# cluster 4: 139 observations
# cluster 5: 407 observations
# cluster 6: 714 observations
# cluster 7: 209 observations

# alternatively
table(dailykos.cluster.group)

# print the top 6 words in each cluster
for (i in 1:7) { 
  print(tail(sort(colMeans(list.subset[[i]][-1]))))
}
# --> cluster iraq war = cluster 5, cluster democratic = cluster 7

####################################################
# k-means clustering
####################################################

# create cluster model
set.seed(1000)
dailykos.kmeans <- kmeans(dailykos[, 2:ncol(dailykos)], centers = 7)

# create 7 datasets with the observations from the clusters
list.subset.kmeans <- split(dailykos, dailykos.kmeans$cluster)
for (i in 1:7) {
  print(nrow(list.subset.kmeans[[i]]))
}

# cluster 1: 146 observations
# cluster 2: 144 observations
# cluster 3: 277 observations
# cluster 4: 2063 observations
# cluster 5: 163 observations
# cluster 6: 329 observations
# cluster 7: 308 observations

# alternatively
table(dailykos.kmeans$cluster)

# print the top 6 words in each cluster
for (i in 1:7) { 
  print(tail(sort(colMeans(list.subset.kmeans[[i]][-1]))))
}
# --> iraq war cluster  = cluster 3, democratic cluster  = cluster 2

####################################################
# compare the two models
####################################################

# a Hierarchical Cluster corresponds to a K-Means Cluster 
# if it contains at least half of the points in K-Means Cluster 
table(hier.clust = dailykos.cluster.group, kmeans.clust = dailykos.kmeans$cluster)
# Hierarchical Cluster= 7 corresponds to K-Means Cluster=2 (democratic cluster)
# Hierarchical Cluster= 5 corresponds to K-Means Cluster=3 (iraq war cluster)









