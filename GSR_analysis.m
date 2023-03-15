% GSR�źŵĽ�����-�˲�-�ֽ�-������ȡ����
%% ��ȡ�����ļ�

clear;clc;
pathphy = '../Physiol_Rec/1001';
filename = {'1000_1000_20210311101553_20210314120149_GSR.csv';
    '2000_2000_20210314140943_20210314160058_GSR.csv'};%��ȡGSR�ļ�������GSRֵ��ʱ�䣬��������������������ԣ����Զ�ȡ�������ļ�

for subid = 1:length(filename)%�����������ԣ����豻�Ա��
    csvname_temp = fullfile( pathphy, filename{subid});
    [data_phy, t_phy, row_phy] = xlsread(csvname_temp, 1);%�ֱ�����ֵ��ʱ�䣬��ֵ��ʱ��
    raw_data{subid} = resample(data_phy',10,40);  %��ֵ����������40Hz��10Hz
end
save('raw_data.mat','raw_data');%�������Ե����ݽ�����֮��Ľ��

%% �˲�����

load raw_data.mat;
figure;

subplot(4,2,2);
plot(raw_data{2});
for subid = 1:length(raw_data)
    subplot(4,2,subid);plot(raw_data{subid});
    data_processed{subid} = smoothdata(raw_data{subid},'gaussian',8);%���˲�����֮���ͼ�����˲�ǰ��ͼ�����棬ֻ��Ϊ�˿��ӻ��������˲��Ϳ����ˣ�ͼ���Բ���
    subplot(4,2,subid+2);plot(data_processed{subid});
end
save('data_processed.mat','data_processed');

%%�����������õ����������Ե����ݣ�ÿ�����ԵĲ����м䲻����ʱ�䴰�з�
%%�ҵ�����ϣ��ֻ��һ�����Ե����ݣ���ÿ���루������Ƶʱ���㣩��һ��ʱ�䴰�з֣���������������ȡ���������Ƶ�

%% ����SCL��SCR�ɷ�

load data_processed.mat;%���������˲�֮�������
global leda2;
sample_rate = 10;

for subid = 1:length(data_processed)%��������
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
    
    SCL_feature(subid,:) = [mean(SCLs{subid}),std(SCLs{subid})];%��һ������
    iSCR_feature(subid,:) = [mean(iSCR),std(iSCR)];%�ڶ�������
end










