import MapReduce
import sys

mr = MapReduce.MapReduce()

def mapper(record):
    # key: table name
    # value: table record 
    key = record[1] 
    mr.emit_intermediate(key, record)
    
    
def reducer(key, list_of_values):
    # key: table key
    # value: list of table name + table record    
    line_item = []
    order = []    
    for fields in list_of_values:       
        if fields[0] == "line_item":            
            line_item.append(fields)
        else:
            order.append(fields)            
    for v_line_item in line_item:
        for v_order in order:
            join = v_order + v_line_item    
            mr.emit(join)


if __name__ == '__main__':
    inputdata = open(sys.argv[1])
    mr.execute(inputdata, mapper, reducer)
