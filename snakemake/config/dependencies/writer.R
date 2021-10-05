args <- commandArgs(trailingOnly = TRUE)
tdir <- args[1]
outfile <- args[2]
outname1 <- paste(outfile, "_final.txt", sep="")
outname2 <- paste(outfile, "_nohits.txt", sep="")
sub_dirs <- list.dirs(tdir,recursive = F)
files <- list.files(sub_dirs,full.names = T)
final_df <- data.frame()
rem_df <- data.frame()
for (sf in files){
	if(length(scan(sf, what="raw", skip = 2, nlines = 2,sep = "\t"))>1){
	print(paste(sf, " has matches, moving forward"))
	f <- read.csv(sf, sep="\t", header=F, skip=3)
       	colnames(f) <- c("Query_ID","DB_ID","DB_length","Perc_identical_matches","DB_coverage_per_HSP",
                        "Alignment_length","Mismatch_number","GAP_openeings_number","START_query","END_query","START_db",
			"END_db","Expected_value","Bit_score", "Query_strand", "Aligned_sequence_QUERY", "Aligned_sequence_DB")
	f$Number_of_hits <- dim(f)[1]
	f$Mutation <- "Intact"
	final_df <- rbind(final_df, f)
	}else{
	print(paste(sf, " is empty, no match was found!")) 
	camp <- strsplit(sf,split="\\/")[[1]][3]
	f <- data.frame(Query_ID=camp,DB_ID="",DB_length="",Perc_identical_matches="None",DB_coverage_per_HSP="None",
			Alignment_length="None",Mismatch_number="None",GAP_openeings_number="None",START_query="None",
			END_query="None",START_db="None",END_db="None",Expected_value="None",Bit_score="None", 
			Query_strand="None", Aligned_sequence_QUERY="None",Aligned_sequence_DB="None") #read.csv(sf, sep="\t", header=F, skip=3)
	f$Number_of_hits <- 0
	f$Mutation <- "Missing"
	rem_df <- rbind(rem_df, f)
      	}
	#final_df <- rbind(final_df, f)
#	final_df$StopCodon_Detected <- "None"
#	final_df$StopCodon_Detected[which(grepl("\\*",final_df$Aligned_sequence_QUERY)==TRUE)] <- "Yes"
#	final_df$Mutation[which(as.numeric(final_df$DB_coverage_per_HSP)<90)] <- "Incomplete"
#	rem_df$StopCodon_Detected <- "None"
#	rem_df$StopCodon_Detected[which(grepl("\\*",rem_df$Aligned_sequence_QUERY)==TRUE)] <- "Yes"
#	rem_df$Mutation[which(as.numeric(rem_df$DB_coverage_per_HSP)<90)] <- "Incomplete"
}

final_df$StopCodon_Detected <- "None"
final_df$StopCodon_Detected[which(grepl("\\*",final_df$Aligned_sequence_QUERY)==TRUE)] <- "Yes"
final_df$Mutation[which(as.numeric(final_df$DB_coverage_per_HSP)<90)] <- "Incomplete"

rem_df$StopCodon_Detected <- "None"
rem_df$StopCodon_Detected[which(grepl("\\*",rem_df$Aligned_sequence_QUERY)==TRUE)] <- "Yes"
rem_df$Mutation[which(as.numeric(rem_df$DB_coverage_per_HSP)<90)] <- "Incomplete"

end_df <- rbind(final_df, rem_df)
write.table(end_df, file = outname1, sep="\t", quote=F, col.names = T, row.names = F)
