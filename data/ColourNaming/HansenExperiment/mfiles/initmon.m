function initmon(initfile, verbose)
%INITMON  Initializes DKL<-->RGB conversion matrices
%   INITMON(INITFILE) initializes DKL<-->RGB conversion matrices for the
%   CIE xyY coordinates of monitor phosphors given in INITFILE.
%
%   INITMON without arguments uses default xyY values to initialize the
%   conversion matrices.
%
%   Function INITMON must be called once prior to subsequent calls of
%   conversion routines DKL2RGB or RGB2DKL.
%
%   See also DKL2RGB, RGB2DKL.
%
%Thorsten Hansen 2003-06-23

if nargin < 2
  verbose = 0;
end

% define xyY monitor coordinates
if nargin == 0 % use default init file 'sony-th.xyY' from directory
  % '/home/hansen/bib/data/lut/sony-th.xyY';
  % notch: initmon('/home/hansen/bib/data/lut/barco12.xyY')
  if verbose
    disp(['Initialize M_dkl2rgb and M_rgb2dkl from default values.'])
  end
  
  moncie = [0.6165 0.3502 14.4499
0.2824 0.6095 39.7539
0.1531 0.0788 4.3940];
  global default_gmap
  default_gmap = defaultgammamap;
  % colormap(defaultgammamap); % set gamma correction map
else
  % file format of xyY monitor coordinates
  % xyY coordinates of (r,g,b) monitor phospors and neutral gray point n
  % file format:
  %
  %   rx ry rY
  %   gx gy gY
  %   bx by bY
  %   nx ny nY <- neutral gray???
  
  if ~isempty(strfind(initfile, '.xyY'))...
      || ~isempty(strfind(initfile, '.xyy'))
    if exist(initfile)
      moncie = textread(initfile);
    else
      error(['Cannot open ' initfile '.xyY nor ' initfile '.xyy'])
    end
  else
    if exist([initfile '.xyY'])
      moncie = textread([initfile '.xyY']);
      if verbose
        disp(['Initialize M_dkl2rgb and M_rgb2dkl from ''' ...
          initfile 'xyY.'''])
      end
    elseif exist([initfile '.xyy'])
      moncie = textread([initfile '.xyy']);
      if verbose
        disp(['Initialize M_dkl2rgb and M_rgb2dkl from ''' ...
          initfile 'xyy.'''])
      end
    else
      error(['Cannot open ' initfile '.xyY nor ' initfile '.xyy'])
    end
  end
  if (size(moncie,1) < 3) | (size(moncie,2) < 3)
    error(['Error reading file ''' initfile ...
      ''': must be at least 3x3 matrix.'])
  end
  
  if exist([initfile '.lut'])
    RGB =  textread([initfile '.lut']);
    global default_gmap
    default_gmap = [RGB]/255;
  elseif exist([initfile '.r']) && exist([initfile '.g']) && exist([initfile '.g'])
    % read gamma tables
    R = textread([initfile '.r']);
    G = textread([initfile '.g']);
    B = textread([initfile '.b']);
    global default_gmap
    default_gmap = [R G B]/255;
  else
    disp('No gamma tables found.')
  end
  if verbose
    disp(['Initialize gamma map from ''' initfile '.(r|g|b)'''])
  end
end
global global_moncie
global_moncie = moncie;


% initialize conversion matrices M_dkl2rgb and M_rgb2dkl
% from monitor coordinates moncie
global M_dkl2rgb M_rgb2dkl

moncie = moncie(1:3,:); % fourth line not needed
M_dkl2rgb = getdkl(moncie);
M_rgb2dkl = inv(M_dkl2rgb);

%
% initialize conversion matrices M_rgb2lms and M_lms2rgb
%
global M_rgb2lms M_lms2rgb


% TEST: new vectorized implementation
monxyY = moncie;
x = monxyY(:,1); y = monxyY(:,2); Y = monxyY(:,3);

if prod(y) == 0, error('y column contains zero value.'), end
z = 1-x-y;
monxyz = [x y z];

white = Y/2;

X = x./y.*Y;
Z = z./y.*Y;
monXYZ = [X Y Z]; % this should be monCIE
% end TEST


monCIE = zeros(3,3);
monCIE(:,2) = moncie(1:3,3);

