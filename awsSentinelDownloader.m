% Sentinel-2 image finder and downloader from map selection
%
% Written by Kaan Kalkan, Istanbul Technical University, 2017


    urlwrite('https://storage.googleapis.com/gcp-public-data-sentinel-2/index.csv.gz','index.gz');
    gunzip('*.gz');
    T = readtable('index'); %scene_list'i oku
    T.SENSING_TIME = []; T.TOTAL_SIZE = []; T.GEOMETRIC_QUALITY_FLAG = [] ;T.GENERATION_TIME = []; 
    cclimit = 50; %delete cloud cover bigger than 50
    index1 = T.CLOUD_COVER>cclimit;
    T(index1,:) = [];

lat = [37 42];
   lon = [25 45];
   plot(lon,lat,'.','MarkerSize',1)
   plot_google_map
   title('zoom and press space');

pause; %Pause for zoom in

[selected_lon,selected_lat] = ginput(1); %Coordinates of click

%% Find Sentinels
    index2 = T.NORTH_LAT>selected_lat & T.SOUTH_LAT <selected_lat ;
    T(~index2,:) = [];
        index3 = T.EAST_LON>selected_lon & T.WEST_LON <selected_lon ;
    T(~index3,:) = [];

close all;

%% select main image from list of images from sentinel list for given path-row
T = sortrows(T,3);
T2 = table2cell(T);
for i=1:size(T2,1);
    str2{i} = [T2{i,3}(6:13), ' --> CC: ', num2str(T2{i,5})];
    T2{i,11} = ['https://storage.googleapis.com/gcp-public-data-sentinel-2/tiles', T2{i,10}(38:111)];
end
[selection,v] = listdlg('PromptString','Select a scene:',...
    'SelectionMode','single','ListSize', [200 400],...
    'ListString',str2);
mainimageid = T2{selection,3};
% xmlPath = ['https://storage.googleapis.com/gcp-public-data-sentinel-2/tiles', T2{selection,10}(38:111), '/',  T2{selection,2}, '.xml'];
% urlwrite(xmlPath, [T2{selection,2}, '.xml']);
% web(T2{selection,11});

imagePreUrl = [T2{selection,11}, '/GRANULE', '/', T2{selection,1}, '/IMG_DATA/', T2{selection,1}(1:56)];

bands = {'01 - Coastal', '02 - Blue', '03 - Green','04 - Red','05 - RE1','06 - RE2','07 - RE3','08 - NIR','09 - WV','10 - Cirrus','11 - SWIR1','12 - SWIR2'};
[bandList,v] = listdlg('PromptString','Select bands:',...
    'ListString',bands);

numselected = size(bandList,2);
disp('Downloading');
for i = 1:numselected % read selected bands and write
    if bandList(i) < 10;
        urlwrite([imagePreUrl, 'B0' , num2str(bandList(i)), '.jp2'], [T2{selection,1}(1:56), 'B0' , num2str(bandList(i)), '.jp2']);
    else
                urlwrite([imagePreUrl, 'B', num2str(bandList(i)), '.jp2'], [T2{selection,1}(1:56), 'B', num2str(bandList(i)), '.jp2'] );
    end
end



