# MHKY simulation study
A simulation study to test the MHKY model from the `phylonco` package.

## Steps:
* sample random parameters and trees (according to these parameters) from prior
* generate data according to model using the `seqgen` package
* reconstruct the tree and parameters from simulated data using BEAST
* compare the reconstructed topology and parameters with the simulated one

## Simulated scenarios
### Data
* MHKY with varied kappa, alpha, beta and gamma
* HKY/GTR + binary model for methylation
### Tree
* constant population size
* exponentially growing pop. size
### Clock
* strict
* relaxed lognormal
