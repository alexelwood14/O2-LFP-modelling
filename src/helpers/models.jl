# Linear Regression
@model function Linear_Regression(y, x, params)
    # Priors
    tau_beta ~ Gamma(2, var(x))
    beta ~ Normal(0, 1)
    sigma ~ Gamma(2, var(x))
    alpha ~ Normal(0, 1)

    mu = (x .* beta .* tau_beta) .+ alpha
    y ~ MvNormal(mu, sigma)
end

# Hierarchical Linear Regression
@model function Hierarchical_LR(y, x, a)
    # Priors
    tau_beta ~ Gamma(2, var(x))
    beta ~ filldist(Normal(0, 1), 2)
    sigma ~ Gamma(2, var(x))
    alpha ~ Normal(0, 1)

    # Likleyhood
    mu = (x .* beta[a] .* tau_beta) .+ alpha
    y ~ MvNormal(mu, sigma)
end

# Second Order Hierarchical Linear Regression
@model function HLR_Order2(y, x, a)
    # Priors
    tau_beta ~ Gamma(2, var(x))
    tau_gamma ~ Gamma(2, var(x))
    beta ~ filldist(Normal(0, 1), 2)
    gamma ~ filldist(Normal(0, 1), 2)
    sigma ~ Gamma(2, var(x))
    alpha ~ Normal(0, 1)

    # Likleyhood
    mu = (x .* beta[a] .* tau_beta) .+ (x.^2 .* gamma[a] .* tau_gamma) .+ alpha
    y ~ MvNormal(mu, sigma)
end


# Second Order Hierarchical Linear Regression with Dynamic Leaky Integrator Smoothing
@model function HLR2_Dynamic_Smoothing(y, x, a)
    # Priors
    tau_beta ~ Gamma(2, var(x))
    tau_gamma ~ Gamma(2, var(x))
    tau_theta ~ Gamma(1, 15)
    beta ~ filldist(Normal(0, 1), 2)
    gamma ~ filldist(Normal(0, 1), 2)
    theta ~ Gamma(2, tau_theta)
    sigma ~ Gamma(2, var(x))
    alpha ~ Normal(0, 1)

    # Likleyhood
    x_hat = 0
    for i in eachindex(y)
        x_hat += (x[i] - x_hat) / theta
        mu = (x_hat * beta[a[i]] * tau_beta) + (x_hat^2 * gamma[a[i]] * tau_gamma) + alpha
        y[i] ~ Normal(mu, sigma)
    end
end

# Linear Regression with 10 Lags
@model function AR(y, x)
    # Priors
    tau_beta ~ Gamma(2, 2)
    beta ~ filldist(Normal(0, 1), 10)
    sigma ~ Gamma(2, 2)

    for i in 10:length(y)
        mu = sum(x[i-9:i] .* beta .* tau_beta)
        y[i] ~ Normal(mu, sigma)
    end
end

# Linear Regression with 10 Lags addressing autocolinearity
@model function AR_no_multi_colin(y, x)
    # Priors
    tau_beta ~ Gamma(2, 2)
    beta ~ Normal(0, 1)
    sigma ~ Gamma(2, 2)

    for i in 10:length(y)
        mu = sum(x[i-9:i]) * beta * tau_beta
        y[i] ~ Normal(mu, sigma)
    end
end