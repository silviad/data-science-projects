# Simulation 


## Problem Description 

The exponential distribution can be simulated in R with rexp(n, lambda) where lambda is the rate parameter. The mean of exponential distribution is 1/lambda and the standard deviation is also 1/lambda. 

Illustrate via simulation (a thousand or so simulated averages of 40 exponentials) the properties of the distribution of the mean of 40 exponential(0.2)s:  
1. Show where the distribution is centred at and compare it to the theoretical centre of the distribution.  
2. Show how variable it is and compare it to the theoretical variance of the distribution.  
3. Show that the distribution is approximately normal.  
4. Evaluate the coverage of the confidence interval for 1/lambda.  

Set lambda = 0.2 for all of the simulations. 


## Solution 

1. The simulation is obtained by taking 1000 simulated averages of 40 exponentials. Lambda is set to 0.2. 

    
    ```r
    set.seed(124536)
    lambda <- 0.2
    teor.mean <- 1/lambda
    teor.sd <- 1/lambda
    teor.var <- (1/lambda)^2
    nsim <- 1000
    n <- 40
    means <- vector()
    stands <- vector()
    for (i in 1:nsim) {
        sample <- rexp(n, lambda)
        means[i] <- mean(sample)
        stands[i] <- sd(sample)
    }
    hist(means, main = "Means distribution of exponential function")
    sim.mean <- mean(means)
    sim.sd <- sd(means)
    sim.var <- var(means)
    abline(v = sim.mean, col = "purple", lwd = 2)
    ```
    
    ![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-1.png) 


    From the above histogram, it is possible to see that the means distribution is centred at 4.9791 (purple line in the plot), a value very close to the theoretical centre 1/lambda = 5. The difference between the two means is 0.0209.


2. The standard deviation and the variance of the means distribution are 0.8113 and 0.6583 respectively while the theoretical values are 5 and 25. Therefore, it is possible to conclude that the theoretical variance of the distribution is bigger than the variance of the means distribution.


3. The Central Limit Theorem says that the distribution of averages of iid (independent and identically distributed) variables becomes a standard normal distribution as the sample size increases. Therefore, it is possible to conclude that the previous distribution is approximately normal. 


4. The coverage of the confidence interval for the theoretical centre of the distribution, 1/lambda = 5, is
  
    
    ```r
    ll <- means - 1.96 * stands/sqrt(n)
    ul <- means + 1.96 * stands/sqrt(n)
    coverage <- sum(ll < teor.mean & ul > teor.mean)/nsim
    ```


 0.907.








