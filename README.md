# NeuriViz

> An experiment in making multimodal visualization schemes to investigate effective brain connectivity.

Authors: Jacob Zelko, Zachary P Christensen

![](assets/neuriviz.png)

This is a Work-in-Progress exploration of making easy visualizations to enable rapid interactivity and feedback with EEG data. 

# Exploring This Project

## Reproduce Project Set-Up

To reproduce this project, please do the following:

1. Clone this code base.

2. Download the dataset, [_Go-Nogo Categorization and Detection Task_](https://openneuro.org/datasets/ds002680/versions/1.0.0), by _Delorme et. al._ to the folder `data/exp_raw/`. [1] 
There are a variety of ways to download this dataset from [OpenNEURO](https://openneuro.org/datasets/ds002680/versions/1.0.0/download).
**NOTE: This dataset is ~9GB and in the course of our data processing, expect to have ~15GB of storage space available.**

3. Open the Julia REPL and execute the following to install all necessary packages:

```julia
julia> using Pkg
julia> Pkg.activate("path/to/NeuriViz")
julia> Pkg.instantiate()
```


## Pre-Processing Data 

1. In the `NeuriViz` directory, navigate to the `scripts` directory.

2. Execute the script `load_dataset.jl`.
This will prepare the data to the appropriate format and stores it in the `data/exp_pro` directory.
