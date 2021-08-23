args <- commandArgs(trailingOnly = TRUE)
tdir <- args[1]
outfile <- args[2]
sub_dirs <- list.dirs(tdir,recursive = F)
files <- list.files(sub_dirs,full.names = T)
final_df <- data.frame()
for (sf in files){
	if(length(scan(sf, what="raw", skip = 2, nlines = 2,sep = "\t"))>1){
	print(paste(sf, " has matches, moving forward"))
	f <- read.csv(sf, sep="\t", header=F, skip=3)
       	colnames(f) <- c("Query_ID","DB_ID","DB_length","Perc_identical_matches","DB_coverage_per_HSP",
                        "Alignment_length","Mismatch_number","GAP_openeings_number","STARt_query","END_query","START_db",
			"END_db","Expected_value","Bit_score", "Query_strand", "Aligned_sequence_QUERY", "Aligned_sequence_DB")
	final_df <- rbind(final_df, f)
	}else{
	print(paste(sf, " is empty, no match was found!")) 
	  }
}

write.table(final_df, file = outfile, sep="\t", quote=F, col.names = T, row.names = F)

