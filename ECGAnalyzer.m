[fileName, pathName] = uigetfile;
filePath = strcat(pathName,fileName);

samplingRate = input('Sampling Rate:'); %Sampling rate

load(filePath);
ecgSignal = val(1:1:samplingRate*5);
noOfSamples = 1:length(ecgSignal);
ecgSignal = ecgSignal./200;
signalTime =(0:length(ecgSignal)-1)/samplingRate; %To determine the total time

figure(1)
plot(signalTime,ecgSignal); %Plot ECG signal
xlabel('Time(s)'); ylabel('ECG (mV)');
title('Collected ECG')

%db8 filtering
waveletFunction = 'db8';
[C,L] = wavedec(ecgSignal,8,waveletFunction);

D1 = wrcoef('d',C,L,waveletFunction,1);
D2 = wrcoef('d',C,L,waveletFunction,2);
D3 = wrcoef('d',C,L,waveletFunction,3);
D4 = wrcoef('d',C,L,waveletFunction,4);
D5 = wrcoef('d',C,L,waveletFunction,5); 
D6 = wrcoef('d',C,L,waveletFunction,6); 
D7 = wrcoef('d',C,L,waveletFunction,7); 
D8 = wrcoef('d',C,L,waveletFunction,8);


filteredEcg = D4+D5+D6+D7;
ecgNoise = D1+D2+D8;

%Peak Detection Using Symlet
waveletSym = modwt(ecgSignal,4,'sym4');
waveletRec = zeros(size(waveletSym));
waveletRec(3:4,:) = waveletSym(3:4,:);

peakData = imodwt(waveletRec,'sym4');
peakData = abs(peakData).^2;
avg = mean(peakData);
[Rpeaks, locs] = findpeaks(peakData,noOfSamples,'MinPeakHeight',avg*8,'MinPeakDistance',50);

numOfBeats = length(locs);
timeLimit = length(ecgSignal)/samplingRate;
heartRate = (numOfBeats*60)/timeLimit;
disp(int8(heartRate));
ecgSNR = db(snr(filteredEcg, ecgNoise));

figure(2);

plot(signalTime, filteredEcg)
hold on
plot(locs./samplingRate,Rpeaks.*0,'r*')
xlabel('Time(s)'); ylabel('ECG (mV)');
title('Filtered ECG')







