rm(list=ls(all=TRUE)) 
options(width = 438L)

library(WindR)
w.start()
#w.menu()
#w.isconnected()

w_ex = data.frame(DCE="DCE", SHF="SHFE")

#---------------- contracts ----------------
BarSize = 15
BarSize = "DAY"

Underlying ="I"; Exchange = "DCE"; Benchmark = c("S0174655");
#Underlying ="CU"; Exchange = "SHF"; Benchmark = NA;
#Underlying ="M"; Exchange = "DCE"; Benchmark = NA;
#Underlying ="RB"; Exchange = "SHF"; Benchmark = NA;
#Underlying ="P"; Exchange = "DCE"; Benchmark = NA;

#contract months
#c.tg = c("01","05","09")
c.tg = formatC(seq(1,12), width=2, flag='0')
#fields obtained from wind terminal
fd = c("close", "volume", "oi")

#---------------- Contract.DF ----------------
fpath = paste(getwd(), "/dataset/", sep="")
fname = paste(Underlying, Exchange, "csv", sep=".")
Contract.DF = read.table(file=paste(fpath,fname,sep=""), header=TRUE, sep=",")

#---------------- contract data ----------------
c.dt = data.frame(DATETIME=character(0)) 
for (i in 1:dim(Contract.DF)[1]) {	
	if (substr(Contract.DF$Month[i],3,4) %in% c.tg) {		
		print(as.character(Contract.DF$Contract[i]))
		if (BarSize == "DAY") {
			ts = min(as.Date(Contract.DF$ListDate[i]), Sys.Date())
			es = min(as.Date(Contract.DF$ExpDate[i]), Sys.Date())			
			w_data = w.wsd(Contract.DF$Contract[i], paste(fd,collapse=","), ts, es, paste("TradingCalendar=",w_ex[,Exchange],";Fill=Previous",sep=""))
		} else {
			ts = paste(Contract.DF$ListDate[i], "00:00:00")
			es = paste(Contract.DF$ExpDate[i], "23:59:59")
#			download data from wind terminal
			w_data = w.wsi(Contract.DF$Contract[i], paste(fd,collapse=","), ts, es, BarSize=BarSize)			
		}		
		names(w_data$Data) = c("DATETIME", paste(Contract.DF$Contract[i],substr(fd,1,2),sep="."))
#		merge contracts into the same data.frame
		c.dt = merge(c.dt, w_data$Data, by="DATETIME", all=TRUE)		
	}
}

#get the benchmark of an underlying, usually the cash spot market price
if (all(!is.na(Benchmark))) {
	ts = as.Date(head(Contract.DF,n=1)$ListDate)
	es = as.Date(tail(Contract.DF,n=1)$ExpDate)	
	for (id in Benchmark) {
		bm = w.edb(id, ts, es, "Fill=Previous")
		names(bm$Data) = c("DATETIME", id)		
		c.dt = merge(c.dt, bm$Data, by="DATETIME", all=TRUE)
	}
} 

#export to csv file
fpath = paste(getwd(), "/dataset/", sep="")
fname = paste(Underlying, Exchange, Sys.Date(), BarSize, "csv", sep=".")
write.table(c.dt, file=paste(fpath,fname,sep=""), sep=",", row.names=FALSE, col.names=TRUE)

#head(c.dt, n=20)
#tail(c.dt, n=20)

#-------------------------------------------------------
Year0 = 2000
YearLengh = 20
#create a data.frame for index start and end date of a month
YearVec = rep(Year0 + seq(0, YearLengh-1), each = 12)
MonthVec = rep(formatC(seq(1, 12), width=2, format="d", flag="0"), YearLengh)
#start date of each month
MonthStart = as.Date(paste(YearVec, MonthVec, "01", sep="-"))
#c(YearVec[-1], Year0 + YearLengh)
#c(MonthVec[-1], "01")
MonthEnd = as.Date(paste(c(YearVec[-1], Year0 + YearLengh), c(MonthVec[-1], "01"), "01", sep="-")) - 1
#Year-Month data.frame
YM = data.frame(YearVec, MonthVec, MonthStart, MonthEnd)
names(YM) = c("Year", "Month", "Start", "End")

