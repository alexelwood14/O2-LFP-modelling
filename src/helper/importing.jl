# Takes a path to an LFP recording and reads information into a dataframe
function import_lfp(path, prefix="../../data/", formatted_path="formatted-lfp/")
    # Get the XML metadata file
    files_xml = root(readxml("$(prefix)$(path)Continuous_Data.openephys"))
    recording = firstelement(firstelement(files_xml))

    # Format XML data into Dict
    files = Dict("processor" => recording["id"], "name" => [], "filename" => [], "position" => [], "bitVolts" => [])
    for elem in eachelement(recording)
        push!(files["name"], elem["name"])
        filename = replace(elem["filename"], r"continuous$"=>"")
        push!(files["filename"], "$(filename)npz")
        push!(files["position"], elem["position"])
        push!(files["bitVolts"], elem["bitVolts"])
    end

    # Add data from each channel/file into a single matrix
    data_channels = [5, 6, 7, 8]
    n_datapoints = length(npzread("../../data/formatted-lfp/$(path)$(files["filename"][data_channels[1]])", ["data"])["data"])
    data = Array{Float32}(undef, length(data_channels), n_datapoints)
    for i in 1:length(data_channels)
        data_element = npzread("../../data/formatted-lfp/$(path)$(files["filename"][data_channels[i]])", ["data"])["data"]
        data_element .*= parse(Float64, files["bitVolts"][data_channels[i]])
        data[i, :] = data_element
    end

    # Add timestamps into vector 
    # Timestamps are identical for each channel so this only needs to be done once
    raw_timestamps = npzread("../../data/formatted-lfp/$(path)$(files["filename"][1])", ["timestamps"])["timestamps"]

    # Creating a timestamp for each datapoint uniformly between the start and end timestamps 
    timestamps = collect(range(raw_timestamps[1], raw_timestamps[end]+1024, n_datapoints))    

    # Collect all LFP attributes into dictionary structure
    lfp_data = Dict("data"=>data, "timestamps"=>timestamps)

    return lfp_data
end

# Takes a path to an O2 file and reads information into a dataframe
function import_o2(path, prefix="../../data/")

end