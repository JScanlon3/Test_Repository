function [OO7_Base_Pin]=RG_Base(path_data,Subject_Number,Ramp_Angle)

Base_Exclude=[13,3;...
              14,2;...
              15,1];
for i=1:size(Base_Exclude,1)
    if Base_Exclude(i,1)==Subject_Number && Base_Exclude(i,2)==Ramp_Angle
        B_Exclude=1;
    end
end
if exist('B_Exclude')==0
    B_Exclude=0;
end

if B_Exclude==1
    OO7_Base_Pin=[0,0,0,0,0,0];
else
if Ramp_Angle==1
    filename=['Sub' num2str(Subject_Number) '_Base_0.CSV'];
elseif Ramp_Angle==2
    filename=['Sub' num2str(Subject_Number) '_Base_025.CSV'];
elseif Ramp_Angle==3
    filename=['Sub' num2str(Subject_Number) '_Base_05.CSV'];
    if Subject_Number==6
            filename=['Sub' num2str(Subject_Number) '_Base_5.CSV'];
    end

elseif Ramp_Angle==4
    filename=['Sub' num2str(Subject_Number) '_Base_10.CSV'];
elseif Ramp_Angle==5
    filename=['Sub' num2str(Subject_Number) '_Base_15.CSV'];
end

%Open file to be read
FID=fopen(fullfile(path_data,filename),'r');


if FID==-1 && Ramp_Angle==3
    filename=['Sub' num2str(Subject_Number) '_Base_5.CSV'];
    FID=fopen(fullfile(path_data,filename),'r');
end


if FID==-1
    disp(['Error: Baseline calibration trial does not exist for task ' num2str(Ramp_Angle)])
    pause
end

%Read the next 6 lines of the .csv (6th line marks force plate data point)
for i=1:6
    tline1=fgets(FID);
end

%% Force Plate Pin Voltage Data Extraction (OO7)
FPit=0;
while length(tline1)>2
    FPit=FPit+1;
    
    commaloc=strfind(tline1,',');
    
    %OO7 Extraction
    for i=1:6
        if i<6
            fpOO7(FPit,i)=str2double(tline1((commaloc(i+1)+1):(commaloc(i+2)-1)));
        else
            fpOO7(FPit,i)=str2double(tline1((commaloc(i+1)+1):length(tline1)));
        end
    end
    tline1=fgets(FID);%Get next line
end

fclose('all');
%% VICON Marker Extraction
%%% Extract each marker's position
% 
% %Skip the next 6 line of the .CSV file
% for i=1:6
%     tline1=fgets(FID);
% end
% 
% MPit=0;
% while length(tline1)>2
%     MPit=MPit+1;
%     
%     commaloc=strfind(tline1,',');
%     
%     %M1 Extraction
%     for i=1:33
%         if i==33
%             if commaloc(i+1)+1==length(tline1)
%                 MarkerPosition(MPit,i)=0;
%             else
%                 MarkerPosition(MPit,i)=str2double(tline1((commaloc(i+1)+1):length(tline1)));
%             end
%         else
%             if commaloc(i+1)+1==commaloc(i+2)
%                 MarkerPosition(MPit,i)=0;
%             else
%                 MarkerPosition(MPit,i)=str2double(tline1((commaloc(i+1)+1):(commaloc(i+2)-1)));
%             end
%         end
%     end
%     
%     tline1=fgets(FID);
% 
% end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Force Plate and Marker Filtration

%%%Filtration Coefficients%%% 
passes = 2; % Number of passes through filter (2 for zero-lag filter)
cbw = 1/((2^(1/passes)-1)^(1/4));   % correction factor
%Force Platform%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
intended_cutoff_fp = 7; % 7 Hz cutoff frequency
adjusted_cutoff_fp = cbw*intended_cutoff_fp;
samp_rate_fp = 1000;   % sampling freq (Hz)
order_fp = 4/2;      % order of filter (4th) %Note single pass of butter is order 2(why divided by 2)
%TOTAL ORDER AFTER FILTFILT is 4
cutoff_fp = adjusted_cutoff_fp/(samp_rate_fp/2);  % cutoff frequency with 1.0 corresponding to 1/2 sampling rate
[bfp,afp] = butter(order_fp,cutoff_fp);    % calculates filter coefficients
%Markers%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
intended_cutoff_m = 5; % 5 Hz cutoff frequency
adjusted_cutoff_m = cbw*intended_cutoff_m;
samp_rate_m = 100;   % sampling freq (Hz)
order_m = 4/2;      % order of filter (4th)
cutoff_m = adjusted_cutoff_m/(samp_rate_m/2);  % cutoff frequency with 1.0 corresponding to 1/2 sampling rate
[bm,am] = butter(order_m,cutoff_m);    % calculates filter coefficients
%%%Filter%%%
fpOO7 = filtfilt(bfp,afp,fpOO7);


OO7_Base_Pin=mean(fpOO7);
end
