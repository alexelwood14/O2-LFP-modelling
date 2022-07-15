function posteriorSample(chain)
    parms = chain.name_map.parameters
    idx = rand(1:length(chain))
    return map(x->chain[x].value[idx] , parms)
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