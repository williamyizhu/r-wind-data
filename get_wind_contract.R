#check if the working directory is correct
if (tail(unlist(strsplit(getwd(),"/")),n=1) != "r-wind-data") {
	print(paste("Wrong working directory:", getwd()))
	break
}

rm(list=ls(all=TRUE)) 
options(width = 438L)

#ExUL, INDEX
source("//VMWARE-HOST/Shared Folders/Documents/workspace/r-basis-analysis/ExUL.R", echo=FALSE, encoding="GBK")
#wind terminal specific code
library(WindR)
w.start()

#ExUL = ExUL[ExUL$Symbol=="SHFE.HC",]

#---------------------------------- futures symbol ----------------------------------
ExUL = ExUL[ExUL$dsName=="wind",]
w_ex = data.frame(CFFEX="CFE", DCE="DCE", SHFE="SHF")

#contract years, only need to download current year for daily update
c.yg = formatC(seq(2016,2017), width=4, flag='0')
#contract months
c.mg = formatC(seq(1,12), width=2, flag='0')
#contract vector
gg = merge(c.mg, c.yg)
m.vec = data.frame(Year=gg[,2], Month=gg[,1], YearMonth=paste(substr(gg[,2],3,4),gg[,1],sep=""))
#choose future contract month, e.g., between 1601 - 1705
ind = (1601 <= as.numeric(as.character(m.vec[,"YearMonth"]))) & (as.numeric(as.character(m.vec[,"YearMonth"])) < 1702)
m.vec = m.vec[ind,]

#field extracted from wind terminal 
field = c("pre_settle", "open", "high", "low", "close", "settle", "volume", "oi")
#Pre Settle	Open	High	Low	Close	Settle	CH1	CH2	Volume	O.I.	Change

for (k in 1:dim(ExUL)[1]) {
#	contract vector
	print(paste("---------------------", ExUL[k,"Symbol"], "(", k, "of", dim(ExUL)[1], ")", "---------------------"))	
	wExchange = as.character(w_ex[1,as.character(ExUL[k,"Exchange"])])
	c.vec = data.frame(Contract=paste(ExUL[k,"Underlying"], m.vec[,"YearMonth"], ".", wExchange, sep=""), m.vec)
	c.vec = apply(c.vec, c(1,2), as.character)
	
#	create directory if not exist
	ff = paste(ExUL[k,"Exchange"], ExUL[k,"Underlying"], sep="_")
	if (!dir.exists(ff)) {
		dir.create(ff)
	}
	
#	get the start and end date for each contract, then retrieve the data
	for (i in 1:dim(c.vec)[1]) {
#		get the first and last trading date, if both Sys.Date() are not trading day, w.wsd() returns an error
		wd = w.wsd(c.vec[i,"Contract"], "ipo_date,lasttrade_date", Sys.Date()-10, Sys.Date(), paste("TradingCalendar=",ExUL[k,"Exchange"],";Fill=Previous",sep=""))
		IPO_DATE = w.asDateTime(wd$Data$IPO_DATE[1], TRUE)
		LASTTRADE_DATE = w.asDateTime(wd$Data$LASTTRADE_DATE[1], TRUE)
		
#		add data to contract and date vector
		if (is.na(LASTTRADE_DATE) | is.na(IPO_DATE)) {
			print(paste("(", i, "of", dim(c.vec)[1], ")", c.vec[i,"Contract"], "does not exist"))
		} else {
			ts = min(as.Date(IPO_DATE), Sys.Date())
			es = min(as.Date(LASTTRADE_DATE), Sys.Date())				
			w_data = w.wsd(c.vec[i,"Contract"], paste(field,collapse=","), ts, es, paste("TradingCalendar=",ExUL[k,"Exchange"],";Fill=Previous",sep=""))
#			retrieve data from wind if there is no error
			if (w_data$ErrorCode == 0) {			
#				export to csv file, e.g., DCE.I.2014.03.csv
				fpath = paste(getwd(), "/", ff, "/", sep="")
				fname = paste(ExUL[k,"Symbol"], c.vec[i,"Year"], c.vec[i,"Month"], "csv", sep=".")
				write.table(w_data$Data, file=paste(fpath,fname,sep=""), sep=",", row.names=FALSE, col.names=TRUE)				
#				print results
				mk = c("DATETIME", "CLOSE", "SETTLE")
				xt = tail(w_data$Data, n=1)			
				lab = paste(paste(mk, apply(xt[mk],1,as.character), sep="="), collapse=" ")
				print(paste("(", i, "of", dim(c.vec)[1], ")", c.vec[i,"Contract"], IPO_DATE, LASTTRADE_DATE, lab, "ErrorCode:", w_data$ErrorCode))	
			} else {
				print(paste("(", i, "of", dim(c.vec)[1], ")", c.vec[i,"Contract"], IPO_DATE, LASTTRADE_DATE, "ErrorCode:", w_data$ErrorCode))					
			}					
		}
	}
}

#---------------------------------- INDEX symbol ----------------------------------
for (k in 1:dim(INDEX)[1]) {
#	contract vector	
	print(paste("---------------------", INDEX[k,"Symbol.IND"], "(", k, "of", dim(INDEX)[1], ")", "---------------------"))	
	
#	retrieve data from wind terminal
	w_data = w.edb(INDEX[k,"Code"], INDEX[k,"sDate"], INDEX[k,"eDate"], 'Fill=Previous')
	
#	export to csv file, e.g., DCE.I.2014.03.csv
	fpath = paste(getwd(), "/INDEX/", sep="")
	fname = paste(INDEX[k,"Symbol.IND"], "csv", sep=".")
	write.table(w_data$Data, file=paste(fpath,fname,sep=""), sep=",", row.names=FALSE, col.names=TRUE)	
	
#	print results
	mk = c("DATETIME", "CLOSE")
	xt = head(w_data$Data, n=1)
	zt = tail(w_data$Data, n=1)	
	xtlab = paste(paste(mk, apply(xt[mk],1,as.character), sep="="), collapse=" ")
	ztlab = paste(paste(mk, apply(zt[mk],1,as.character), sep="="), collapse=" ")	
	print(paste(xtlab, ztlab, "ErrorCode:", w_data$ErrorCode))		
}

#---------------------------------- FIXED_INCOME symbol ----------------------------------
for (k in 1:dim(FIXED_INCOME)[1]) {
#	contract vector	
	print(paste("---------------------", FIXED_INCOME[k,"Symbol"], "(", k, "of", dim(FIXED_INCOME)[1], ")", "---------------------"))	
	
#	retrieve data from wind terminal
	w_data = w.edb(FIXED_INCOME[k,"Code"], FIXED_INCOME[k,"sDate"], FIXED_INCOME[k,"eDate"], 'Fill=Previous')
	
#	export to csv file, e.g., DCE.I.2014.03.csv
	fpath = paste(getwd(), "/FIXED_INCOME/", sep="")
	fname = paste(FIXED_INCOME[k,"Symbol"], "csv", sep=".")
	write.table(w_data$Data, file=paste(fpath,fname,sep=""), sep=",", row.names=FALSE, col.names=TRUE)	
	
#	print results
	mk = c("DATETIME", "CLOSE")
	xt = head(w_data$Data, n=1)
	zt = tail(w_data$Data, n=1)	
	xtlab = paste(paste(mk, apply(xt[mk],1,as.character), sep="="), collapse=" ")
	ztlab = paste(paste(mk, apply(zt[mk],1,as.character), sep="="), collapse=" ")	
	print(paste(xtlab, ztlab, "ErrorCode:", w_data$ErrorCode))		
}
