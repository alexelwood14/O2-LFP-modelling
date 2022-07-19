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

#function posterior_predictive()
#    
#end


# Performs k-fold cross validation
function k_fold_CV(model, x, y, ratio; params=nothing, n_folds=4)
    # Randomly permute the order of samples
    paris = [[x[i], y[i]] for i in 1:length(x)]
    shuffle(paris)

    # Randomly make 4 even (ideally) folds from the samples
    fold_size = floor(length(y)/n_folds)
    start = 1
    folds = []
    if length(y) % fold_size != 0
        push!(folds, paris[start:start+fold_size+1])
    end 
    for i in 2:n_folds
        push!(folds, pairs[start:start+fold_size])
    end
    print(folds)

    # Run model for each combination of 3 train folds

    # Generate Posterior Predictive Distribution

    # Get average residual value from respective test fold

    # Return average of all residual values and best fold and chain
end