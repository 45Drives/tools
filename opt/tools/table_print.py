################################################################################
# table_print.py 
# desc:
# prints information to stdout based on rows, columns, and header content
################################################################################

# TODO: 
# find max length of c_txt lists and use that as the check during column content
# portion
# fix odd number column alignment

# escape sequences for supported color options
ANSI_colors={
	"LGREEN":'\033[1;32m',
	"GREEN":'\033[0;32m',
	"RED":'\033[0;31m',
	"GREY":'\033[1;30m',
	"END":'\033[0m'
}
# characters used to draw box around table content
class box:
	TL=(u'\u2554','+') # ╔
	TR=(u'\u2557','+') # ╗
	BL=(u'\u255a','+') # ╚
	BR=(u'\u255d','+') # ╝
	H= (u'\u2550','-') # ═
	V= (u'\u2551','|') # ║
	TT=(u'\u2566','+') # ╦
	LT=(u'\u2560','+') # ╠
	RT=(u'\u2563','+') # ╣
	BT=(u'\u2569','+') # ╩
	CT=(u'\u256C','+') # ╬

class table():
	def __init__(self,ansi=True,h_txt=['TABLE HEADER TXT','second line of the table header'],c_count=3,c_labels=["COLUMN 1","COLUMN 2","COLUMN 3"],c_txt=[[("00","GREEN"),("01","GREY")],[("10","RED"),("11","LGREEN")],[("20","RED"),("21","GREEN")]],padding=1): 
		self.box_idx=(0 if ansi else 1) #used to index into the box tuple
		self.h_txt=h_txt
		self.c_labels=c_labels
		self.c_txt=c_txt
		self.padding=padding
		self.c_count=c_count
		self.column_width=[]
		self.table_width=0
		self.table_lines=[]
		self.column_width_sum=0
		
		
	def table_print(self):
		#########################################################################################
		self.column_width=[]
		self.table_width=0
		self.table_lines=[]
		self.column_width_sum=0
		idx=self.box_idx
		
		# find the length of the longest string in each column (excluding headers)
		for rows in self.c_txt:
			self.column_width.append(len(max(rows, key=lambda t: len(t[0]))[0]))
		
		# compare the column label length to the longest string in each column
		# add padding to the highest value, these are then summed to form the 
		# table width.
		for i in range(0,len(self.c_labels)):
			label_len=len(self.c_labels[i])
			if label_len > self.column_width[i]:
				self.column_width[i]=label_len 
			self.column_width[i]+=(2*self.padding)
			self.table_width+=self.column_width[i]+1
			self.column_width_sum+=self.column_width[i]

		# adjust the table width in the case where the header text is longer
		# than the sum of all column widths 
		header_len=len(max(self.h_txt,key=len))+(2*self.padding) 
		if header_len > self.table_width:
			self.table_width=header_len
		
		################################################################################################
		
		# top of header
		self.table_lines.append(box.TL[idx]+(box.H[idx])*self.table_width+box.TR[idx])
		
		# header lines
		for header_txt in self.h_txt:
			self.table_lines.append(box.V[idx]+header_txt+(" "*(self.table_width-len(header_txt))+box.V[idx]))
		
		# bottom of header
		line=box.LT[idx]
		for i in range(self.c_count):
			line+=(box.H[idx])*(self.column_width[i]) #add in horizontal separators
			if i < self.c_count-1:
				line += box.TT[idx] #add in the column separator
		line+=(box.H[idx])*(self.table_width-self.column_width_sum-1)+box.RT[idx]
		self.table_lines.append(line)
		
		# column labels
		line=box.V[idx]
		for i in range(self.c_count):
			line+=(" "*self.padding)+self.c_labels[i]+(" "*(self.column_width[i]-len(self.c_labels[i])-1))
			if i < self.c_count-1:
				line += box.V[idx] #add in the column separator
		line+=(" ")*(self.table_width-self.column_width_sum-1)+box.V[idx]
		self.table_lines.append(line)
		
		# bottom of column label
		line=box.LT[idx]
		for i in range(self.c_count):
			line+=(box.H[idx])*(self.column_width[i]) #add in horizontal separators
			if i < self.c_count-1:
				line += box.CT[idx] #add in the column separator
		line+=(box.H[idx])*(self.table_width-self.column_width_sum-1)+box.RT[idx]
		self.table_lines.append(line)
		
		#column content
		for i in range(len(self.c_txt[0])):
			line=box.V[idx]
			for j in range(self.c_count):
				if i < len(self.c_txt[j]):
					if self.c_txt[j][i][1] in ANSI_colors.keys() and idx==0:
						line+=(" "*self.padding)+(ANSI_colors[self.c_txt[j][i][1]])+(self.c_txt[j][i][0])+(ANSI_colors["END"])+(" "*(self.column_width[j]-len(self.c_txt[j][i][0])-1))
					else:	
						line+=(" "*self.padding)+(self.c_txt[j][i][0])+(" "*(self.column_width[j]-len(self.c_txt[j][i][0])-1))
				else:
					line+=(" "*(self.column_width[j]))
				if j < self.c_count-1:
					line+=box.V[idx]
			line+=(" ")*(self.table_width-self.column_width_sum-1)+box.V[idx]
			self.table_lines.append(line)
		
		# bottom of table
		line=box.BL[idx]
		for i in range(self.c_count):
			line+=(box.H[idx])*(self.column_width[i]) #add in horizontal separators
			if i < self.c_count-1:
				line += box.BT[idx] #add in the column separator
		line+=(box.H[idx])*(self.table_width-self.column_width_sum-1)+box.BR[idx]
		self.table_lines.append(line)
		
		# final print
		for i in range(len(self.table_lines)):
			print(self.table_lines[i])

test = table()
test.table_print()

test.h_txt = ["HI","FREN"]
test.table_print()

test.h_txt = ["HI","THIS IS A TEST TO SEE IF WE CAN BREAK THE OUTPUT BASED ON HEADER"]
test.table_print()

test.c_txt[0][0] = ("smol","")
test.table_print()

test.h_txt = ["A","B","C","D"]
test.table_print()
test.c_labels=["A","BEE","cee"]
test.c_txt=[[("one","RED"),("two","RED")],[("three",""),("4","GREY")],[("|5|","LGREEN"),("s6ix","GREEN")]]
test.c_count=3
test.table_print()

test.c_labels=["BIGGER","BETTER","FASTER"]
test.table_print()
