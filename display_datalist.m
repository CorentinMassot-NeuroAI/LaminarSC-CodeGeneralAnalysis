function display_datalist(datalist)

%function display_datalist(datalist
%  
%
%Corentin Pitt Pittsburgh 05/24/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% vshift=1;
% figure;hold on;
% for i=1:length(datalist)
%     1+vshift*i
%     ht=text(0.5,1+vshift*i,num2str(i));
%     set(ht,'Color','k','FontSize',10);
%     ht=text(1,1+vshift*i,datalist(i));
%     set(ht,'Color','k','FontSize',10);
% end
% axis([0 10 0 1+vshift*(i+1)]);
% axis off;



for i=1:length(datalist)
    display([num2str(i) datalist(i)]);
end
