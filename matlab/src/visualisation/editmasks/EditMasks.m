function varargout = EditMasks(varargin)
% EDITMASKS MATLAB code for EditMasks.fig
%      EDITMASKS, by itself, creates a new EDITMASKS or raises the existing
%      singleton*.
%
%      H = EDITMASKS returns the handle to a new EDITMASKS or the handle to
%      the existing singleton*.
%
%      EDITMASKS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITMASKS.M with the given input arguments.
%
%      EDITMASKS('Property','Value',...) creates a new EDITMASKS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EditMasks_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EditMasks_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EditMasks

% Last Modified by GUIDE v2.5 25-Nov-2015 11:22:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
  'gui_Singleton',  gui_Singleton, ...
  'gui_OpeningFcn', @EditMasks_OpeningFcn, ...
  'gui_OutputFcn',  @EditMasks_OutputFcn, ...
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


% --- Executes just before EditMasks is made visible.
function EditMasks_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EditMasks (see VARARGIN)

% Choose default command line output for EditMasks
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EditMasks wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EditMasks_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in OpenFolder.
function OpenFolder_Callback(hObject, eventdata, handles)
% hObject    handle to OpenFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.folder = uigetdir('/home/arash/Software/Repositories/neurobit/data/dataset/ColourNameDataset/ebay/cars/black/');  %store the selected folder in handles.folder;
files = dir(fullfile(handles.folder,'*jpg')); %get all png files
for i = 1:length(files)
  piclist{i} = files(i).name; %lists each of them in a cell
end
if ~isempty(piclist)
  set(handles.ImageList, 'String', piclist); %display them in the list box.
end
guidata(hObject, handles); %update the gui to save handles


% --- Executes on selection change in ImageList.
function ImageList_Callback(hObject, eventdata, handles)
% hObject    handle to ImageList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImageList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImageList

axis off;
hold off;

list = get(handles.ImageList,'string'); %get the picture list
selected = get(handles.ImageList,'value'); % get which one is selected.
axes(handles.ImageAxes);

ImagePath = fullfile(handles.folder,cell2mat(list(selected)));
global OriginalImage;
OriginalImage = imread(ImagePath); %open the picture
imshow(OriginalImage); %display image.

MaskPath = [ImagePath(1:end-4), '_MASK.png'];
global MaskImage;
MaskImage = double(imread(MaskPath)); %open the mask
h = ShowMaskAsOverlay(0.3, MaskImage);

set(h, 'ButtonDownFcn', @Mask_ButtonDownFcn);


function Mask_ButtonDownFcn(hObject, ~)

axis off;
hold off;

h = get(hObject,'Parent');
p = get(h, 'CurrentPoint');

selected = round(p(1, 2:-1:1));

rowsv = get(hObject, 'YData');
rows = rowsv(2);
colsv = get(hObject, 'XData');
cols = colsv(2);

if selected(1) > rows
  selected(1) = rows;
end

if selected(2) > cols
  selected(2) = cols;
end

global OriginalImage;
global MaskImage;

r1 = max(selected(1) - 5, 1);
r2 = min(selected(1) + 5, rows);
c1 = max(selected(2) - 5, 1);
c2 = min(selected(2) + 5, cols);

MaskImage(r1:r2, c1:c2, :) = 0;

imshow(OriginalImage); %display image.
h = ShowMaskAsOverlay(0.3, MaskImage);

set(h, 'ButtonDownFcn', @Mask_ButtonDownFcn);


% --- Executes during object creation, after setting all properties.
function ImageList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function ImageAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate ImageAxes

axis off;
