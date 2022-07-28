using LazyArrays
using MCMCChains
using Statistics
using StatsBase
using Turing
using MCMCChains
using Distributions
using Random
Random.seed!(123)

# Gets a sample from the posterior
function posteriorSample(chain; old=false)
    if old
        parms = chain.name_map.parameters
        idx = rand(1:length(chain))
        return map(x->chain[x].value[idx] , parms)
    else
        idx = rand(1:length(chain))
        sample = Dict()
        for name in chain.name_map.parameters
            sample[name] = get(chain; section=:parameters)[name][idx]
        end
        return sample
    end
end

# Generate posterior predictive samples
function getPredictions(chain, x, mu_formula; n_samples_per_x=1000, old=false)
    # Get samples of parameters
    postSample = [posteriorSample(chain; old=old) for i in 1:n_samples_per_x]
    
    # Get posterior predictive samples for each parameter combination for each x
    predictions = []
    for i in 1:length(x)
        pred_i = []
        for sample in postSample
            mu = mu_formula(x[i], sample, nothing)
            if old
                post = rand(Normal(mu, sample[6]), 1)[1]
            else
                post = rand(Normal(mu, sample[:sigma]), 1)[1]
            end
            push!(pred_i, post)
        end
        push!(predictions, pred_i)
    end

    return predictions
end


# Calculates the total residual error between x and y
# x and y must be the same length
function total_residual_error(x, y)
    return sum(abs.(x - y))
end


# Calculates the average residual error between x and y
# x and y must be the same length
function avg_residual_error(x, y)
    return sum(abs.(x - y))/length(x)
end

# Split the data into folds to support cross-validation
function generate_folds(x, y; n_folds=4)
    # Randomly permute the order of samples
    xy_pairs = [[x[i], y[i]] for i in 1:length(x)]
    xy_pairs = shuffle(xy_pairs)

    # Randomly make n_folds ideally even folds from the data
    fold_size::Int = floor(length(y)/n_folds)
    folds = []
    
    # Push as many equally sized pairs into each fold as possible
    for i in 1:fold_size:n_folds*fold_size
        push!(folds, xy_pairs[i:fold_size+i-1])
    end

    # If the number of pairs is not divisible by fold size push leftover pairs as evenly as possible
    if length(y) % fold_size != 0
        for i in fold_size*n_folds+1:length(xy_pairs)
            push!(folds[i%n_folds], xy_pairs[i])
        end
    end 

    return folds
end

function avg_k_fold_CV(model, x, y, mu_formula; params=nothing, n_folds=4, threads=4, chain_length=1000, n_samples_per_x=100, old=false)
    # Generating Folds
    # folds[fold][pair][x/y][datapoint]
    folds = generate_folds(x, y; n_folds=n_folds)
    avg_x = [mean(folds[i][:][1]) for i in 1:n_folds]
    avg_y = [mean(folds[i][:][2]) for i in 1:n_folds]

    chains = []
    residuals = []
    for i in 1:n_folds
        # Get training folds
        println("Sampling Fold Combination $(i) of $(n_folds):")
        x_train = []
        y_train = []
        for j in 1:n_folds
            if j != i
                push!(x_train, avg_x[j])
                push!(y_train, avg_y[j])
            end
        end
        x_train = [x_train[i][j] for i in 1:length(x_train) for j in 1:length(x_train[i])]
        y_train = [y_train[i][j] for i in 1:length(y_train) for j in 1:length(y_train[i])]
        
        # Run model with training folds
        println("\tTraining Model")
        extended_params = []
        if !isnothing(params)
            for i in 1:div(length(x), n_folds)
                for j in eachindex(params)
                    push!(extended_params, params[j]) 
                end
            end
        end
        md = model(y_train, x_train, extended_params)
        chain = sample(md, NUTS(0.65), MCMCThreads(), chain_length, threads)
        push!(chains, chain)

        # Generate Posterior Predictive Distribution
        println("\tGenerating Posterior Predictive Distribution")
        x_test = avg_x[i] 
        y_test = avg_y[i]
        predictions = getPredictions(chain, x_test, mu_formula; n_samples_per_x=n_samples_per_x, old=old)

        # Get average residual value from respective test fold
        println("\tCaclulating Residual Error")
        x_pred_means = [mean(predictions[i]) for i in 1:length(predictions)]
        push!(residuals, avg_residual_error(x_pred_means, y_test))
    end

    # Return average of all residual values and best fold and chain
    return Dict("chains"=>chains, "residuals"=>residuals)
end


# Performs k-fold cross validation
function k_fold_CV(model, x, y, mu_formula; params=nothing, n_folds=4, threads=4, chain_length=1000, n_samples_per_x=100, old=false)
    # Generating Folds
    # folds[fold][pair][x/y][datapoint]
    folds = generate_folds(x, y; n_folds=n_folds)

    chains = []
    residuals = []
    for i in 1:n_folds
        # Get training folds
        println("Sampling Fold Combination $(i) of $(n_folds):")
        train = []
        for j in 1:n_folds
            if j != i
                push!(train, folds[j])
            end
        end
        x_train = [train[k][l][1][d] for k in 1:length(train) for l in 1:length(train[k]) for d in 1:length(train[k][l][1])]
        y_train = [train[k][l][2][d] for k in 1:length(train) for l in 1:length(train[k]) for d in 1:length(train[k][l][1])]

        # Run model with training folds
        println("\tTraining Model")

        md = model(y_train, x_train, params)
        chain = sample(md, NUTS(0.65), MCMCThreads(), chain_length, threads)
        push!(chains, chain)

        # Generate Posterior Predictive Distribution
        println("\tGenerating Posterior Predictive Distribution")
        x_test = [folds[i][k][1][d] for k in 1:length(folds[i]) for d in 1:length(folds[i][k][1])]
        y_test = [folds[i][k][2][d] for k in 1:length(folds[i]) for d in 1:length(folds[i][k][2])]
        predictions = getPredictions(chain, x_test, mu_formula; n_samples_per_x=n_samples_per_x, old=old)

        # Get average residual value from respective test fold
        println("\tCaclulating Residual Error")
        x_pred_means = [mean(predictions[i]) for i in 1:length(predictions)]
        push!(residuals, avg_residual_error(x_pred_means, y_test))    
    end

    # Return average of all residual values and best fold and chain
    return Dict("chains"=>chains, "residuals"=>residuals)
end