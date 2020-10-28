using BIDSTools
using DrWatson

@quickactivate "NeuriViz"

data_path = datadir("exp_raw")
layout = Layout(data_path; load_metadata = false)

for sub in layout.subjects
    for ses in sub.sessions
        output_path = datadir("exp_pro") * ses.path[(end - 14):end]
        input_path = data_path * ses.path[(end - 14):end]
        for file in ses.files
	    input_file = input_path * file.path[(length(input_path) + 1):end]
            output_file = output_path * file.path[(length(input_path) + 1):end]
        end
    end
end



