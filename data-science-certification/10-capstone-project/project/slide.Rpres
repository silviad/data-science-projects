Predictive Shiny App
========================================================


Introduction
========================================================

Mobile devices like smartphones and tablets are already part of daily life but typing on their keyboards can be sometimes frustrating. 

A predictive text model like SwiftKey has been developed and integrate on a Shiny App available online. The key idea applied here is that **"context matters"**. The application adapts not only to the user, as the current smart devices usually do, but also to the context. The Shiny App will give the user the possibility to switch between different contexts so the algorithm adapt better to the different typing styles and offer a better typing experience. 

The contexts analyzed are **Twitter, Blog and News**.


Predictive Model 
========================================================
An exploratory analysis conducted on the different contexts data has detected linguistic and stylistics differences as expected.

Therefore, a **composite predictive model** has been implemented. For each different context, a model has been developed following the same steps: preparation of a huge data set of **n-grams** reaching a trade-off with memory limits and implementation of a **backoff algorithm**.

The algorithm is a linear combination of the two most predictive n-grams (fourgrams and trigrams, trigrams and bigrams or bigrams and unigrams). An **hybrid approach** has been applied combining the n-grams model and the part of speech model (**POS tagging**).


User Guide - Instructions 
========================================================
When the application starts, a page appears with **three links**, one for each different context: Twitter, Blogs and News. Clicking on a link, a new application starts for the specific context.

In this second application, it is possible to write in a **text area**. 

**Three buttons** appear above the text area. The buttons show the **three most likely words** predicted: if there is a space after the last word typed, the algorithm predicts the next word, otherwise implements sentence completion with prediction. If a button is pressed, the word displayed on is pasted into the text area to complete the sentence.

On the left, a summary displays the top 20 words predicted by the algorithm ordered by descending frequency.


Future improvements
========================================================
This is a pilot project and some features have not been implemented due to the limited amount of time, resources.

Other features will have be added to obtain better prediction performance and a better user experience in general:

- Implementation of bags of word: an automatic mechanism to find similar words and sentences.
- Extension of POS tagging and implementation of named entity recognition.
- Integration of emoticons.
- More target pruning to gain space and memory necessary to implement the previous features.
- Layout improvements. 


