


##directory for original dataset downloaded from quandl, DCE.I.2014.03.Close
#
#INDEX$fpath = paste(dpath, paste("r-",INDEX[,"dsName"],"-data",sep=""), "INDEX", paste(INDEX[,"Exchange"],INDEX[,"Underlying"],"csv",sep="."), sep="/")
#
#
#for (j in unique(INDEX[,"Underlying"])) {
#	print(j)
#	
#	sIndex = INDEX[INDEX[,"Underlying"]==j,]
#	
#	c.dt = data.frame(DATETIME=character(0)) 	
#	for (k in 1:dim(sIndex)[1]) {
#		print(sIndex[k,"fpath"])
#		
#		zt = read.table(file=sIndex[k,"fpath"], header=TRUE, sep=",")
#		zt$DATETIME = as.Date(zt$DATETIME)
#		names(zt) = c("DATETIME", sIndex[k,"Symbol"])	
#		
#		c.dt = merge(c.dt, zt, by="DATETIME", all=TRUE, sort=TRUE)
#	}	
#}




#for (k in 1:dim(INDEX)[1]) {
##	contract vector	
#	print(paste("---------------------", INDEX[k,"Exchange"], INDEX[k,"Underlying"], "(", k, "of", dim(INDEX)[1], ")", "---------------------"))	
#	
##	retrieve data from wind terminal
#	w_data = w.edb(INDEX[k,"Code"], INDEX[k,"sDate"], INDEX[k,"eDate"], 'Fill=Previous')
#	
##	export to csv file, e.g., DCE.I.2014.03.csv
#	fpath = paste(getwd(), "/INDEX/", sep="")
#	fname = paste(INDEX[k,"Exchange"], INDEX[k,"Underlying"], "csv", sep=".")
#	write.table(w_data$Data, file=paste(fpath,fname,sep=""), sep=",", row.names=FALSE, col.names=TRUE)	
#
##	print results
#	mk = c("DATETIME", "CLOSE")
#	xt = head(w_data$Data, n=1)
#	zt = tail(w_data$Data, n=1)	
#	xtlab = paste(paste(mk, apply(xt[mk],1,as.character), sep="="), collapse=" ")
#	ztlab = paste(paste(mk, apply(zt[mk],1,as.character), sep="="), collapse=" ")	
#	print(paste(xtlab, ztlab, "ErrorCode:", w_data$ErrorCode))		
#}



















