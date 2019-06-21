%function analysis_events

%function analysis_events
%   Analysis of data averaged over trials recorded with a laminar probe (LMA)
%
% Corentin Massot
% Cognition and Sensorimotor Integration Lab, Neeraj J. Gandhi
% University of Pittsburgh  
% created 11/03/2015 last modified 01/09/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%set paths
[root_path data_path save_path]=set_paths;

%screen size
scrsz = get(groot,'ScreenSize');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%parameters
%print figures
savefigs=0;
figtype='epsc2';%'png';%'epsc2';

%alignement
%alignlist={'no' 'targ' 'go' 'sacc' 'targ_pburst' 'targ_rsburst' 'sacc_pburst' 'sacc_rsburst'};
%alignlist={'targ' };
alignlist={'sacc' };

%window of analysis
%wind=[];%all
%wind=[-50 250];%targ align
wind=[-200 200];%sacc align

%sigma FR
sigma_FR=6;

%shift
shift_spk=80;
shift_lfp=30;

%newdata directory
savedata=0;
newdata_dir='saveData_SC\';

%shift ripple temporal correction
shift_ripple=4

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%get data
datalist=load_data_gandhilab(data_path);


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%analyzing data
dlist=get_dlist;
        
data=[];
info=[];
for d=dlist
    
    %get data and info
    clear('data')
    info.datafile=datalist{d};
    load ([data_path info.datafile]);
    display(info.datafile)
    
    %getting channel mapping and discard selected bad channels
    [info.chmap info.nchannels info.depths]=get_chmap(data(1).info.electrode{2},[]);
    %[info.chmap info.nchannels info.depths]=get_chmap([9:16  1:8],[]);
     
     
    %getting trial type
    info.trialtype=data(1).sequence(1);
    %getting list of targets
    targslist=data(1).offline.targslist;
    %targets index
    targs_ind=get_targsindex(targslist,info);
    %%target tuning (after compute_tuning)
    info.targ_tuning=data(1).offline.targ_tuning;
    
    %select trials
    seltrials=get_seltrials(data,'rpt');
    
    %loop across all alignements
    for al=1:numel(alignlist)
        info.align=alignlist{al};
        
        %get alltrials with specific alignement
        [alltrials_spk_tuning info.aligntime]=get_alltrials_align(data,seltrials,[],'fr',info,targslist,sigma_FR,1);
        [alltrials_spk info.aligntime ~]=get_alltrials_align(data,seltrials,wind,'fr',info,targslist,sigma_FR,1);
        [alltrials_lfp ~]=get_alltrials_align(data,seltrials,wind+shift_ripple,'lfp',info,targslist,sigma_FR,1);
        [allstats]=get_allbehavstats(data,seltrials,targslist,'rpt');
     
        
        %save data
        newdata={};
        
        %% 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %analysis of trials for each target
        for tg=info.targ_tuning %targs_ind %[6:10],%info.targ_tuning%
        
            figtrials=figure('Position',[1 100 scrsz(3)-100 scrsz(4)-200]);
   
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %display all targets
            hdlfig=subplot(2,3,1);hold on;
            display_alltargets(targslist,info,hdlfig);
            
             %compute target tuning
             hdlfig=subplot(2,3,4);hold on;
             plot_targtuning(alltrials_spk_tuning,targs_ind,info,hdlfig,'Target tuning');
         
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %target index
            info.targ=tg;
               
            %%
            %%%%%%%%%%%%%%%%%%
            %spk
            trials_spk=alltrials_spk{tg};
            [info.nchannels info.ntrials info.triallen]=size(trials_spk);
            
            %compute average trials
            [trials_spk_avg trials_spk_var]=get_trials_avg(trials_spk);
                     
            %remove trials with amplitude that is too small
            [trials_spk_avgc index_spk_c]=clean_trials(trials_spk_avg,'fr');
            hdlfig=subplot(2,3,2);hold on;
            titlestr={info.datafile ; ['FR ' info.align ' t' num2str(info.targ) ' #trials:' num2str(info.ntrials)]};
            plot_trials(trials_spk_avgc,[],index_spk_c,shift_spk,[],[],info,hdlfig,titlestr,[],[]);
            %%
            %%%%%%%%%%%%%%%%%%
            %lfp
            trials_lfp=alltrials_lfp{tg};
            [info.nchannels info.ntrials info.triallen]=size(trials_lfp);
            
            
            %compute average trials
            [trials_lfp_avg trials_lfp_var]=get_trials_avg(trials_lfp);
            
            %remove trials with amplitude that is too small
            [trials_lfp_avgc index_lfp_c]=clean_trials(trials_lfp_avg,'lfp');
            hdlfig=subplot(2,3,5);hold on;
            titlestr='LFP';
            plot_trials(trials_lfp_avgc,[],index_lfp_c,shift_lfp,[],[],info,hdlfig,titlestr,[],[]);
            
            %%
            %%%%%%%%%%%%%%%%%%
            %plot CSD
            hdlfig=subplot(2,3,6);hold on;
            titlestr='CSD';
            plot_csdtrials(trials_lfp_avgc,index_lfp_c,[],[],[],info,hdlfig,titlestr);
            
            %%
            %%%%%%%%%%%%%%%%%%
            %behavioral stats
            stats_t=allstats{tg};
            hdlfig=subplot(2,3,3);hold on;
            titlestr='Behavioral stats';
            plot_behavstats(stats_t,info,hdlfig,titlestr);
            
            
            %%%%%%%%%%%%%%%%%%
            %save figs
            if savefigs
                saveas(figtrials,[save_path info.datafile '_' info.align '_t' num2str(info.targ) '.' figtype],figtype);
            end;
            
            %%
            %%%%%%%%%%%%%%%%%%
            %save data
            if savedata
                newdata{tg}.lfp=trials_lfp_avgc;
                newdata{tg}.fr=trials_spk_avgc;
                newdata{tg}.info=info;
            else
                d
                pause
            end
        end
        
        %save data
        if savedata
            save_data(newdata,root_path,newdata_dir,info);
        end
        
    end
    %close all
end



