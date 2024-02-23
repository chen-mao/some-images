#!/usr/bin/python2
#coding=utf-8

import os
import sys
import ConfigParser

Dir = str(os.getcwd())
print(Dir)
#	Read .ini	- done
def read_ini(path,section,key):
	if not os.path.exists(path):
		print("No Path"+path)
		sys.exit()
	config = ConfigParser.ConfigParser()
	config.optionxform = lambda option: option
	config.read(path)
	value = config.get(section,key,0)	
	return value

iteration_number = int(read_ini(Dir+"/Setup_unigine.ini","Frequent","Times"))
print(iteration_number)

sys.path.append(Dir+"/Unigine_Heaven-4.0-Enterprise/automation")
os.chdir(Dir+"/Unigine_Heaven-4.0-Enterprise/automation")

import heaven_automation

resolutions = [\
		[1920,1080],\
]

for width,height in resolutions:
	for i in range(iteration_number):
		#print("running heaven in "+str(width)+"x"+str(height)+" Cycle "+str(i))
		heaven_automation.run(\
			api = 'GL',\
			fullscreen = 1,\
			aa = 0,\
			width = width,\
			height = height,\
			quality = 'low',\
			tessellation = 'disabled',\
			log = "heaven_"+str(width)+"x"+str(height)+'_low_log.csv',\
			log_caption = 'Score,min_FPS,max_FPS,average_FPS,API,Resolution,AA,Quality,Tessellation,Video,CPU',\
			log_format = '$S,$z,$x,$F,$A,$v,$m,$quality,$tessellation,$g,$c'\
			)
