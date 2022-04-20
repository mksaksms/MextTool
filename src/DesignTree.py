#MeXT-SE software source code
#author: Md Jubaer Hossain Pantho
#University of Florida

from tkinter import *
from tkinter.ttk import *
import xml.dom.minidom
import IPparse
from PIL import ImageTk, Image


class DesignTree():
    def __init__(self, master):
    
        self.tree = Treeview(master, height=30)


    def deletePrevousEntry(self):
        nodes = self.tree.get_children()

        for item in nodes:
            self.tree.delete(item)


    def generateTree(self, filePath):
        self.deletePrevousEntry()

        Style().configure("Treeview", background="#B3B3D0", font=(None, 12), foreground="black", fieldbackground="#B3B3D0")

        self.tree["columns"]=("one","two")
        self.tree.column("#0", width=280, minwidth=240, stretch=NO)
        self.tree.column("one", width=120, minwidth=100, stretch=NO)
        self.tree.column("two", width=160, minwidth=120)

        self.tree.heading("#0",text="Design Tree",anchor=W)
        self.tree.heading("one", text="--",anchor=W)
        self.tree.heading("two", text="info",anchor=W)

        greenImage = Image.open("../images/greenButton.png")
        greenImage = greenImage.resize((12, 12), Image.ANTIALIAS)
        self.greenPhoto = ImageTk.PhotoImage(greenImage)

        infoImage = Image.open("../images/info.png")
        infoImage = infoImage.resize((14, 14), Image.ANTIALIAS)
        self.infoPhoto = ImageTk.PhotoImage(infoImage)

        paramImage = Image.open("../images/param.png")
        paramImage = paramImage.resize((10, 10), Image.ANTIALIAS)
        self.paramPhoto = ImageTk.PhotoImage(paramImage)

        systemData, cpuConfList, memConfList, comConfData = IPparse.parseFile(filePath)

        # Level 1
        self.treeInfo= []
        vendorInfo = self.tree.insert("", 1, text=str(systemData[0][0]), image = self.infoPhoto, values=("","vendor Info"))
        boardInfo = self.tree.insert("", 2, text=str(systemData[1][0]), image = self.infoPhoto, values=("","board Info"))

        self.treeInfo.append(vendorInfo)
        self.treeInfo.append(boardInfo)


        for i in range(2, len(systemData)):
            moduleBuffer = self.tree.insert("",i, text=str(systemData[i][0]), image = self.greenPhoto, values=("",""))
            self.treeInfo.append(moduleBuffer)


        # Level 2


        for i in range(2, len(systemData)):

            #Adding CPU configuration information
            if "CPU" in str(systemData[i][0]) and cpuConfList:
                cpuConfig = self.tree.insert(self.treeInfo[i], "end", text="cpuconfig", values=("","customize"))

                for j in range(len(cpuConfList)):
                    self.tree.insert(cpuConfig, "end", text=cpuConfList[j], image = self.paramPhoto, values=("",""))
            #Adding Memory Configuration information
            elif "memory" in str(systemData[i][0]) and memConfList:
                memConfig = self.tree.insert(self.treeInfo[i], "end", text="memconfig", values=("","customize"))
                for j in range(len(memConfList)):
                    self.tree.insert(memConfig, "end", text=memConfList[j], image = self.paramPhoto, values=("",""))


            for k in range(1, len(systemData[i])):
                self.tree.insert(self.treeInfo[i], "end", text=systemData[i][k], image = self.paramPhoto, values=("",""))


        #Adding Communication configuration
        if comConfData:
            moduleBuffer = self.tree.insert("","end", text=comConfData, image = self.greenPhoto, values=("","BUS"))
            self.treeInfo.append(moduleBuffer)
        self.tree.grid(column = 0, row = 3, padx=(8, 8), pady=(2,2))
