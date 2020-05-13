# utils.r
#
# shared utility functions
require("whisker")
require("stringr")


# whisker is R implementation of Mustache templating language
process_template = function(template, data, output){
    if(file.exists(template))
        template = readLines(template)
    text = whisker::whisker.render(template, data)

    if(!is.null(output)){
        writeLines(text, output)
        return()
        } else {
        return(text)
        }
    }


find_tags = function(template){
    if(file.exists(template)){
        template = readLines(template)
        }
    tags = stringr::str_extract_all(template, "\\{{2,3}[/#]?[.\\w]*\\}{2,3}")
    tags = unlist(tags)
    tags = stringr::str_remove_all(tags, "[\\{\\}/#]")
    tags = tags[tags != "." ]
    tags = unique(tags)
    tags
    }


# temporarily set path to particular directory
# path is restored once the calling function/frame ends.
settmpwd = function(wd){
    envir = parent.frame()
    envir$oldwd = getwd()
    do.call("on.exit", list(quote(setwd(oldwd))), envir=envir)
    setwd(wd)
    }


run_beast = function(xml){
    settmpwd(dirname(xml))
    system2("beast", args=c("-overwrite", "-java", basename(xml)))
    }



run_loganalyser = function(){
  system2("loganalyser", args=c("-oneline", "intermediate/test.???.001.log", ">", "results"))
}

run_coverage_calculator = function(){
  system2("/opt/phylo/beast2/bin/applauncher", 
          args=c("CoverageCa", 
                 "-log", "/home/nico/workspace/contactrees_simulation_study/intermediate/sampling/SAMPLING.log",
                 "-logA", "/home/nico/workspace/contactrees_simulation_study/results",
                 "-out", "/home/nico/workspace/contactrees_simulation_study/intermediate/tmp/"))
}

# similar to mkdir -p
mkdir = function(dir){
    if(!dir.exists(dir))
        dir.create(dir, recursive=TRUE)
    }
