# O2-LFP-modelling

This project aims to use a Bayesian model to relate Amperometric Oxygen data and Local Field Potential (LFP) data.

## Notebooks

All notebooks are contained in [src/notebooks](src/notebooks/).

- [visualisations.ipynb](src/notebooks/visualisations.ipynb) contains code to import the raw LFP and O2 data into Julia and visualise it using some basic plots.
- [filtering.ipynb](src/notebooks/filtering.ipynb) contains code to compute the Fourier transform of O2 data and apply high/low pass filtering. This will be useful later as modelling will involve working with only high/low frequency components of the O2 data. 
- [synchronisation.ipynb](src/notebooks/synchronisation.ipynb) contains code to try to realign the timestamps between O2 and LFP data. Both data recordings contain a flag every 10s to aid in synchronising the data.
- [autocorrelation.ipynb](src/notebooks/autocorrelation.ipynb) contains code to display the temporal autocorrelogram of O2 and LFP data. This should explore the theory that heart rate and respiratory rate should shot a temporal autocorrelation at offsets of equal period.
- [enveloping.ipynb](src/notebooks/enveloping.ipynb) takes the LFP data, bands it into a specific frequency range and then computes and displays its analytic envelope.
- [laser-stim-feature](src/notebooks/laser-stim-feature.ipynb) is an attempt finding a correlation between the LFP and O2 features after the laser stimulation events. 
- [aim1](src/notebooks/aim1.ipynb) is an attempt to create a model to compete Aim 1: "Make a formal description of the relationships between oxygen amperometric signals (<1hz) and local field potentials (LFP) (typically 1-80Hz) recorded simultaneously on separate electrodes."
- [leaky-integrator](src/notebooks/leaky-integrator.ipynb) creates an implementation of a leaky integrator which can be used to smooth a higher frequency signal so that it can be compared with a lower frequency signal. This will be used throughout the analysis, and especially regarding aim1.

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
4. Jupyter should open in the browser.

### Importing Data

Data should be placed in a directory called data in the root directory of this repository. Edit path and filename variables within the notebooks to match how the data is stored.