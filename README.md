# Contactrees simulation study
A well callibrated simulation study to test the contactrees model.

## Steps:
* sample random parameters, tree and contact edges from prior distribution
* generate data according to model using the `seqgen` package
* reconstruct the tree and parameters from simulated data using BEAST
* compare statistics about the reconstructed trees, edges and parameters with the simulated one

## Simulated scenarios
### Data
* CTMC
* BinaryCovarion
### Tree
* constant population size coalescent
* Yule
* Birth-death
### Contact rate
* Fixed contact rate
* Constant estimated contact rate
### Borrowing probability (per word and contact edge)
* Fixed borrowing probability
* Constant estimated borrowing probability
* Borrowing probability varrying between words
### Clock
* strict
* relaxed lognormal