for i=1:3
  moncie(i,3) = 1.0 - moncie(i,1) - moncie(i,2);
  monCIE(i,1) = (moncie(i,1)/moncie(i,2))*monCIE(i,2);
  monCIE(i,3) = (moncie(i,3)/moncie(i,2))*monCIE(i,2);
  monRGB(i,1) = 0.15514 * monCIE(i,1) + ...
    0.54313 * monCIE(i,2) - 0.03386 * monCIE(i,3);
  monRGB(i,2) = -0.15514 * monCIE(i,1) + ...
    0.45684 * monCIE(i,2) + 0.03386 * monCIE(i,3);
  monRGB(i,3) = 0.01608 * monCIE(i,3);
  tsum = monRGB(i,1) + monRGB(i,2);
  monrgb(i,1) = monRGB(i,1) / tsum;
  monrgb(i,2) = monRGB(i,2) / tsum;
  monrgb(i,3) = monRGB(i,3) / tsum;
end

Xmon = monCIE; % who needs Xmon?

Xmat= inv(Xmon); % who needs Xmat?

M_rgb2lms = monRGB; % M_rgb2lms used in mon2cones
% why not directly compute on M_rgb2lms ?

M_lms2rgb = inv(M_rgb2lms);

% white point
%w = mon2cones(0.5, 0.5, 0.5);
w = [0.5 0.5 0.5] * M_rgb2lms; % who needs this?

end

%------------------------------------------------------------------------------
function M_dkl2rgb = getdkl(monxyY)
%------------------------------------------------------------------------------
% compute dkl2rgb conversion matrix from moncie coordinates
% (compare function "getdkl" in color.c)

x = monxyY(:,1); y = monxyY(:,2); Y = monxyY(:,3);
if prod(y) == 0, error('y column contains zero value.'), end
xyz = [x y 1-x-y];
white = Y/2;

% Smith & Pokorny cone fundamentals
% V. C. Smith & J. Pokorny (1975), Vision Res. 15, 161-172.
M = [ 0.15514  0.54312  -0.03286
  -0.15514  0.45684   0.03286
  0.0      0.0       0.01608];

RGB = xyz*M'; % R, G  and B cones (i.e, long, middle and short wavelength)



