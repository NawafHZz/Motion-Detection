function varargout = detect(varargin)
% DETECT MATLAB code for detect.fig
%      DETECT, by itself, creates a new DETECT or raises the existing
%      singleton*.
%
%      H = DETECT returns the handle to a new DETECT or the handle to
%      the existing singleton*.
%
%      DETECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DETECT.M with the given input arguments.
%
%      DETECT('Property','Value',...) creates a new DETECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before detect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to detect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help detect

% Last Modified by GUIDE v2.5 29-Apr-2018 13:06:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @detect_OpeningFcn, ...
                   'gui_OutputFcn',  @detect_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before detect is made visible.
function detect_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
global vid
axes(handles.axes1);
vid=videoinput('winvideo',1,'YUY2_640x480');
set(vid,'ReturnedColorSpace','rgb');                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
triggerconfig(vid,'manual');
set(vid,'FramesPerTrigger',1 );
set(vid,'TriggerRepeat', Inf);
himage=image(zeros(480,640,3),'parent',handles.axes1);
preview(vid,himage);

% Update handles structure
guidata(hObject, handles);
% --- Outputs from this function are returned to the command line.
function varargout = detect_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)

global popSwitch
global vid
start(vid);
frame=1;
%Infinite while loop
Out=[];
while(1)
    if popSwitch == 2
        trigger(vid);
        %Get Image
        im=getdata(vid,1);
        if frame == 5
            red=im(:,:,1);
            Green=im(:,:,2);
            Blue=im(:,:,3);
            Out(:,:,1)=red;
            Out(:,:,2)=Green;
            Out(:,:,3)=Blue;
            Out=uint8(Out);
        end

        if frame > 5
            red=im(:,:,1);
            Green=im(:,:,2);
            Blue=im(:,:,3);
            red1=Out(:,:,1);
            Green1=Out(:,:,2);
            Blue1=Out(:,:,3);
            redDiff = imabsdiff(red,red1);     %get absolute diffrence between both images
            greenDiff = imabsdiff(Green,Green1); %get absolute diffrence between both images
            blueDiff = imabsdiff(Blue,Blue1);   %get absolute diffrence between both images
            redSumRow= sum(redDiff,1);               %calculate SAD
            greenSumRow= sum(greenDiff,1);               %calculate SAD
            blueSumRow= sum(blueDiff,1);               %calculate SAD
            redSAD= sum(redSumRow)/ 307200;
            greenSAD= sum(greenSumRow)/ 307200;
            blueSAD= sum(blueSumRow)/ 307200;
            Final=(redSAD+greenSAD+blueSAD)/3;
            disp(Final);
            if Final > 9
                set(handles.text2,'String','Change Detected')  
            else
                set(handles.text2,'String','No Change')
            end 
        end
    elseif popSwitch == 3 
        trigger(vid);
        data = getdata(vid,1);

        % Now to track red objects in real time
        % we have to subtract the red component 
        % from the grayscale image to extract the red components in the image.
        diff_im = imsubtract(data(:,:,1), rgb2gray(data));
        %Use a median filter to filter out noise
        diff_im = medfilt2(diff_im, [3 3]);
        % Convert the resulting grayscale image into a binary image.
        diff_im = im2bw(diff_im,0.24);

        % Remove all those pixels less than 300px
        diff_im = bwareaopen(diff_im,300);

        % Label all the connected components in the image.
        bw = bwlabel(diff_im, 8);

        % Here we do the image blob analysis.
        % We get a set of properties for each labeled region.
        stats = regionprops(bw, 'BoundingBox', 'Centroid');

        if length(stats) > 0
            num = length(stats);
            x = ['Number of Red object is: ',num2str(num)];
            set(handles.text2,'String',x)
        else
            set(handles.text2,'String','Number of Red object is: 0')
        end
        % Display the image
        imshow(data)

        hold on

        %This is a loop to bound the red objects in a rectangular box.
        for object = 1:length(stats)
            bb = stats(object).BoundingBox;
            bc = stats(object).Centroid;
            rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
            plot(bc(1),bc(2), '-m+')
            a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
            set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
        end

        hold off
    elseif popSwitch == 4
        trigger(vid);
        data = getdata(vid,1);

        % Now to track Green objects in real time
        % we have to subtract the red component 
        % from the grayscale image to extract the red components in the image.
        diff_im = imsubtract(data(:,:,2), rgb2gray(data));
        %Use a median filter to filter out noise
        diff_im = medfilt2(diff_im, [3 3]);
        % Convert the resulting grayscale image into a binary image.
        diff_im = im2bw(diff_im,0.02);

        % Remove all those pixels less than 300px
        diff_im = bwareaopen(diff_im,300);

        % Label all the connected components in the image.
        bw = bwlabel(diff_im, 8);

        % Here we do the image blob analysis.
        % We get a set of properties for each labeled region.
        stats = regionprops(bw, 'BoundingBox', 'Centroid');

        if length(stats) > 0
            num = length(stats);
            x = ['Number of Green object is: ',num2str(num)];
            set(handles.text2,'String',x)
        else
            set(handles.text2,'String','Number of Green object is: 0')
        end

        % Display the image
        imshow(data)

        hold on

        %This is a loop to bound the red objects in a rectangular box.
        for object = 1:length(stats)
            bb = stats(object).BoundingBox;
            bc = stats(object).Centroid;
            rectangle('Position',bb,'EdgeColor','g','LineWidth',2)
            plot(bc(1),bc(2), '-m+')
            a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
            set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
        end

        hold off
    elseif popSwitch == 5
        trigger(vid);
        data = getdata(vid,1);

        % Now to track Blue objects in real time
        % we have to subtract the red component 
        % from the grayscale image to extract the red components in the image.
        diff_im = imsubtract(data(:,:,3), rgb2gray(data));
        %Use a median filter to filter out noise
        diff_im = medfilt2(diff_im, [3 3]);
        % Convert the resulting grayscale image into a binary image.
        diff_im = im2bw(diff_im,0.2);

        % Remove all those pixels less than 300px
        diff_im = bwareaopen(diff_im,300);

        % Label all the connected components in the image.
        bw = bwlabel(diff_im, 8);

        % Here we do the image blob analysis.
        % We get a set of properties for each labeled region.
        stats = regionprops(bw, 'BoundingBox', 'Centroid');

        if length(stats) > 0
            num = length(stats);
            x = ['Number of Blue object is: ',num2str(num)];
            set(handles.text2,'String',x)
        else
            set(handles.text2,'String','Number of Blue object is: 0')
        end
        % Display the image
        imshow(data)

        hold on

        %This is a loop to bound the red objects in a rectangular box.
        for object = 1:length(stats)
            bb = stats(object).BoundingBox;
            bc = stats(object).Centroid;
            rectangle('Position',bb,'EdgeColor','b','LineWidth',2)
            plot(bc(1),bc(2), '-m+')

            a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
            set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
        end

        hold off
    end
    disp(frame);
    frame=frame+1;
    if frame == 1500
        break
    end
end


% --- Executes on button press in stop.
function stop_Callback(hObject, eventdata, handles)
global vid
stop(vid);
flushdata(vid);
clear all;
close all


% --- Executes on selection change in popupmenu.
function popupmenu_Callback(hObject, eventdata, handles)
global popSwitch
sw = get(handles.popupmenu,'value');
popSwitch = sw;
assignin('base','popSwitch',sw);

% --- Executes during object creation, after setting all properties.
function popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
