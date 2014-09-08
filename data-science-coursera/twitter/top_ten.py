import sys
import json

def main():
    tweet_file = open(sys.argv[1])

    tweet_content = []   
    for line in tweet_file:    
	tweet_content.append(json.loads(line))
	   
    hashtag_dictionary = {}
    for i in range(len(tweet_content)):
	tweet =  tweet_content[i]	    
	if 'text' in tweet.keys() and 'lang' in tweet.keys() and tweet['lang'] == 'en':
	    hashtags = tweet['entities']['hashtags']            
	    for j in range(len(hashtags)):
		hashtag = hashtags[j]['text'].encode('utf-8')
		if hashtag in hashtag_dictionary.keys():
		    hashtag_dictionary[hashtag] += 1
                else:
	            hashtag_dictionary[hashtag] = 1
		    
    i = 0		    
    for hashtag in hashtag_dictionary.keys():	
	i += 1 
	print hashtag, " ",  hashtag_dictionary[hashtag]
	if i == 10:
	    break
		    
if __name__ == '__main__':
    main()
