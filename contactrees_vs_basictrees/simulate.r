# simulate.r
#
# Performs tree and sequence simulation together with BEAST analysis
# and its evaluation.
library("argparser")

import::from("../src/beast.r", process_beast_template)
import::from("../src/utils.r", settmpwd, mkdir, run_beast, run_loganalyser, run_coverage_calculator, run_acgannotator_all, run_treeannotator_all)
import::from("../src/seqgen.r", seqgen_sampling)

options(scipen=999)

SAMPLING.DIR = "intermediate/sampling/"

main = function(){
    ntax = 25
    nsamples = 60
    simu_sample_interval = 200000
    repeats = 1

    mkdir("intermediate/sampling")
    mkdir("intermediate/contactrees")
    mkdir("intermediate/basictrees")
    mkdir("intermediate/contactrees/coverage")
    mkdir("intermediate/basictrees/coverage")

    taxa = make_taxa_names(ntax)
    
    # generate template to sample from prior
    simulator_params = list(
        "sample_from_prior" = "true",
        "taxa" = taxa,
        "nsamples" = 1 + nsamples,
        "chain_length" = 1 + simu_sample_interval*nsamples,
        "sample_interval" = simu_sample_interval
        )
    
    # template_simulator = "templates/direct_simulator.xml"
    template_simulator = "templates/mcmc_simulator.xml"
    template_seqgen = "templates/seqgen_and_analysis.xml"

    config_ct = "templates/contactrees.toml"
    config_bt = "templates/basictrees.toml"

    process_beast_template(
        template_simulator,
        config_ct,
        taxa,
        "intermediate/sampling/SAMPLING.xml",
        simulator_params
        )

    # run beast to sample from prior
    run_beast("intermediate/sampling/SAMPLING.xml")

    # simulate data and reconstruct with contactrees
    seqgen_sampling(
        "intermediate/sampling/SAMPLING.log",
        "intermediate/sampling/SAMPLING.trees",
        template_seqgen,
        config_ct,
        config_ct,
        taxa,
        "intermediate/contactrees/test.xml",
        list(seqlength="20"),
        repeats = repeats
    )

    # simulate data and reconstruct with basic tree analysis
    seqgen_sampling(
        "intermediate/sampling/SAMPLING.log",
        "intermediate/sampling/SAMPLING.trees",
        template_seqgen,
        config_bt,
        config_bt,
        taxa,
        "intermediate/basictrees/test.xml",
        list(seqlength="20"),
        repeats = repeats
    )
    
    # evaluate
    run_loganalyser("intermediate/contactrees/")
    run_coverage_calculator("intermediate/contactrees/")
    # run_acgannotator_all("intermediate/contactrees/")

    run_loganalyser("intermediate/basictrees/")
    run_coverage_calculator("intermediate/basictrees/")
    # run_treeannotator_all("intermediate/basictrees/")
    }

make_taxa_names = function(ntax){
    paste(1:ntax)
    # make.unique(rep(LETTERS, length.out=ntax), sep="")
    }


if(!interactive()){
    main()
    }
