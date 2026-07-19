#!/usr/bin/python3

import os
import os.path
import sys
from operator import itemgetter


def listSequences(path="."):
    if path == ".":
        path = os.getcwd()

    if not os.path.isdir(path):
        print("Given Path is not a directory !")
        return

    allFiles = os.listdir(path)

    imglen2 = []
    imglen3 = []
    imglen4 = []
    spcFile = []
    unicFile = []
    seqList = []

    nbFiles = 0
    for file in allFiles:
        splited = file.split(".")
        imglen = len(splited)
        imgName = splited[0]
        checkType = "None"

        if imglen == 2:
            ext = splited[1]
            uiFle.append(file)
            # print '2 '+file
            nbFiles += 1

        if imglen == 3:
            try:
                checkType = int(splited[1])
            except:
                spcFile.append(file)

            if checkType != "None":
                padding = splited[1]
                ext = splited[2]
                imgStructure = imgAnalyser(imgName, padding, ext)
                seqList = seqAnalyser(imgStructure, seqList)
                # print '3 '+str(imgStructure
                nbFiles += 1

        if imglen == 4:
            try:
                checkType = int(splited[2])

            except:
                spcFile.append(file)

            if checkType != "None":
                aovName = splited[1]
                padding = splited[2]
                ext = splited[3]
                imgStructure = imgAnalyser(imgName, padding, ext, aovName)
                seqList = seqAnalyser(imgStructure, seqList)
                nbFiles = nbFiles + 1
                # print '4 '+str(imgStructure)

        if imglen == 1 or imglen > 4:
            if os.path.isfile(file):
                spcFile.append(file)

    print(
        "----------------------------------------------------------------------------------------------------"
    )
    # seqList.sort()
    sorted_list = sorted(seqList, key=itemgetter("imgName"))

    for result in sorted_list:
        # if result.has_key('missing') :
        if "missing" in result:
            if len(result["missing"]) == 0:
                print(
                    result["imgName"],
                    result["aovName"],
                    " " * result["lenName"],
                    result["paddingMinStr"],
                    "    ",
                    result["paddingMaxStr"],
                    "    ",
                    result["extension"],
                )
            else:
                print(
                    result["imgName"],
                    result["aovName"],
                    " " * result["lenName"],
                    result["paddingMinStr"],
                    "    ",
                    result["paddingMaxStr"],
                    "    ",
                    result["extension"],
                    "    Missing Frames: ",
                    result["missing"],
                )
    print()
    print()
    print("Total >> " + str(nbFiles) + "  files.")
    print(
        "----------------------------------------------------------------------------------------------------"
    )
    # print spcFile


def seqAnalyser(imgStructure, seqList):
    imgStructure["paddingMin"] = imgStructure["paddingVal"]
    imgStructure["paddingMax"] = imgStructure["paddingVal"]
    imgStructure["paddingMinStr"] = imgStructure["paddingString"]
    imgStructure["paddingMaxStr"] = imgStructure["paddingString"]
    imgStructure["frames"] = [
        imgStructure["paddingVal"],
    ]

    if len(seqList) == 0:
        seqList.append(imgStructure)
    else:
        checkName = 0
        listToCheck = []

        for seq in seqList:
            # check si une sequence existe avec ce nom et cet aov
            if (
                seq["imgName"] == imgStructure["imgName"]
                and seq["aovName"] == imgStructure["aovName"]
                and seq["extension"] == imgStructure["extension"]
                and seq["paddingNbr"] == imgStructure["paddingNbr"]
            ):
                checkName += 1
                listToCheck.append(seq)

            fullLen = 60
            curLen = len(seq["imgName"])
            newLen = fullLen - curLen

            seq["lenName"] = newLen

        # si aucune squence ne porte ce nom
        if checkName == 0:
            seqList.append(imgStructure)
        # sinon on affime la recherche
        else:
            for seq in listToCheck:
                # print str(imgStructure)
                if seq["paddingMin"] > imgStructure["paddingVal"]:
                    seq["paddingMin"] = imgStructure["paddingVal"]
                    seq["paddingMinStr"] = imgStructure["paddingString"]

                if seq["paddingMax"] < imgStructure["paddingVal"]:
                    seq["paddingMax"] = imgStructure["paddingVal"]
                    seq["paddingMaxStr"] = imgStructure["paddingString"]

                listFrames = seq["frames"]
                listFrames.append(imgStructure["paddingVal"])
                seq["frames"] = sorted(listFrames)

                missingF = missingFrames(
                    seq["paddingMin"], seq["paddingMax"], seq["frames"]
                )
                seq["missing"] = missingF

    return seqList


def missingFrames(firstF, lastF, listF):
    missingF = []
    i = firstF

    while i < lastF:
        if i not in listF:
            missingF.append(i)
        i += 1

    return missingF


def imgAnalyser(curImgName, curPadding, curExt, curAovName=""):
    imgStructure = {}
    imgStructure["imgName"] = curImgName
    imgStructure["aovName"] = curAovName
    imgStructure["paddingString"] = curPadding
    imgStructure["paddingNbr"] = len(curPadding)
    imgStructure["paddingVal"] = int(curPadding)
    imgStructure["extension"] = curExt

    return imgStructure


if __name__ == "__main__":
    try:
        opt = sys.argv[1]
    except:
        opt = None

    if opt:
        listSequences(opt)
    else:
        listSequences()
