% ERRORAREA plots means and errors (e.g. SEMs or SDs) as translucent areas 
%
% USAGE:
% [linehandles, areahandles] = errorarea(X,Y,errors)

function [linehandles, areahandles] = errorarea(X,Y,errors,linewidth)

if ~exist('linewidth','var')
	linewidth = 2;
end

linehandles = plot(X,Y,'LineWidth',linewidth);

hold on


for i_line = 1:length(linehandles)

    filly = [Y(:,i_line) + errors(:,i_line); fliplr([Y(:,i_line) - errors(:,i_line)]')'];
    fillx = [X(:,i_line); fliplr(X(:,i_line)')'];
    
    areahandles(i_line) = fill(fillx,filly,[linehandles(i_line).Color]);  
    set(areahandles(i_line), 'edgecolor', 'none');
    set(areahandles(i_line), 'FaceAlpha',0.2);
    
end

xlim([min(min(X)) max(max(X))]);

