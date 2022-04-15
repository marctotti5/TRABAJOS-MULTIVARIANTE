
function fig_h = plot_scatter(bdata,elabel,classes,xylabel,lcont,opt,mult,maxv,blur)

% Scatter plot.
%
% plot_scatter(bdata) % minimum call
% plot_scatter(bdata,elabel,classes,xylabel,lcont,0) % plot without multiplicity
% fig_h = plot_scatter(bdata,elabel,classes,xylabel,lcont,opt,mult,maxv,blur) % complete call
%
%
% INPUTS:
%
% bdata: (Nx2) bidimensional data to plot. 
%
% elabel: [Nx1] name of the elements (numbers are used by default)
%
% classes: [Nx1, str(N), {N}] groups for different visualization (a single 
%   group by default)
%
% xylabel: {2} xlabel and ylabel (nothing by default)
%
% lcont: {2} control limits on x and y axis (nothing by default)
%
% opt: (str or num) options for data plotting: binary code of the form 'ab' for:
%       a:
%           0: do not plot multiplicity
%           1: plot multiplicity
%       b: (for a 0)
%           0: filled marks
%           1: empty marks
%       b: (for a 1)
%           00: plot multiplicity info in the size of the markers.
%           01: plot multiplicity info in the form of the markers.
%           10: plot multiplicity information in the Z axis.
%           11: plot multiplicity info in the size of the markers and 
%               classes in Z-axis
%           
%   By deafult, opt = '00'. If less digits are specified, least significant
%   digits are set to 0, i.e. opt = 1 means a=1, b=00.
%
% mult: [Nx1] multiplicity of each row (1s by default)
%
% maxv: [1x3] thresholds for the different markers.
%       maxv(1): maximum threshold for marker 'x' for opt = 2 (20 by default)
%       maxv(1): maximum threshold for marker 'o' for opt = 2 (50 by default)
%       maxv(1): maximum threshold for marker 's' for opt = 2 (100 by default)
%
% blur: [1x1] avoid blur when adding labels. The higher, the more labels 
%   are printer (the higher blur). Inf shows all the labels (1 by default).
%
%
% OUTPUTS:
%
% fig_h: (1x1) figure handle.
%
%
% EXAMPLE OF USE: Plot random data with filled marks and control limits:
%
% fig_h = plot_scatter(rand(100,2),[],[],{'Y','X'},{0.8,0.8},0);
%
%
% EXAMPLE OF USE: with labels and classes in elements:
%
% fig_h = plot_scatter(randn(5,2),{'one','two','three','four','five'},[1 1 1 2 2],{'Y','X'});
%
%
% EXAMPLE OF USE: with labels, multilicity and classes in elements:
%
% X = randn(5,2);
% for opt = [0 100 101 110 111],
%   fig_h = plot_scatter(X,{'one','two','three','four','five'},[1 1 1 2 2],{'Y','X'},[],opt,[1 20 50 100 1000]);
% end
%
%
% coded by: Jose Camacho Paez (josecamacho@ugr.es)
%           Alejandro Perez Villegas (alextoni@gmail.com)
% last modification: 4/Nov/18.
%
% Copyright (C) 2018  University of Granada, Granada
% Copyright (C) 2018  Jose Camacho Paez
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
%

%% Parameters checking

% Set default values
routine=dbstack;
assert (nargin >= 1, 'Error in the number of arguments. Type ''help %s'' for more info.', routine(1).name);

N = size(bdata, 1);
if nargin < 2 || isempty(elabel), elabel = 1:N; end;
if nargin < 3 || isempty(classes), classes = ones(N,1); end;
if nargin < 4 || isempty(xylabel), xylabel = {'',''}; end;
if nargin < 5 || isempty(lcont),  lcont = []; end;
if nargin < 6 || isempty(opt),     opt     = '000';                 end;
if nargin < 7 || isempty(mult),    mult    = ones(N,1);         end;
if nargin < 8 || isempty(maxv),    maxv    = [20 50 100];       end;
if nargin < 9 || isempty(blur),    blur    = 1;       end;

% Convert int arrays to str
if isnumeric(opt), opt=num2str(opt); end

% Convert row arrays to column arrays
if size(elabel,1)  == 1, elabel  = elabel';  end;
if size(classes,1) == 1, classes = classes'; end;
if size(lcont,1) == 1, lcont = lcont'; end;
if size(mult,1) == 1, mult = mult'; end;
if size(maxv,2) == 1, maxv = maxv'; end;

% Convert int arrays to str
if ~isempty(elabel) && isnumeric(elabel), elabel=num2str(elabel); end
if isnumeric(opt), opt=num2str(opt); end

% Complete opt
while length(opt)<3, opt = strcat(opt,'0'); end

% Convert char arrays to cell
if ischar(elabel),  elabel = cellstr(elabel); end;
if ischar(classes), classes = cellstr(classes); end;
if ischar(xylabel),  xylabel = cellstr(xylabel); end;

