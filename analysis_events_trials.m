%function analysis_events_trials

%function analysis_events_trials
%   Analysis of data trial-by-trial recorded with a laminar probe (LMA)
%
% Corentin Massot
% Cognition and Sensorimotor Integration Lab, Neeraj J. Gandhi
% University of Pittsburgh
% created 07/29/2016 last modified 01/09/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%set paths
[root_path data_path save_path]=set_paths;

%screen size
scrsz = get(groot,'ScreenSize');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%parameters
%print figures and save data
savefigs=0;
figtype='epsc2';%'png';%'epsc2';

%alignement
%alignlist={'no' 'targ' 'go' 'sacc'};
alignlist={'sacc'};

%window of analysis
%wind=[];%all
%wind=[0 600];%targ align
wind=[-400 200];%sacc align


%window of burst
windb=[30 200];

%sigma FR
sigma_FR=6;

%vshift
%vshift_fr=150;
%vshift_lfp=30;


%newdata directory
savedata=0;
newdata_dir='Data_SC\';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%get data
datalist=load_data_gandhilab(data_path);

%colorlist
colorlist=get_colorlist;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%analyzing data
dlist=get_dlist;

data=[];
info=[];
for d=dlist
    
    %get data and info
    clear('data');
    info.datafile=datalist{d};
    load ([data_path info.datafile]);
    display(info.datafile)
    
    %getting channel mapping and discard selected bad channels
    [info.chmap info.nchannels info.depths]=get_chmap(data(1).info.electrode{2},[]);
    %getting trial type
    info.trialtype=data(1).sequence(1);
    %getting list of targets
    targslist=data(1).offline.targslist;
    %targets index
    targs_ind=get_targsindex(targslist,info);
    
    %target tuning (after compute_tuning)
    info.targ_tuning=data(1).offline.targ_tuning;
    
    %select trials
    seltrials=get_seltrials(data,'rpt');
    
    
    %loop across all alignements
    for al=1:numel(alignlist)
        info.align=alignlist{al};
        %[alltrials_lfp ~]=get_alltrials_align(data,seltrials,wind,'lfp',info,targslist,sigma_FR,1);
        %correct for shift introduced by ripple filtering
        [alltrials_lfp ~]=get_alltrials_align(data,seltrials,wind+4,'lfp',info,targslist,sigma_FR,1);
        
        %get all neural and behavioral data with specific alignement
        [alltrials_fr_tuning ~]=get_alltrials_align(data,seltrials,[],'fr',info,targslist,sigma_FR,1);
        [alltrials_fr info.aligntime]=get_alltrials_align(data,seltrials,wind,'fr',info,targslist,sigma_FR,1);
        [alltrials_spk ~]=get_alltrials_align(data,seltrials,wind,'spk',info,targslist,sigma_FR,1);
        
        
        [allgazepos,allevents]=get_alldatagaze_align(data,seltrials,info,targslist);
        
        %save data
        newdata=cell(1,length(targslist));
        
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %analysis of trials for each target
        for tg=info.targ_tuning;%targs_ind,
            %target index
            info.targ=tg;
            
            %neural and behavioral signals for target tg
            trials_fr=alltrials_fr{tg};
            [info.nchannels,info.ntrials,info.triallen]=size(trials_fr);
            trials_lfp=alltrials_lfp{tg};
            %[info.nchannels,info.ntrials,info.triallen]=size(trials_lfp);
            trials_spk=alltrials_spk{tg};
            
            gazepos=allgazepos{tg};
            events=allevents{tg};
            
            %loop on trials
            for t=1:info.ntrials,
                
                figtrials=figure('Position',[1 100 scrsz(3)-100 scrsz(4)-200]);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %display all targets
                hdlfig=subplot(2,3,1);hold on;
                display_alltargets(targslist,info,hdlfig);
                
                %compute target tuning
                hdlfig=subplot(2,3,3);hold on;
                plot_targtuning(alltrials_fr_tuning,targs_ind,info,hdlfig,'Target tuning');
                
                
                %%
                %%%%%%%%%%%%%%%%%%
                %gaze data
                gazepos_t=gazepos{t};
                events_t=events{t};
                event_align=get_eventalign(events_t,info.align);
                
                if ~isempty(event_align)
                    
                    hdlfig1=subplot(2,3,1);hold on;
                    hdlfig2=subplot(2,3,4);hold on;
                    
                    %%
                    %%%%%%%%%%%%%%%%%%
                    %gaze data
                    plot_gazedata(gazepos_t,events_t,event_align,wind,info,hdlfig1,'',hdlfig2,'XY Eye Traces');
                    ax=axis;
                    axis([ax(1) ax(2) -4 4]);
                    
                    %%
                    %%%%%%%%%%%%%%%%%%
                    %spk
                    trials_fr_t=squeeze(trials_fr(:,t,:));
                    %remove trials with amplitude that is too small
                    [trials_fr_tc index_fr_tc]=clean_trials(trials_fr_t,'fr');
                    hdlfig=subplot(2,3,2);hold on;
                    titlestr={info.datafile ; ['FR ' info.align ' t' num2str(info.targ) ' trial:' num2str(t) '/' num2str(info.ntrials)]};
                    plot_trials(trials_fr_tc,[],index_fr_tc,[],events_t,event_align,info,hdlfig,titlestr,[],[]);
                    
                    
                    %%%%%%%%%%%%%%%%%%
                    %lfp
                    trials_lfp_t=squeeze(trials_lfp(:,t,:));
                    %remove trials with amplitude that is too small
                    [trials_lfp_tc index_lfp_tc]=clean_trials(trials_lfp_t,'lfp');
                    hdlfig=subplot(2,3,5);hold on;
                    titlestr='LFP';
                    plot_trials(trials_lfp_tc,[],index_lfp_tc,[],events_t,event_align,info,hdlfig,titlestr,[],[]);
                    
                    %%
                    %%%%%%%%%%%%%%%%%%
                    %plot CSD
                    hdlfig=subplot(2,3,6);hold on;
                    titlestr='CSD';
                    plot_csdtrials(trials_lfp_tc,index_lfp_tc,events_t,event_align,[],info,hdlfig,titlestr);
                    
                    
                end
                
                %%%%%%%%%%%%%%%%%%
                %save figs
                if savefigs==1
                    saveas(figtrials,[save_path info.datafile '_' info.align '_t' num2str(info.targ) '_trial' num2str(t) '.' figtype],figtype);
                end;
                
                
                pause
                close(figtrials)
            end
            
            %%%%%%%%%%%%%%%%%%
            %save data
            if savedata
                newdata{tg}.lfp=trials_lfp;
                newdata{tg}.fr=trials_fr;
                newdata{tg}.info=info;
            else
                %pause
                %close(figtrials)
            end
            
        end
        if savedata
            save_data(newdata,root_path,newdata_dir,info);
        end
    end
end
