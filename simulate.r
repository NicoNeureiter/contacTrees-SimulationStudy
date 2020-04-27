# simulate.r
#
# Performs tree and sequence simulation together with BEAST analysis
# and its evaluation.
library("argparser")

import::from("src/beast.r", process_beast_template)
import::from("src/utils.r", settmpwd, mkdir, run_beast)
import::from("src/seqgen.r", seqgen_sampling)

options(scipen=999)

SAMPLING.DIR = "intermediate/sampling/"

main = function(){
    ntax = 6
    nsamples = 4
    repeats = 1

    mkdir("intermediate/sampling")

    taxa = make_taxa_names(ntax)
    
    # generate template to sample from prior
    simulator_params = list(
        "sample_from_prior" = "true",
        "taxa" = taxa,
        "nsamples" = nsamples+1 # number of samples
        )

    template_beast = "templates/direct_simulator.xml"
    template_seqgen = "templates/seqgen_and_analysis.xml"
    # template_seqgen = "templates/seqgen_and_analysis_startingtree.xml"

    config = "templates/contactrees.toml"

    process_beast_template(
        template_beast,
        config,
        taxa,
        "intermediate/sampling/SAMPLING.xml",
        simulator_params
        )
    
    # run beast to sample from prior
    run_beast("intermediate/sampling/SAMPLING.xml")
    
    # simulate data for every sample n times
    seqgen_sampling(
        "intermediate/sampling/SAMPLING.log",
        "intermediate/sampling/SAMPLING.trees",
        template_seqgen,
        template_beast,
        config,
        config,
        taxa,
        "intermediate/test.xml",
        list(seqlength="10"),
        repeats = repeats
    )
    # merge with another template without sampling from prior
    # run those beast analyses
    # evaluate
    }

make_taxa_names = function(ntax){
    paste(1:ntax)
    # make.unique(rep(LETTERS, length.out=ntax), sep="")
    }


if(!interactive()){
    main()
    }