using NPZ
using EzXML

function import_lfp_events(path, prefix="../../data/", formatted_path="formatted-lfp/")
    raw_events = npzread("$(prefix)$(formatted_path)$(path)all_channels.npz")

    delete!(raw_events, "recordingNumber")
    delete!(raw_events, "sampleNumber")
    delete!(raw_events, "eventType")
    delete!(raw_events, "nodeId")

    type_mapping = Dict(0.0=>"laser", 4.0=>"sync", 7.0=>"oxygen")

    events = Dict()
    for event_type in unique(raw_events["channel"])
        timestamps = raw_events["timestamps"][findall(x->x==event_type, raw_events["channel"])] 
        activation = raw_events["eventId"][findall(x->x==event_type, raw_events["channel"])]

        on = timestamps[findall(x->x==1, activation)]
        off = timestamps[findall(x->x==0, activation)]
        
        events[type_mapping[event_type]] = Dict("on"=>on, "off"=>off)
    end

    # Add empty lists if flag present in data
    for value in values(type_mapping)
        if !haskey(events, value)
            events[value] = Dict("on"=>[], "off"=>[])
        end
    end

    return events
end


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
    data_channels = (1:length(files["filename"]))
    n_datapoints = length(npzread("$(prefix)$(formatted_path)$(path)$(files["filename"][data_channels[1]])", ["data"])["data"])
    data = Array{Float32}(undef, length(data_channels), n_datapoints)
    for i in 1:length(data_channels)
        data_element = npzread("$(prefix)$(formatted_path)$(path)$(files["filename"][data_channels[i]])", ["data"])["data"]
        data_element .*= parse(Float64, files["bitVolts"][data_channels[i]])
        data[i, :] = data_element
    end

    # Add timestamps into vector 
    # Timestamps are identical for each channel so this only needs to be done once
    raw_timestamps = npzread("$(prefix)$(formatted_path)$(path)$(files["filename"][1])", ["timestamps"])["timestamps"]

    # Creating a timestamp for each datapoint uniformly between the start and end timestamps 
    timestamps = round.(collect(range(raw_timestamps[1], raw_timestamps[end]+1024, n_datapoints)))

    # Import events
    events = import_lfp_events(path)

    # Collect all LFP attributes into dictionary structure
    lfp_data = Dict("data"=>data, "timestamps"=>timestamps, "laser"=>events["laser"], "oxygen"=>events["oxygen"], "sync"=>events["sync"])

    return lfp_data
end


# Takes a path to an O2 file and reads information into a dataframe
function import_o2(path, prefix="../../data/")
    raw_data = []

    # Read data line by line
    open("$(prefix)$(path)") do file
        for line in eachline(file)
            if isdigit(line[1])
                # data_element = [timestamp, o2 data, sync flag, heat flag]
                data_element = split(line, "\t")  
                if length(data_element) == 3 && data_element[3] == "#* timeTick ON "
                    data_element = [parse(Float32, data_element[1]), parse(Float32, data_element[2]), 1, 0]
                elseif length(data_element) == 3 && data_element[3] == "#* heatStim ON "
                    data_element = [parse(Float32, data_element[1]), parse(Float32, data_element[2]), 0, 1]
                else
                    data_element = [parse(Float32, data_element[1]), parse(Float32, data_element[2]), 0, 0]
                end
                push!(raw_data, data_element)
            end
        end
    end
    raw_data = reduce(vcat,transpose.(raw_data))
    
    # Get lists of timestamps for each event
    sync = raw_data[findall(x->x==1, raw_data[:,3]), 1] .* 1000
    laser = raw_data[findall(x->x==1, raw_data[:,4]), 1] .* 1000

    # Extract data/timestamps into individual vectors
    data = raw_data[:, 2]
    timestamps = raw_data[:, 1] .* 1000

    # Collect all O2 attributes into dictionary structure
    o2_data = Dict("timestamps"=>timestamps, "data"=>data, "sync"=>sync, "laser"=>laser)

    return o2_data
end