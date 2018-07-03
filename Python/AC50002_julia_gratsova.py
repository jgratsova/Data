#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Dec 2 11:56:55 2017

@author: Julia Gratsova

"""
import itertools as itr

# variables

values = {}
rankedWords = {}
preparedFile = []
filename = ''

def readValues():
    # creates a dictionary of letter rankings from the file
    with open('values.txt') as f:
        for line in f:
            val = line.split(" ")
            key = val[0]
            value = val[1]
            values[key]=value
            # print(key, ' : ', value)


def getValue(letter):
    #gives a score to a letter
    return values[letter]


def cleanFile(filename):
    f = filename + '.txt'
    with open(f) as file:
        names = file.readlines()  # reads all the lines of a file in a list
        for char in names:
            char = char.upper()  # converts all lowercase characters to uppercase
            char = char.replace("-", " ")  # removes hyphen and replaces with space, separating two words
            char = char.replace("\'", "")  # ignores the apostrophes (')
            char = char.replace("+", "")  # ignores the apostrophes (')
            preparedFile.append(char.rstrip())  # remove trailing space


def letterRank(wordLength, letter, index):
     # defines letter rank logic
    rank = 0
    # if first letter
    if index == 0:
        rank = 0
    # if last
    elif index+1 == wordLength:
        rank = 2
        # if last and E
        if letter == "E":
            rank = 15
    # not first or last
    else: rank = index + int(values[letter])
    return rank


def rankWords():
    # creates new dictionary with original line and ranks every letter according to the rank
    #logic defined above
    for string in preparedFile:
        rankList = []
        words = string.split(' ')
        for word in words:
            for index, letter in enumerate(word):
                # print(len(word), ' ', letter, ' ', index)
                rank = letterRank(len(word),letter,index)
                rankList.append(int(rank))
        #print(string, ' :: ', rankList)
        rankedWords[string] = rankList


def createAbbr(dict):
    # for each letter in abbreviation gets score for the letter from rankedWords
    # if score for letter is used removes it from ranked letters list
    # adds abbreviation and scores to a nested dictionary
    # CRAB TREE: 
        # CAB : 29
        # CRA : 15
    abbr_dict = {}
    seen = set()
    # copies strings from original dictionary
    ranked_copy = rankedWords
    
    # for each string in list:
    for key in dict:
        temp = {}
        abbrs = []
        unique = {}
        best = []
        scored = {}
        score_table = {}
        # combines words in string
        joined_key = key.replace(" ", "")
        # creates all abbreviations keeping letter indices
        indices = itr.combinations(enumerate(joined_key), 3)
        # calculates score for each abbreviation 
        for i in indices:
            letter1 = int(ranked_copy[key][i[0][0]])
            letter2 = int(ranked_copy[key][i[1][0]])
            letter3 = int(ranked_copy[key][i[2][0]])
            score = letter1 + letter2 + letter3
            indexed_abbr = i[0][1] + i[1][1] + i[2][1]
            #print(indexed_abbr)
            temp[indexed_abbr]=[score]
            #print(score)
            #print(i[1][0], i[1][1])
        scored[key] = temp
         # removes duplicate abbreviations 
        for k, v in scored.items():
            for sk, sv in v.items():
                #print(sk,sv)
                if sk not in seen:
                    seen.add(sk)
                    unique[sk]=sv
        sortedDict = [(k, unique[k]) for k in sorted(unique, key=unique.get)]
        tempMinimum = int(99)
        for k, v in sortedDict:
            if int(v[0]) < int(tempMinimum):
                tempMinimum = v[0]
        #print(key)
        for k, v in sortedDict:
            if int(v[0]) == int(tempMinimum):
                best.append(k)
                #print(k,v)   
        abbr_dict[key] = best
    return abbr_dict

    
def printFile(dictionary, filename, names):
    # prints original name + abbreviations to a .txt file
    f = filename + '_abrevs.txt'
    of = filename + '.txt'
    with open(of) as of:
        names = of.readlines()
        
    with open(f, 'w') as file:
        # replaces keys with original names 
        index = 0
        for key, value in dictionary.items():
            string = names[index]
            file.write(string)
            string = ' '.join(value) + '\n'
            file.write(string)
            index = index + 1


def printMenu():
    # prints a menu
    main_menu_text = """ 
    1. Create abbreviations
    2. Run tests
    3. Exit
    """
    print(main_menu_text)


def test():
    # tests for letter ranking logic
    print("Testing letter rank logic:")
    print("should be 0: ", letterRank(5, "A", 0))
    print("should be 0: ", letterRank(8, "Z", 0))
    print("should be 2: ", letterRank(5, "A", 4))
    print("should be 2: ", letterRank(5, "Z", 4))
    print("should be 15: ", letterRank(7, "E", 6))
    print("should be 21: ", letterRank(5, "A", 1))
    print("should be 26: ", letterRank(5, "E", 1))

       
def userInterface():
    # user interface  and menu operation
    logo = """
       __    ___  ___   ___    ___    ___  ___  
      /__\  / __)| __) / _ \  / _ \  / _ \(__ \ 
     /(__)\( (__ |__ \( (_) )( (_) )( (_) )/ _/ 
    (__)(__)\___)(___/ \___/  \___/  \___/(____)
        """
    
    description = """ 
    Python script to create abbreviations from the words in text file. 
    Script will read the input file, create all possible abbreviations
    from each line, rank them according to given letter values,
    remove duplicates and output original line plus best scored 
    abbreviations to the text file.
    """
    print(logo)
    print(description)
    menu = True
    while menu:          
        printMenu()
        option = input("Select menu 1-3: ")
        if option == "1":     
            filename = input("Please enter the filename: ")
            original_names = cleanFile(filename)
            rankWords()
            abbreviated = createAbbr(rankedWords)
            printFile(abbreviated, filename,original_names)
            file = filename + '_abrevs.txt'
            print("generated the file", file)
        elif option == "2":
            print("Running tests")
            test()
        elif option == "3":
            print("Exiting")
            menu = False
            return
        else:
            # any input other than values 1-3 are wrong
            input("Wrong input, press any key for menu")


def main():
    # reads character values from file
    readValues()
    # calls user interface
    userInterface()

 
if __name__ == '__main__':
    main()
    # main method
        
    
    
