import MapReduce
import sys

mr = MapReduce.MapReduce()

def mapper(record):
    # key: id seq
    # value: seq
    matrix_name = record[0]
    i = record[1]
    j = record[2]
    value = record[3]
    if matrix_name == "a":
        for k in range(0,5):
            key = (i, k)
            mr.emit_intermediate(key, record)
    else:
        for k in range(0,5):
            key = (k, j)
            mr.emit_intermediate(key, record)        
    
def reducer(key, list_of_values):
    # key: seq
    # value: list of occurrence counts 
    value = 0
    for val1 in list_of_values:
        matrix_name1 = val1[0]       
        i1 = val1[1]
        j1 = val1[2]
        value1 = val1[3]        
        if matrix_name1 == "a": 
            for val2 in list_of_values:
                matrix_name2 = val2[0]
                i2 = val2[1]
                j2 = val2[2]
                value2 = val2[3]                 
                if matrix_name2 == "b" and j1 == i2:
                    value += value1*value2
                
    print key, list_of_values

    value_output = (key[0], key[1], value)
    print value_output
    mr.emit((value_output))

if __name__ == '__main__':
    inputdata = open(sys.argv[1])
    mr.execute(inputdata, mapper, reducer)    