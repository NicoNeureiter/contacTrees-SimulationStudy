# seqgen.r
#
# simulate sequences based on parameter values
require("ape")
require("tools")
library("magrittr")

import::from("beast.r", merge, process_beast_template)
import::from("utils.r", run_beast)
import::from("stringr", str_pad)
import::from("icesTAF", mkdir)
import::from("rlist", list.append)
import::from("parallel", mclapply)

seqgen = function(seqgen_template,
                  seqgen_config,
                  taxa,
                  output,
                  parameters = list(),
                  repeats = 1
    ){
    output = normalize_path(output)

    for(i in seq_len(repeats)){
        repeat_output = repeat_path(output, i) # some temp path
        parameters[["sequence_output"]] = buid_seq_output(repeat_output)
        process_beast_template(
            seqgen_template,
            seqgen_config,
            taxa,
            repeat_output,
            parameters
            )
        run_beast(repeat_output)
        }
    }


seqgen_sampling = function( log,
                            trees_path,
                            seqgen_template,
                            merge_template,
                            seqgen_config,
                            merge_config,
                            taxa,
                            output,
                            parameters = list(),
                            repeats = 1
    ){
    log = read_log(log)
    
    
    # trees = ape::read.nexus(trees)[-1]
    trees = read_tree_lines(trees_path)

    if(nrow(log) != length(trees))
        stop("ERROR: rows of log should be identical to the number of trees")
    
    all.run.args = list()
    
    for(i in seq_along(trees)){
        variables = to_list(log[i,])
        variables[["tree"]] = trees[[i]]
        variables[["taxa"]] = taxa
        
        variables = merge(variables, parameters)
        sampling_output = repeat_path(output, i)
        
        run.args = list(vars=variables, out=sampling_output)
        all.run.args = list.append(all.run.args, run.args)
    }

        
    mclapply(X = all.run.args,
             FUN = function(run.args) seqgen(seqgen_template,
                                             seqgen_config,
                                             taxa,
                                             run.args[['out']],
                                             run.args[['vars']],
                                             repeats),
             mc.cores = 2,
             mc.preschedule = FALSE,
             mc.allow.recursive = FALSE)
    }

read_tree_lines = function(trees_path) {
  trees <- list()
  trees_con <- file(trees_path)
  trees_lines <-readLines(trees_con)
  
  i_tree <- 1
  for (i_line in 1:length(trees_lines)) {
    line = trees_lines[i_line]
    if (startsWith(line, "tree STATE_")) {
      tree_str <- strsplit(line, " \\[&R\\] ")[[1]][2]
      trees[i_tree] <- tree_str
      i_tree = i_tree + 1
    }  
  }
  
  close(trees_con)
  return(trees[-1]) # first values are starting positions
}


normalize_path = function(x){
    wd = getwd()
    file.path(wd, x)
    }


repeat_path = function(path, i){
    i_padded = str_pad(i, 3, pad="0")
    paste(tools::file_path_sans_ext(path), i_padded, tools::file_ext(path), sep=".")
}


buid_seq_output = function(path){
  path_stripped <- tools::file_path_sans_ext(path)
  seq_dir <- paste(path_stripped, ".data/", sep="")
  mkdir(seq_dir)
  paste(seq_dir, "block$(x).xml", sep="")
}


read_log = function(log){
    log = read.table(log, header=TRUE, stringsAsFactors=FALSE)
    log = log[-1,] # first values are starting positions
    bad_columns = c("Sample", "posterior", "likelihood", "prior")
    log = log[, !colnames(log) %in% bad_columns]
    log
    }


to_list = function(vec){
    # as.list(vec) would be enough if not for multidimensional parameters
    names = names(vec)
    dotnames = grep("\\.[0-9]+$", names)
    dotvec = vec[dotnames]
    vec = vec[-dotnames]
    dotlist = to_list_dotvec(dotvec)
    list = as.list(vec)
    return(c(vec, dotlist))
    }


to_list_dotvec = function(dotvec){
    unique_dotnames = unique(sub("\\.[0-9]+$", "", names(dotvec)))
    dotlist = lapply(unique_dotnames, to_list_dotname, dotvec)
    names(dotlist) = unique_dotnames
    dotlist
    }


to_list_dotname = function(name, dotvec){
    match = unlist(dotvec[grep(name, names(dotvec))])
    order = strsplit(names(match), split=".", fixed=TRUE)
    order = lapply(order, getElement, 2)
    order = as.numeric(unlist(order))
    names(match) = NULL
    match[order]
    }
