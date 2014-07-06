# The following pair of functions caches the inverse of a matrix,
# if it has already been calculated, otherwise it computes the inverse.

# This function creates a special "matrix" object that can cache its inverse
makeCacheMatrix <- function(x = matrix()) {
        inv <- NULL
        set <- function(y) {
                x <<- y
                inv <<- NULL
        }
        get <- function() x
        setinverse <- function(inverse) inv <<- inverse
        getinverse<- function() inv
        list(set = set, get = get,
             setinverse = setinverse,
             getinverse= getinverse)
}

# This function computes the inverse of the special "matrix" returned
# by makeCacheMatrix. If the inverse has already been calculated, 
# then the cachesolve should retrieve the inverse from the cache
cacheSolve <- function(x, ...) {        
        inv <- x$getinverse()
        if(!is.null(inv)) {
                message("getting cached data")
                return(inv)
        }
        data <- x$get()        
        inv <- solve(data, ...)  # Return a matrix that is the inverse of 'x'
        x$setinverse(inv)
        inv
}
