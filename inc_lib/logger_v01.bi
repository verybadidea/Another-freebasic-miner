type log_entry_type
	dim as string time_, text
	declare operator cast () as string
end type

operator log_entry_type.cast () as string
   return time_ & " " & text
end operator

type logger_type
	dim as string fileName
	dim as integer numEntries
	dim as log_entry_type entry(any)
	declare constructor(fileName as string, bufferSize as integer, entryClearEndTimer as double)
	declare destructor
	declare function add(text as string) as integer
	declare function pop() as log_entry_type
	'For clearing buffer on timer
	private:
	dim as double entryClearEndTimer, entryMinLifeTime
	public:
	declare sub restartClearTimer() 'start of restart
	declare sub updateClearTimer()
end type

constructor logger_type(fileName as string, bufferSize as integer, entryMinLifeTime as double)
	this.fileName = fileName
	numEntries = 0
	redim entry(bufferSize - 1)
	this.entryMinLifeTime = entryMinLifeTime
	restartClearTimer()
end constructor

destructor logger_type
	erase entry
	fileName = ""
end destructor

function logger_type.add(text as string) as integer
	'add to buffer (at top)
	if numEntries <= ubound(entry) then numEntries += 1
	for i as integer = (numEntries - 1) to 1 step -1
		entry(i) = entry(i - 1)
	next
	entry(0).time_ = time
	entry(0).text = text
	restartClearTimer()
	'write to file
	if fileName = "" then
		return -1
	else
		dim as integer fileNum
		fileNum = freefile
		if open(fileName, for append, as fileNum) = 0 then 
			print #fileNum, entry(0)
			close fileNum
		else
			return -2
		end if
	end if
	return 0
end function

function logger_type.pop() as log_entry_type
	dim as log_entry_type retEntry
	if numEntries > 0 then
		numEntries -= 1
		retEntry = entry(numEntries)
	end if
	return retEntry
end function

sub logger_type.restartClearTimer()
	entryClearEndTimer = timer + entryMinLifeTime
end sub

sub logger_type.updateClearTimer()
	if timer > entryClearEndTimer then
		pop()
		restartClearTimer()
	end if
end sub

'test code

'~ var logger = logger_type("datalog.txt", 5)

'~ print logger.numEntries
'~ logger.add("bla1")
'~ logger.add("bla2")
'~ logger.add("bla3")
'~ print logger.numEntries

'~ for i as integer = 0 to logger.numEntries - 1
	'~ print logger.entry(i)
'~ next

