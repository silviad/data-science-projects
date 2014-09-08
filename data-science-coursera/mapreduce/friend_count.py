import MapReduce
import sys

mr = MapReduce.MapReduce()

def mapper(record):
    # key: person A
    # value: person A friend    
    mr.emit_intermediate(record[0],1)
    

def reducer(key, list_of_values):
    # key: person A
    # value: list of occurrence counts 
    total = 0 
    for val in list_of_values:
        total += val
    mr.emit((key, total))
    
    
if __name__ == '__main__':
    inputdata = open(sys.argv[1])
    mr.execute(inputdata, mapper, reducer)    