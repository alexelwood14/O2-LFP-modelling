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
function posteriorSample(chain)
    parms = chain.name_map.parameters
    idx = rand(1:length(chain))
    return map(x->chain[x].value[idx] , parms)
end

# Generate posterior predictive samples
function getPredictions(chain, x, mu_formula, p_map; param=ones(length(x)), n_samples_per_x=1000)
    # Get samples of parameters
    postSample = [posteriorSample(chain) for i in 1:n_samples_per_x]
    
    # Get posterior predictive samples for each parameter combination for each x
    predictions = []
    for i in 1:length(x)
        pred_i = []
        for sample in postSample
            mu = mu_formula(x[i], sample, p_map, param[i])
            post = rand(Normal(mu, sample[p_map("sigma")]), 1)[1]
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

function generate_folds(x, y; n_folds=4)
    # Randomly permute the order of samples
    xy_pairs = [[x[i], y[i]] for i in 1:length(x)]
    xy_pairs = shuffle(xy_pairs)

    # Randomly make n_folds ideally even folds from the data
    fold_size::Int = floor(length(y)/n_folds)
    print(fold_size)
    start = 1
    folds = []
    
    for i in 1:fold_size:(n_folds-1)*fold_size
        println("pushing $(start)+$(i):$(start)+$(fold_size)+$(i)")
        println("pushing $(xy_pairs[start+i:start+fold_size+i])")
        push!(folds, xy_pairs[start+i:start+fold_size+i])
    end
    if length(y) % fold_size != 0
        println("pushing last")
        push!(folds[length(folds)], xy_pairs[length(xy_pairs)])
    end 

    return folds
end


# Performs k-fold cross validation
function k_fold_CV(model, x, y, p_map, mu_formula; params=nothing, n_folds=4)
    # Generating Folds
    folds = generate_folds(x, y; n_folds=n_folds)

    chains = []
    residuals = []
    for i in 1:4
        # Run model for each combination of 3 train folds
        println("Sampling Fold $(i):")
        train = vcat(pop(folds, folds[i]))
        x_train = train[1, :] 
        y_train = train[2, :] 
        printlln("\tTraining Model")
        md = model(y_train, x_train, params)
        chain = sample(md, NUTS(0.65), MCMCThreads(), 1000, 4)
        push!(chains, chain)

        # Generate Posterior Predictive Distribution
        println("\tGenerating Posterior Predictive Distribution")
        x_test = folds[i][1]
        y_test = folds[i][2]
        predictions = getPredictions(chain, x_test, mu_formula, p_map; param=params)

        # Get average residual value from respective test fold
        println("\tCaclulating Residual Error")
        x_pred_means = [mean(predictions[i]) for i in 1:length(predictions)]
        push!(avg_residual_error(x_pred_means, y_test))    
    end

    # Return average of all residual values and best fold and chain
    return mean(residuals)
end