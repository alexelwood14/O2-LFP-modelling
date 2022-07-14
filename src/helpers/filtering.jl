# Smooths a signal S with lag coefficient k
function leaky_integrator(S; k=0.5)
    t = (1:length(S))
    
    y = zeros(length(t))

    for i in 1:(length(t)-1)
        dy = (S[i]-y[i])/k
        y[i+1] = y[i]+dy*dt
    end

    return y
end