% Validate dimensions of input data
assert(size(bdata,2) == 2, 'Dimension Error: 1st argument must be N-by-2. Type ''help %s'' for more info.', routine(1).name); 
if ~isempty(elabel), assert (isequal(size(elabel), [N 1]), 'Dimension Error: 2nd argument must be N-by-1. Type ''help %s'' for more info.', routine(1).name); end;
if ~isempty(classes), assert (isequal(size(classes), [N 1]), 'Dimension Error: 3rd argument must be N-by-1. Type ''help %s'' for more info.', routine(1).name); end;
if ~isempty(xylabel), assert (length(xylabel) == 2, 'Dimension Error: 4th argument must contain 2 cell elements. Type ''help %s'' for more info.', routine(1).name); end;
if ~isempty(lcont), assert (iscell(lcont) && isequal(size(lcont), [2 1]), 'Dimension Error: 5th argument must be a cell of 2 elements. Type ''help %s'' for more info.', routine(1).name); end;
assert (ischar(opt) && length(opt)==3, 'Dimension Error: 6th argument must be a string or num of maximum 3 bits. Type ''help %s'' for more info.', routine(1).name);
if ~isempty(mult), assert (isequal(size(mult), [N 1]), 'Dimension Error: 7th argument must be N-by-1. Type ''help %s'' for more info.', routine(1).name); end;
if ~isempty(maxv), assert (isequal(size(maxv), [1 3]), 'Dimension Error: 8th argument must be 1-by-3. Type ''help %s'' for more info.', routine(1).name); end;
if ~isempty(blur), assert (isequal(size(blur), [1 1]), 'Dimension Error: 9th argument must be 1-by-1. Type ''help %s'' for more info.', routine(1).name); end;

% Validate values of input data
assert (isempty(find(opt~='0' & opt~='1')), 'Value Error: 6th argument must contain binary values. Type ''help %s'' for more info.', routine(1).name);


%% Main code

% Create figure window
fig_h = figure;
hold on;

% Preprocess classes to force them start with 1, 2...n,
unique_classes = unique(classes);
if iscell(classes)
     normal_classes = arrayfun(@(x) find(strcmp(unique_classes, x), 1), classes);
else
     normal_classes = arrayfun(@(x) find(unique_classes == x, 1), classes);
end
unique_classes = unique(normal_classes);

% Define mult bins, markers, colors and sizes 
bins = [0 1 maxv Inf];
markers = ['^','v','d','o','s'];

color_list = hsv(length(unique_classes));
colors = color_list(normal_classes, :);

sizes = zeros(size(mult));
for i=1:length(bins)-1
    sizes (mult>bins(i) & mult<=bins(i+1)) = round(2.5 * i^2 * pi);
end

switch opt
    case '000',  % 2D plot, No multiplicity info, filled marks
        for i=1:length(unique_classes)
            ind = find(normal_classes == unique_classes(i));
            scatter(bdata(ind,1), bdata(ind,2), [], colors(ind,:),'filled','DisplayName',num2str(unique_classes(i)));
        end

    case '010',  % 2D plot, No multiplicity info, empty marks
        for i=1:length(unique_classes)
            ind = find(normal_classes == unique_classes(i));
            scatter(bdata(ind,1), bdata(ind,2), [], colors(ind,:),'DisplayName',num2str(unique_classes(i)));
        end
    
    case '100',  % 2D plot, Multiplicity in size
        for i=1:length(unique_classes)
            ind = find(normal_classes == unique_classes(i));
            scatter(bdata(ind,1), bdata(ind,2),sizes(ind), colors(ind,:),'filled','DisplayName',num2str(unique_classes(i)));
        end
    
    case '101',  % 2D plot, Multiplicity in markers
        for i=1:length(unique_classes)
            for j=1:length(bins)-1
                ind = find(normal_classes==unique_classes(i) & mult<=bins(j+1) & mult>bins(j));
                disp_name = strcat(num2str(unique_classes(i)), ' (mult: > ', num2str(bins(j)), ')');
                scatter(bdata(ind,1), bdata(ind,2), [], colors(ind,:), 'filled', markers(j), 'DisplayName', disp_name);
            end
        end
    
    case '110',  % 3D plot, Multiplicity in Z-axis
        for i=1:length(unique_classes)
            ind = find(normal_classes == unique_classes(i));
            scatter3(bdata(ind,1), bdata(ind,2), mult(ind), [], colors(ind,:), 'filled', 'DisplayName',num2str(unique_classes(i)));
        end
    
    case '111',  % 3D plot, Multiplicity in size, classes in Z-axis
        for i=1:length(unique_classes)
            ind = find(normal_classes == unique_classes(i));
            scatter3(bdata(ind,1), bdata(ind,2), normal_classes(ind), sizes(ind), colors(ind,:), 'filled', 'DisplayName',num2str(unique_classes(i)));
        end
end

