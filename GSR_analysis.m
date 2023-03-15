% GSR信号的降采样-滤波-分解-特征提取过程
%% 读取数据文件

clear;clc;
pathphy = '../Physiol_Rec/1001';
filename = {'1000_1000_20210311101553_20210314120149_GSR.csv';
    '2000_2000_20210314140943_20210314160058_GSR.csv'};%读取GSR文件，包含GSR值和时间，这个例子这里是两个被试，所以读取了两个文件

for subid = 1:length(filename)%读到两个被试，赋予被试编号
    csvname_temp = fullfile( pathphy, filename{subid});
    [data_phy, t_phy, row_phy] = xlsread(csvname_temp, 1);%分别是数值，时间，数值加时间
    raw_data{subid} = resample(data_phy',10,40);  %数值这栏降采样40Hz至10Hz
end
save('raw_data.mat','raw_data');%两个被试的数据降采样之后的结果

%% 滤波处理

load raw_data.mat;
figure;

subplot(4,2,2);
plot(raw_data{2});
for subid = 1:length(raw_data)
    subplot(4,2,subid);plot(raw_data{subid});
    data_processed{subid} = smoothdata(raw_data{subid},'gaussian',8);%做滤波处理之后把图画在滤波前的图的下面，只是为了可视化，做完滤波就可以了，图可以不画
    subplot(4,2,subid+2);plot(data_processed{subid});
end
save('data_processed.mat','data_processed');

%%在这里例子用的是两个被试的数据，每个被试的测试中间不再做时间窗切分
%%我的数据希望只用一个被试的数据，但每五秒（不看视频时不算）做一个时间窗切分，但后续的特征提取过程是类似的

%% 分离SCL与SCR成分

load data_processed.mat;%两个被试滤波之后的数据
global leda2;
sample_rate = 10;

for subid = 1:length(data_processed)%两个被试
    gsr_o = data_processed{subid};
    data.conductance = gsr_o;
    data.time = (0:length(gsr_o)-1)/sample_rate;
    data.timeoff = 0;
    data.event = [];
    save('data.mat','data');
    Ledalab('..Physiol_Rec\Ledalab\data.mat','open','leda','analyze','CDA');
    %Ledalab('..\Ledalab\data.mat','open','mat','analyze','CDA');
    SCRs{subid} = leda2.analysis.phasicData;
    SCLs{subid} = leda2.analysis.tonicData;
    iSCR = cumsum(SCRs{subid});
    subplot(4,2,subid+4);plot(SCLs{subid});
    subplot(4,2,subid+6);plot(SCRs{subid});
    
    SCL_feature(subid,:) = [mean(SCLs{subid}),std(SCLs{subid})];%第一个特征
    iSCR_feature(subid,:) = [mean(iSCR),std(iSCR)];%第二个特征
end










