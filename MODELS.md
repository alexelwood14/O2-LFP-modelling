# Models

This file contains formal definitions for all models used in this project. See [models.jl](src/helpers/models.jl) for the code corresponding to each model.

## Linear Regression

$$y_i \sim Normal(\mu_i, \sigma_i)$$

$$\mu_i = \beta x_{i} + \alpha$$

$$\alpha \sim Normal(0, 1)$$

$$\beta \sim Normal(0, \tau_\beta)$$

$$\tau_\beta \sim Gamma(2, var(x))$$

$$\sigma_i \sim Gamma(2, var(x))$$

## Hierarchical_LR

Hierarchical Linear Regression

$$y_i \sim Normal(\mu_i, \sigma_i)$$

$$\mu_i = \beta_j x_{i} + \alpha$$

$$\alpha \sim Normal(0, 1)$$

$$\beta_j \sim Normal(0, \tau_\beta)$$

$$\tau_\beta \sim Gamma(2, var(x))$$

$$\sigma_i \sim Gamma(2, var(x))$$

## HLR_Order2 

Second Order Hierarchical Linear Regression

$$y_i \sim Normal(\mu_i, \sigma_i)$$

$$\mu_i = \beta_j x_{i} + \gamma_j x_{i}^2 + \alpha$$

$$\alpha \sim Normal(0, 1)$$

$$\beta_j \sim Normal(0, \tau_\beta)$$

$$\gamma_j \sim Normal(0, \tau_\gamma)$$

$$\tau_\beta \sim Gamma(2, var(x))$$

$$\tau_\gamma \sim Gamma(2, var(x))$$

$$\sigma_i \sim Gamma(2, var(x))$$

## HLR2_Dynamic_Smoothing

Second Order Hierarchical Linear Regression with Dynamic Leaky Integrator Smoothing

$$y_i \sim Normal(\mu_i, \sigma_i)$$

$$\mu_i = \beta_j \hat{x}_{i} + \gamma_j \hat{x}_{i}^2 + \alpha$$

$$\hat{x}_{i+1} = \hat{x}_i+((x_i-\hat{x}_i)/\theta)$$

$$\theta \sim Gamma(2, \tau_\theta)$$

$$\alpha \sim Normal(0, 1)$$

$$\beta_j \sim Normal(0, \tau_\beta)$$

$$\gamma_j \sim Normal(0, \tau_\gamma)$$

$$\tau_\theta \sim Gamma(1, 15)$$

$$\tau_\beta \sim Gamma(2, var(x))$$

$$\tau_\gamma \sim Gamma(2, var(x))$$

$$\sigma_i \sim Gamma(2, var(x))$$

## AR

Linear Regression with 10 Lags

$$y_i \sim Normal(\mu_i, \sigma_i)$$

$$\mu_i = \sum_{j=1}^{10}\beta_jx_{i-j}$$

$$\beta_j \sim Normal(0, \tau_\beta)$$

$$\tau_\beta \sim Gamma(2, 2)$$

$$\sigma_i \sim Gamma(2, 2)$$

## AR_no_multi_colin

Linear Regression with 10 Lags addressing autocolinearity

$$y_i \sim Normal(\mu_i, \sigma_i)$$

$$\mu_i = \beta\sum_{j=1}^{10}x_{i-j}$$

$$\beta \sim Normal(0, \tau_\beta)$$

$$\tau_\beta \sim Gamma(2, 2)$$

$$\sigma_i \sim Gamma(2, 2)$$