% different computation of RGB that results in the same M_dkl2rgb matrix
% RGB = xyY2XYZ(monxyY')'*M'

% check
% RGB = xyz*M';
% RGBnew = xyY2XYZ(monxyY')'*M'
%%RGBnew ./ RGB;

do_some_checks = 0;
if do_some_checks
  
  %RGB_check = (M*xyz')';
  
  XYZ2xyY(((xyY2XYZ(monxyY(1:2,:)')')*M')')
  
  x_R = x(1); y_R = y(1); Y_R = Y(1);
  z_R = 1-x_R-y_R;
  X_R = x_R./y_R.*Y_R;
  Z_R = z_R./y_R.*Y_R;
  XYZ_R = [X_R; Y_R; Z_R]
  
  LMS_R = M*XYZ_R;
  
  
  % M*xyY2XYZ(monxyY')
  
  LMS_correct = ((xyY2XYZ(monxyY(1:2,:)'))'*M')'
  
  %LMS_2 = XYZ2xyY(M*xyY2XYZ(monxyY')')
  %LMS_3 = XYZ2xyY(M'*xyY2XYZ(monxyY'))
  %LMS_4 = XYZ2xyY(M'*xyY2XYZ(monxyY')')
  
  %LMS_check = XYZ2xyY(xyY2XYZ(monxyY)*diag(3))
end


RG_sum = RGB(:,1) + RGB(:,2); % R G sum
R = RGB(:,1)./RG_sum;
B = RGB(:,3)./RG_sum;
G = 1 - R;

% alternative implementation of last 4 lines
%RGB = RGB./repmat(RGB(:,1) + RGB(:,2), 1, 3);
%R = RGB(:,1); G = RGB(:,2); B = RGB(:, 3);

% constant blue axis
a = white(1)*B(1);
b = white(1)*(R(1)+G(1));
c = B(2);
d = B(3);
e = R(2)+G(2);
f = R(3)+G(3);
dGcb = (a*f/d - b)/(c*f/d - e); % solve x
dBcb = (a*e/c - b)/(d*e/c - f); % solve y

% tritanopic confusion axis
a = white(3)*R(3);
b = white(3)*G(3);
c = R(1);
d = R(2);
e = G(1);
f = G(2);
dRtc = (a*f/d - b)/(c*f/d - e); % solve x
dGtc = (a*e/c - b)/(d*e/c - f); % solve y

IMAX = 1;
M_dkl2rgb = IMAX * [1        1         dRtc/white(1)
  1  -dGcb/white(2)  dGtc/white(2)
  1  -dBcb/white(3)     -1];


%M_dkl2rgb = IMAX * [1  1  0
%                    1  0  0
%                    1  0 -1]

end

%------------------------------------------------------------------------------
function gmap = defaultgammamap()
%------------------------------------------------------------------------------
% from r,g,b = textread('/home/hansen/bib/data/lut/sony-th.r,g,b')
gmap = ...
  [  1     1     2
  10    11    13
  17    18    20
  23    23    26
  28    28    31
  32    32    35
  36    36    39
  39    40    43
  43    43    46
  46    46    50
  49    49    52
  51    52    55
  54    54    58
  57    57    60
  59    59    63
  61    61    65
  64    64    67
  66    66    69
  68    68    71
  70    70    73
  72    72    75
  74    74    77
  76    75    79
  77    77    81
  79    79    83
  81    81    84
  83    82    86
  84    84    88
  86    86    89
  87    87    91
  89    89    92
  91    90    94
  92    92    95
  93    93    97
  95    95    98
  96    96   100
  98    97   101
  99    99   102
  101   100   104
  102   101   105
  103   103   106
  104   104   108
  106   105   109
  107   107   110
  108   108   111
  110   109   113
  111   110   114
  112   111   115
  113   113   116
  114   114   117
  116   115   118
  117   116   119
  118   117   121
  119   118   122
  120   119   123
  121   120   124
  122   122   125
  123   123   126
  124   124   127
  125   125   128
  127   126   129
  128   127   130
  129   128   131
  130   129   132
  131   130   133
  132   131   134
  133   132   135
  134   133   136
  135   134   137
  136   135   138
  137   136   139
  137   137   140
  138   138   141
  139   139   142
  140   139   142
  141   140   143
  142   141   144
  143   142   145
  144   143   146
  145   144   147
  146   145   148
  147   146   149
  148   147   149
  148   147   150
  149   148   151
  150   149   152
  151   150   153
  152   151   154
  153   152   155
  154   153   155
  154   153   156
  155   154   157
  156   155   158
  157   156   159
  158   157   159
  158   158   160
  159   158   161
  160   159   162
  161   160   162
  162   161   163
  162   162   164
  163   162   165
  164   163   166
  165   164   166
  166   165   167
  166   165   168
  167   166   169
  168   167   169
  169   168   170
  169   168   171
  170   169   171
  171   170   172
  172   171   173
  172   171   174
  173   172   174
  174   173   175
  175   174   176
  175   174   176
  176   175   177
  177   176   178
  177   176   179
  178   177   179
  179   178   180
  180   179   181
  180   179   181
  181   180   182
  182   181   183
  182   181   183
  183   182   184
  184   183   185
  184   183   185
  185   184   186
  186   185   187
  186   185   187
  187   186   188
  188   187   189
  188   187   189
  189   188   190
  190   189   191
  190   189   191
  191   190   192
  192   191   193
  192   191   193
  193   192   194
  194   193   194
  194   193   195
  195   194   196
  196   195   196
  196   195   197
  197   196   198
  197   197   198
  198   197   199
  199   198   199
  199   198   200
  200   199   201
  201   200   201
  201   200   202
  202   201   202
  202   202   203
  203   202   204
  204   203   204
  204   203   205
  205   204   205
  205   205   206
  206   205   207
  207   206   207
  207   206   208
  208   207   208
  208   208   209
  209   208   210
  210   209   210
  210   209   211
  211   210   211
  211   211   212
  212   211   212
  213   212   213
  213   212   214
  214   213   214
  214   214   215
  215   214   215
  215   215   216
  216   215   216
  217   216   217
  217   216   218
  218   217   218
  218   218   219
  219   218   219
  219   219   220
  220   219   220
  220   220   221
  221   220   221
  222   221   222
  222   222   222
  223   222   223
  223   223   224
  224   223   224
  224   224   225
  225   224   225
  225   225   226
  226   225   226
  226   226   227
  227   227   227
  228   227   228
  228   228   228
  229   228   229
  229   229   229
  230   229   230
  230   230   231
  231   230   231
  231   231   232
  232   231   232
  232   232   233
  233   232   233
  233   233   234
  234   234   234
  234   234   235
  235   235   235
  235   235   236
  236   236   236
  236   236   237
  237   237   237
  238   237   238
  238   238   238
  239   238   239
  239   239   239
  240   239   240
  240   240   240
  241   240   241
  241   241   241
  242   241   242
  242   242   242
  243   242   243
  243   243   243
  244   243   244
  244   244   244
  245   244   245
  245   245   245
  246   245   246
  246   246   246
  247   246   247
  247   247   247
  248   247   248
  248   248   248
  249   249   249
  249   249   249
  249   250   250
  250   250   250
  250   251   251
  251   251   251
  251   252   252
  252   252   252
  252   252   253
  253   253   253
  253   253   254
  254   254   254
  254   254   255]/255;

end
