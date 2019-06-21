function datalist=load_data_gandhilab(data_path)

%analysis_trials_LMA
%   Analysis of data tirals-by-trials recorded with a laminar probe (LMA)
%   in gandhilab
%
% Corentin Massot
% Cognition and Sensorimotor Integration Lab, Neeraj J. Gandhi
% University of Pittsburgh  
% created 11/03/2015 last modified 11/03/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%read directory
files=dir(data_path);

datalist={};
dateslist=[];
ff=0;
for f=1:size(files),
    file=files(f).name;
    if length(file)>3,
        ff=ff+1;
        dateslist(ff)=str2num([file(17:18) file(13:16)]);
        datalist{ff}=file;
    end
end

%sort files according to date
[~,ind]=sort(dateslist);
datalist=datalist(ind);


