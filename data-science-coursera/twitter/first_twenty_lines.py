counter = 1

with open("output.txt", "r") as f:
    for line in f:
        print(line),       
        counter = counter + 1
        if counter > 20 :
            break;