import MapReduce
import sys

mr = MapReduce.MapReduce()

def mapper(record):
    # key: document identifier
    # value: document contents
    key = record[0]
    value = record[1]
    words = value.split()
    word_set = set()
    for w in words:
        if w not in word_set:
            mr.emit_intermediate(w, key)
            word_set.add(w)  
    
    
def reducer(key, list_of_values):
    # key: word
    # value: list of document identifier
    mr.emit((key, list_of_values))

   
if __name__ == '__main__':
    inputdata = open(sys.argv[1])
    mr.execute(inputdata, mapper, reducer)