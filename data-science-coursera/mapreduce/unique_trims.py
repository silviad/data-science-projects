import MapReduce
import sys

mr = MapReduce.MapReduce()

def mapper(record):
    # key: id seq
    # value: seq
    value = record[1]
    value = value[:-10]
    mr.emit_intermediate(value, 1)
    
def reducer(key, list_of_values):
    # key: seq
    # value: list of occurrence counts 
    mr.emit((key))

if __name__ == '__main__':
    inputdata = open(sys.argv[1])
    mr.execute(inputdata, mapper, reducer)   