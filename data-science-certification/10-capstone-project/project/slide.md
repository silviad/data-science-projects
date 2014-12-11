Predictive Shiny App
========================================================


Introduction
========================================================

Mobile devices like smartphones and tablets are already part of daily life of many people but typing on mobile keyboards can be sometimes frustrating. 

A predictive text model like SwiftKey has been developed and integrate it on a Shiny App available online. The key idea applied is a best practice of user-experience design: **"context matters"**. The application adapts not only to the user as the current smart devices usually do but also to the context. The Shiny App will give the user the possibility to switch between different contexts in order to make the algorithm adapt better to different typing style of the user and eventually offer a better typing experience. The contexts in this case are **Twitter, Blog and News**.


Predictive Model 
========================================================
An exploratory analysis conducted on the different contexts data has detected linguistic and stylistics differences between them as expected.

Therefore, a **composite predictive model** has been implemented including a model for each different context. The three models have been developed following the same steps: preparation of a huge data set reaching a trade-off with memory limits and implementation of a **backoff algorithm**.

The algorithm is a linear combination of the two most predictive n-grams (fourgrams and trigrams, trigrams and bigrams or bigrams and unigrams). It consists in a **hybrid approach** that combines the n-grams model for words and the model for word classes (**POS tagging**).


User Guide - Instructions 
========================================================
When the application is started, it appears a page with **three links**, one for each different context: Twitter, Blogs and News. Clicking on a link, a new application is started for the specific context.

In this second application, it is possible to write in a **text area**. The text area is resizable clicking on the bottom left corner of the area itself. During the typing, **three buttons** appear above the text area.

The buttons show the **three most likely words** predicted: if there is a space after the last word typed, the algorithm predicts the next word, otherwise implements sentence completion with prediction. If a button is pressed, the word displayed on is pasted into the text area to complete the sentence.


Future improvements
========================================================
This is a pilot project and some features have been not implemented due to the limited amount of time, resources and knowledge.

In order to obtain better performance with the prediction, other features will have been added:

1. Implementation of bags of word: an automatic mechanism to find similar words and sentences
2. Extension of POS tagging
3. More target pruning to gain space and memory necessary to implement the previous features.
4. Layout improvements

