#! /usr/bin/python

import os
import getopt
import sys

def returnFrame(e):
    return e['frame']

def returnValue(e):
    return e['value']

# Take in a file from the arguments. Parse the file, extract minima or maxima, and export as a text file to the location given by arguments.
def findInflections(inputFile, outputFile, minimize=True):
    fin = inputFile
    fout = outputFile
    fmin = minimize
    inflectList = []
    compareList = [{'frame': 0, 'value': -1}, {'frame': 0, 'value': -1}, {'frame': 0, 'value': -1}]
    thisFrame = 0
    thisValue = 0
    exportList = []

    try:
        # print (fin)
        f = open(fin)
        f.close()
    except:
        print("Cannot open input file: " + fin)
        return

    try:
        if fmin:
            pass
    except:
        print("Parameter 'minimize' must be a boolean! Use either 'True' or 'False'")

    with open(fin) as f:
        if minimize:
            for line in f:
                if line[0] == "@":
                    continue
                line = line.strip().split()
                thisFrame = int(float(line[0].strip()))
                thisValue = float(line[1].strip())
                frameDict = dict(frame = thisFrame, value = thisValue)
                compareList.append(frameDict)
                compareList.pop(0)
                if returnValue(compareList[1]) < returnValue(compareList[0]) and returnValue(compareList[1]) < returnValue(compareList[2]):
                    inflectList.append(compareList[1])
            inflectList.sort(key=returnValue)
            exportList = [inflectList[0], inflectList[1], inflectList[2]]
        else:
            for line in f:
                for line in f:
                    if line[0] == "@":
                        continue
                    line = line.strip()
                    line = line.split()
                    thisFrame = line[0].strip()
                    thisFrame = int(float(thisFrame))
                    thisValue = line[1].strip()
                    thisValue = float(thisValue)
                    frameDict = dict(frame = thisFrame, value = thisValue)
                    compareList.append(frameDict)
                    compareList.pop(0)
                    if returnValue(compareList[1]) < returnValue(compareList[0]) and returnValue(compareList[1]) < returnValue(compareList[2]):
                        inflectList.append(compareList[1])
            inflectList.sort(key=returnValue, reverse=True)
            exportList = [inflectList[0], inflectList[1], inflectList[2]]

    with open(fout, "a+") as o:
        for i in range(len(exportList)):
            o.write(str(returnFrame(exportList[i])) + "  " + str(returnValue(exportList[i])) + "\n")

def main(argv):
    f1 = ""
    f2 = ""
    mix = True

    opts, args = getopt.getopt(argv, "hi:o:m:", ["input=","output=","minimize="])
    for opt, arg in opts:
        if opt == "-h":
            print ("Usage: ./RMSDAnalysis -i <input file, as .agr> -o <output file, as .txt> -m <find minima (True) or maxima (False)>")
            sys.exit()
        elif opt in ("-i", "--input"):
            f1 = arg
        elif opt in ("-o", "--output"):
            f2 = arg
        elif opt in ("-m", "--minimize"):
            mix = arg
    findInflections(f1, f2, mix)    

if __name__ == "__main__":
    main(sys.argv[1:])
