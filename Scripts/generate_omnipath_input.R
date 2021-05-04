#!/usr/bin/env Rscript

library(dplyr)
library(OmnipathR)
library(reshape2)


# Function to convert the input measurments into appropriate format for CARNIVAL
generateTFList <- function (df = df, top = 50, access_idx = 1) 
{
    if (top == "all") {
        top <- nrow(df)
    }

    if (top > nrow(df)) {
        warning("Number of to TF's inserted exceeds the number of actual TF's in the\n            
                 data frame. All the TF's will be considered.")
        top <- nrow(df)
    }

    ctrl <- intersect(x = access_idx, y = 1:ncol(df))
    if (length(ctrl) == 0) {
        stop("The indeces you inserted do not correspond to \n              
              the number of columns/samples")
    }
    returnList <- list()
    for (ii in 1:length(ctrl)) {
        tfThresh <- sort(x = abs(df[, ctrl[ii]]), decreasing = TRUE)[top]
        temp <- which(abs(df[, ctrl[ii]]) >= tfThresh)
        currDF <- matrix(data = , nrow = 1, ncol = top)
        colnames(currDF) <- rownames(df)[temp[1:top]]
        currDF[1, ] <- df[temp[1:top], ctrl[ii]]
        currDF <- as.data.frame(currDF)
        returnList[[length(returnList) + 1]] <- currDF
    }
    names(returnList) <- colnames(df)[ctrl]
    return(returnList)
}

# Function to create a PKN based on information obtained from Omnipath
loadPKNForCarnival = function(df, filter_by_references = 0) {

    omnipath_pkn = df %>% dplyr::filter( is_directed == 1 ) %>%
    dplyr::mutate_at( c("n_references"), ~as.numeric(as.character(.))) %>%
    dplyr::filter( n_references >= filter_by_references ) %>%
    dplyr::select( "source_genesymbol", "target_genesymbol", "consensus_stimulation", "consensus_inhibition" ) %>%
    dplyr::mutate_at( c("consensus_stimulation", "consensus_inhibition"), ~as.numeric(as.character(.)))

    omnipath_pkn_inh_upd = omnipath_pkn %>% melt() %>%
    filter(variable == "consensus_inhibition" & value == "1") %>%
    mutate(value = -1)

    omnipath_pkn = omnipath_pkn %>% melt() %>%
    filter( variable == "consensus_stimulation" & value != "0" ) %>%
    rbind(omnipath_pkn_inh_upd)

    omnipath_pkn = omnipath_pkn %>% dplyr::select("source_genesymbol", "target_genesymbol", "value") %>%
                                  relocate("target_genesymbol", "value")
    colnames(omnipath_pkn) = c("source", "effect", "target")
    return(omnipath_pkn)
}

# We first process the measurments (found in measurments.csv file)
measurements = read.csv(snakemake@input[[1]])
tf_activities_carnival <- data.frame(measurements, stringsAsFactors = F)
rownames(tf_activities_carnival) <- measurements$TF
tf_activities_carnival$TF <- NULL

tfList = generateTFList(tf_activities_carnival, top=50, access_idx = 1)

write.csv(tfList$t, snakemake@output[[1]], quote = FALSE, row.names = FALSE)

# Next we create the PKN that is passed to CARNIVAL
omnipath <- import_omnipath_interactions(from_cache_file = NULL,
                                         filter_databases = get_interaction_resources(),
                                         select_organism = 9606)
omnipath <- loadPKNForCarnival(omnipath, 0)

write.csv(omnipath, snakemake@output[[2]], quote = FALSE, row.names = FALSE)

# We create and save the input dataframe 
diffNodes = base::setdiff(omnipath$source, omnipath$target)
initiators = base::data.frame(base::matrix(data = NaN, nrow = 1, ncol = length(diffNodes)), stringsAsFactors = F)
colnames(initiators) = diffNodes
write.csv(initiators, snakemake@output[[3]], quote = FALSE, row.names = FALSE)

carnival_input <- list(inputObj = initiators, measObj = tfList$t, netObj = omnipath)
saveRDS(carnival_input, snakemake@output[[4]])

