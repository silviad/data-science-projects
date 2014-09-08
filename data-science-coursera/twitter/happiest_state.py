import sys
import json

def create_dict(afinnfile):
	scores = {} # initialize an empty dictionary
	for line in afinnfile:
		term, score  = line.split("\t")  # The file is tab-delimited. "\t" means "tab character"
		scores[term] = int(score)  # Convert the score to an integer        
	return scores

def calculate_sentiment(tweet,sent_dict):
	sum_sentiment = 0 
	if 'text' in tweet.keys() and 'lang' in tweet.keys() and tweet['lang'] == 'en':
		tweet_text = tweet['text'].encode('utf-8')            
		words = tweet_text.split(" ")
		for j in range(len(words)):
			if words[j] in sent_dict.keys():
				sum_sentiment = sum_sentiment + sent_dict[words[j]]
	return str(sum_sentiment)  

def create_dict_state(tweet_content,sent_dict):
	state_dictionary = {}
	for i in range(len(tweet_content)):
	    tweet =  tweet_content[i]
	    sentiment = calculate_sentiment(tweet,sent_dict)
	    if 'text' in tweet.keys() and 'lang' in tweet.keys() and tweet['lang'] == 'en' and 'place' in tweet.keys():
		place = tweet['place']
		if type(place) is dict:
			country_code = place['country_code'].encode('utf-8')
			if country_code == 'US' or country_code == 'USA':
				location = place['full_name'].split(",")			
				state = location[len(location)-1].strip().encode('utf-8')
				if state <> 'USA':
					if state in state_dictionary.keys():
						state_dictionary[state] += int(sentiment)
					else:
						state_dictionary[state] = int(sentiment)

				
	return state_dictionary 


def print_happiest_state(state_dictionary):
	i = 0	
	state_max = ""
	max_sentiment = 0    
	
	for state in state_dictionary.keys():		     
	    if i == 0:
	        state_max = state
		max_sentiment = state_dictionary[state]
		i = 1
	    else:
		if state_dictionary[state] > max_sentiment: 
		     state_max = state    
		     max_sentiment = state_dictionary[state] 	
	
	return state_max
	
def main():
	sent_file = open(sys.argv[1])
	tweet_file = open(sys.argv[2])        
	sent_dict = create_dict(sent_file)        
	tweet_content = []   
	for line in tweet_file:    
		tweet_content.append(json.loads(line))  
    
	state_dictionary = create_dict_state(tweet_content,sent_dict)	

	print print_happiest_state(state_dictionary)
	
	
if __name__ == '__main__':
	main()