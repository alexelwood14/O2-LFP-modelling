# O2-LFP-modelling

This project aims to use a Bayesian model to relate Amperometric Oxygen data and Local Field Potential (LFP) data.

## Notebooks

All notebooks are contained in [src/notebooks](src/notebooks/). The following notebooks directly investigate the main research aims:

- [aim1.ipynb](src/notebooks/aim1.ipynb) is an attempt to create a model to compete Aim 1: "Make a formal description of the relationships between oxygen amperometric signals (<1hz) and local field potentials (LFP) (typically 1-80Hz) recorded simultaneously on separate electrodes."
- [aim2.ipynb](src/notebooks/aim2.ipynb) is an attempt to answer Aim 2: "Investigate whether high frequency components of oxygen amperometric signals (>1Hz) are equivalent LFP signals?"


The following notebooks develop techniques used in the processing and analysis of the data:

- [visualisations.ipynb](src/notebooks/visualisations.ipynb) contains code to import the raw LFP and O2 data into Julia and visualise it using some basic plots.
- [filtering.ipynb](src/notebooks/filtering.ipynb) contains code to compute the Fourier transform of O2 data and apply high/low pass filtering. This will be useful later as modelling will involve working with only high/low frequency components of the O2 data. 
- [enveloping.ipynb](src/notebooks/enveloping.ipynb) takes the LFP data, bands it into a specific frequency range and then computes and displays its analytic envelope.
- [leaky-integrator.ipynb](src/notebooks/leaky-integrator.ipynb) creates an implementation of a leaky integrator which can be used to smooth a higher frequency signal so that it can be compared with a lower frequency signal. This will be used throughout the analysis, and especially regarding aim1.

The following notebooks initially investigate and aim to give a better understand the dataset:

- [synchronisation.ipynb](src/notebooks/synchronisation.ipynb) contains code to try to realign the timestamps between O2 and LFP data. Both data recordings contain a flag every 10s to aid in synchronising the data.
- [autocorrelation.ipynb](src/notebooks/autocorrelation.ipynb) contains code to display the temporal autocorrelogram of O2 and LFP data. This should explore the theory that heart rate and respiratory rate should show a temporal autocorrelation at constant offsets.


## Helper functions

As the notebooks have developed, some data processing methods have been used multiple times. To avoid duplicated code segments, these methods have been moved into separate files to be imported as required.

- [importing.jl](src/helpers/importing.jl) contains the functions needed to import the raw data, and it specific to our dataset. This code has been moved across from [visualisations.ipynb](src/notebooks/visualisations.ipynb)
- [filtering.jl](src/helpers/filtering.jl) contains preprocessing functions that will be applied to the data, including a leaky integrator and enveloping. This code has been moved across from notebooks [leaky-integrator.ipynb](src/notebooks/leaky-integrator.ipynb) and [enveloping.ipynb](src/notebooks/enveloping.ipynb).
- [analysis.jl](src/helpers/analysis.jl) contains the functions needed to analyse chains produced by models. This code has been moved across from  [aim1.ipynb](src/notebooks/aim1.ipynb)

## Usage

### Running Notebooks

Running the notebooks requires [Julia](https://julialang.org/) and [IJulia](https://github.com/JuliaLang/IJulia.jl) to first be installed.

1. Clone the repository.
2. Use the terminal to navigate to the root of the repository
3. Run the following commands 

```
$ Julia
julia> using IJulia
julia> notebook()
```
4. Jupyter should open in the browser. Navigate to the desired notebook.

### Importing Data

Data should be placed in a directory called data in the root directory of this repository. Edit path and filename variables within the notebooks to match how the data is stored.