## Introduction

The goal of the project is to create a product to highlight the prediction 
algorithm built for the Capstone project of Coursera Specialization in Data Science. 

The main directory of this repo contains the code for the exploratory analysis.
The sub-directory project contains the code of the project:  

- the procedure of preprocessing text
- the code for the Shiny application in the sub-directories shiny_app_multi, shiny_app_twitter, shiny_app_blogs e shiny_app_news.

### Operating instructions

For every context (twitter, blog and news) execute the following steps:

1. execute preproc.corpus function from preprocessing.R package
2. execute sql instructions from the file after_load, profanity and contractions
3. add manually keys and unique constraints to the main tables
4. execute preproc.refine function from preprocessing.R package
5. copy the file RDS in the shiny_app_x directory
