# run after initial build
import os
fname = "main.bal"
OLD_NUMBER = -1
NEW_NUMBER = -1
NEW_FULL_1 = ""
NEW_FULL_2 = ""
NEW_FULL_3 = ""

OLD_FULL_1 = ""
OLD_FULL_2 = ""
OLD_FULL_3 = ""

with open(fname, "r") as f:
	lines = f.readlines()

def write_to_file(string):
	os.remove(fname)
	with open(fname, "w") as f:
		f.write(string)

def do_my_port(lines):
	global NEW_NUMBER
	global OLD_NUMBER
	global NEW_FULL_1
	global OLD_FULL_1
	new_full = ""
	for l in lines:
		newNum = -1
		TAG = "int myPort = 909"
		if TAG in l:
			s = l.split(";")[0]
			num = int(s[-1:])
			if num < 5:
				newNum = num + 1
				OLD_NUMBER = num
				NEW_NUMBER = newNum
				old_full = "int myPort = 909"+str(num)
				new_full = "int myPort = 909"+str(newNum)
				NEW_FULL_1 = new_full
				OLD_FULL_1 = old_full
				break

def do_listener(lines):
	global NEW_FULL_2
	global OLD_FULL_2
	for l in lines:
		if "listener http:Listener mylistener = " in l:
			s = l.split(")")[0]
			num = int(s[-1:])
			if num < 5:
				old_full = "listener http:Listener mylistener = new(909"+str(OLD_NUMBER)
				new_full = "listener http:Listener mylistener = new(909"+str(NEW_NUMBER)
				NEW_FULL_2 = new_full
				OLD_FULL_2 = old_full

def do_name(lines):
	global NEW_FULL_3
	global OLD_FULL_3
	for l in lines:
		if "name: \"notes" in l:
			s = l.split(",")[0]

			num = int(s[-2:len(s)-1])
			if num < 5:
				old_full = "name: \"notes"+str(OLD_NUMBER)
				new_full = "name: \"notes"+str(NEW_NUMBER)
				NEW_FULL_3 = new_full
				OLD_FULL_3 = old_full

def finalise():
	with open(fname, "r") as f:
		data = f.read()
	if NEW_NUMBER > 4:
		return
	data = data.replace(OLD_FULL_1, NEW_FULL_1)
	data = data.replace(OLD_FULL_2, NEW_FULL_2)
	data = data.replace(OLD_FULL_3, NEW_FULL_3)
	with open(fname, "w") as f:
		f.write(data)

do_my_port(lines)
do_listener(lines)
do_name(lines)
finalise()