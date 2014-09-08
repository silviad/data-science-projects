import sys
import json

def main():
    tweet_file = open(sys.argv[1])

    tweet_content = []   
    for line in tweet_file:    
	tweet_content.append(json.loads(line))
	
    total_occurrences = 0     
    words_dictionary = {}
    for i in range(len(tweet_content)):
	tweet =  tweet_content[i]	    
	if 'text' in tweet.keys() and 'lang' in tweet.keys() and tweet['lang'] == 'en':
	    tweet_text = tweet['text'].encode('utf-8')            
	    words = tweet_text.split(" ")
	    total_occurrences += len(words)
	    for j in range(len(words)):
		word = words[j].strip()
		if word in words_dictionary.keys():
		    words_dictionary[word] += 1
                else:
	            words_dictionary[word] = 1
		    
    for word in words_dictionary.keys():	
	frequency = round(1.0 * words_dictionary[word]/total_occurrences,4) 
	print word, " ", frequency
		    
if __name__ == '__main__':
    main()
