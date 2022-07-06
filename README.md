# O2-LFP-modelling

This project aims to use a Bayesian model to relate Amperometric Oxygen data and Local Field Potential (LFP) data.

## Notebooks

All notebooks are contained in [src/notebooks](src/notebooks/).

- [visualisations.ipynb](src/notebooks/visualisations.ipynb) contains code to import the raw LFP and O2 data into Julia and visualise it using some basic plots.
- [filtering.ipynb](src/notebooks/filtering.ipynb) contains code to compute the Fourier transform of O2 data and apply high/low pass filtering. This will be useful later as modelling will involve working with only high/low frequency components of the O2 data. 
- [synchronisation.ipynb](src/notebooks/synchronisation.ipynb) contains code to try to realign the timestamps between O2 and LFP data. Both data recordings contain a flag every 10s to aid in synchronising the data.
- [autocorrelation.ipynb](src/notebooks/autocorrelation.ipynb) contains code to display the temporal autocorrelogram of O2 and LFP data. This should explore the theory that heart rate and respiratory rate should shot a temporal autocorrelation at offsets of equal period.