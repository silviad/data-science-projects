import sys
import json

def lines(fp):
	print str(len(fp.readlines()))

def create_dict(afinnfile):
	scores = {} # initialize an empty dictionary
	for line in afinnfile:
		term, score  = line.split("\t")  # The file is tab-delimited. "\t" means "tab character"
		scores[term] = int(score)  # Convert the score to an integer        
	return scores

def main():
	sent_file = open(sys.argv[1])
	tweet_file = open(sys.argv[2])        
	sent_dict = create_dict(sent_file)
	
	tweet_content = []   
	for line in tweet_file:    
		tweet_content.append(json.loads(line))
	
	for i in range(len(tweet_content)):
		sum_sentiment = 0 
		tweet =  tweet_content[i]
		if 'text' in tweet.keys() and 'lang' in tweet.keys() and tweet['lang'] == 'en':
			tweet_text = tweet['text'].encode('utf-8')            
			words = tweet_text.split(" ")
			for j in range(len(words)):
				if words[j] in sent_dict.keys():
					sum_sentiment = sum_sentiment + sent_dict[words[j]]
		print str(sum_sentiment)   
	
if __name__ == '__main__':
	main()