% Plot labels    
ax = axis;
f = 5;
deltax = (ax(2)-ax(1))/100;
deltay = (ax(4)-ax(3))/100;
if ~isempty(elabel)
    for i=1:N
        suffx = length(char(strtrim(elabel(i,1))));
        ind = [1:(i-1) (i+1):size(bdata,1)];
        
        dx = (bdata(ind,1)-bdata(i,1))/deltax;
        dxM = dx;
        dxM(dxM<0) = Inf;
        dxm = dx;
        dxm(dxm>0) = Inf;
        dy = (bdata(ind,2)-bdata(i,2))/deltay;
        dyM = dy;
        dyM(dyM<0) = Inf;
        dym = dy;
        dym(dym>0) = Inf;
        
        % Labels in any direction: not used
        
%         d = min([dxM.^2+dyM.^2 dxM.^2+dym.^2 dxm.^2+dyM.^2 dxm.^2+dym.^2]);
%         if length(find(d > 10/blur))>1 || isempty(ind),
%             quad = find(d==max(d),1);
%             switch quad,
%                 case 1,
%                     posx = bdata(i,1)+deltax;
%                     posy = bdata(i,2)+deltay;
%                 case 2,
%                     posx = bdata(i,1)+deltax;
%                     posy = bdata(i,2)-6*deltay;
%                 case 3,
%                     posx = bdata(i,1)-deltax-suffx/2;
%                     posy = bdata(i,2)+2*deltay;
%                 case 4,
%                     posx = bdata(i,1)-deltax-suffx/2;
%                     posy = bdata(i,2)-6*deltay;
%             end
% 
% 
%         % Labels only to the right: used
%         
        d = min([dxM.^2+dyM.^2 dxM.^2+dym.^2 dxm.^2+dyM.^2 dxm.^2+dym.^2]);
        if (length(find(d > 10/blur))>1 && length(find(d(1:2) > 10/blur))>0)|| isempty(ind),
            quad = find(d(1:2)==max(d(1:2)),1);
            switch quad,
                case 1,
                    posx = bdata(i,1)+deltax;
                    posy = bdata(i,2)+deltay;
                case 2,
                    posx = bdata(i,1)+deltax;
                    posy = bdata(i,2)-6*deltay;
                case 3,
                    posx = bdata(i,1)-deltax-suffx/2;
                    posy = bdata(i,2)+2*deltay;
                case 4,
                    posx = bdata(i,1)-deltax-suffx/2;
                    posy = bdata(i,2)-6*deltay;
            end
            
%         % Labels only to upper right: not used
%         
%         d = min([dxM.^2+dyM.^2 dxM.^2+dym.^2 dxm.^2+dyM.^2 dxm.^2+dym.^2]);
%         if (length(find(d > 10/blur))>1 && d(1) > 10/blur)|| isempty(ind),
%             posx = bdata(i,1)+deltax;
%             posy = bdata(i,2)+deltay;
            
            
            switch opt
                case '110'
                    text(posx, posy, mult(i), strtrim(elabel(i,1)),'VerticalAlignment','bottom', 'HorizontalAlignment','left','FontSize', 12);
                case '111'
                    text(posx, posy, normal_classes(i), strtrim(elabel(i,1)),'VerticalAlignment','bottom', 'HorizontalAlignment','left','FontSize', 12);
                otherwise
                    text(posx, posy, strtrim(elabel(i,1)),'VerticalAlignment','bottom', 'HorizontalAlignment','left','FontSize', 12);
            end
        end
    end
end


ax = axis;
ax([1 3]) = min(ax([1 3]),zeros(1,2));
ax([2 4]) = max(ax([2 4]),zeros(1,2));

if ~isempty(lcont) % Plot control limits
    if ~isempty(lcont{2})
        ax(3) = min([ax(3);lcont{2}(:)]);
        ax(4) = max([ax(4);lcont{2}(:)]);
    end
    if ~isempty(lcont{1})
        ax(1) = min([ax(1);lcont{1}(:)]);
        ax(2) = max([ax(2);lcont{1}(:)]);
        for i=1:length(lcont{1}),
            plot([lcont{1}(i) lcont{1}(i)], ax(3:4), 'r--','LineWidth',2, 'HandleVisibility', 'off');
        end
    end
    if ~isempty(lcont{2})
        for i=1:length(lcont{2}),
            plot(ax(1:2),[lcont{2}(i) lcont{2}(i)], 'r--','LineWidth',2, 'HandleVisibility', 'off');
        end
    end    
else % Plot origin lines
    plot([0 0], ax(3:4), 'k--', 'HandleVisibility', 'off');
    plot(ax(1:2), [0 0], 'k--', 'HandleVisibility', 'off');
end    
axis(ax)

% Set axis labels
if ~isempty(xylabel)
    xlabel(xylabel{1}, 'FontSize', 20);
    ylabel(xylabel{2}, 'FontSize', 20);
end

axes_h = get(fig_h,'Children');
set(axes_h, 'FontSize', 12);

legend off
box on
hold off

  