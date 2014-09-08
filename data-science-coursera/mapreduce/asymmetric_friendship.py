import MapReduce
import sys

mr = MapReduce.MapReduce()

def mapper(record):
    # key: person A
    # value: person A friend  
    if record[0] < record[1]:
        friends = record[0] + " " +  record[1]
    else:
        friends = record[1] + " " +  record[0]
    mr.emit_intermediate(friends, record[0])

def reducer(key, list_of_values):
    # key: person A + person B
    # value: friend     
    if len(list_of_values) == 1:
        friends = key.split()
        if friends[0] == list_of_values[0]:
            mr.emit((friends[1],friends[0]))
        else:
            mr.emit((friends[0],friends[1]))

    
if __name__ == '__main__':
    inputdata = open(sys.argv[1])
    mr.execute(inputdata, mapper, reducer)    