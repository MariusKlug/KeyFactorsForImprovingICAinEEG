% exports a figure with high quality default options using tif, png, eps, and pdf formats and saves the figure in addition
%
% INPUT:
%   filename        - string containing the name (optionally including full or
%                     relative path) of the file the figure is to be saved as. If
%                     a path is not specified, the figure is saved in the current
%                     directory.
%   figure_handle   - handle to a figure to export (OPTIONAL ARGUMENT)
%
%
% OUTPUT:
%     None. fig, tif, png, eps, and pdf files will be written on disk
%
% AUTHOR:
%   Marius Klug, 2018

function export_fig_all(filename, figure_handle,only_rendered,adjust_titles)

if  ~exist('filename','var')
	error('Please provide a filename for the figure (optionally including the path as well).')
end

if  ~exist('figure_handle','var')
	figure_handle = gcf;
end

if ~exist('only_rendered','var')
	only_rendered = false;
end

if ~exist('adjust_titles','var')
	adjust_titles = false;
end

% Always test for the DAU:
% if ~strcmp(class(figure_handle),'matlab.ui.Figure')
if ~isa(figure_handle,'matlab.ui.Figure')
	error('Please enter a valid figure handle as the second argument.')
end

disp(['Saving figure ' num2str(figure_handle.Number) ' as .fig, and in tif, png, eps, and pdf formats '...
	'using antialiasing, a padding of 5% around the figure, lossless quality, and transparent background for png.'])

disp('The title is slipping a little downwards while exporting using antialiasing, so it''s being moved up a little for plotting')


if adjust_titles
	for i_axes = 1:length(figure_handle.Children)
		axes_handle = figure_handle.Children(i_axes);

		if strcmp(class(axes_handle),'matlab.graphics.axis.Axes')
			titleposition_original = get(get(axes_handle,'title'),'Position');
			titleposition_new = titleposition_original;
			titleposition_new(2) = titleposition_new(2)*1.01;

			set(get(axes_handle,'title'),'Position',titleposition_new)
		end
	end
end
% export using antialiasing, a padding of 5% around the figure, with losless quality, and transparent background (png)
%tiff, png, eps, and PDF formats
if ~only_rendered
	export_fig(figure_handle, filename, '-png', '-tif', '-eps', '-pdf', '-p0.05', '-a4', '-q101', '-transparent')
	savefig(figure_handle, filename)
else
	export_fig(figure_handle, filename, '-png', '-p0.05', '-a4', '-q101')
% 	savefig(figure_handle, filename)
end




disp(['All files written to "' filename '".'])
%
% set(get(axes_handle,'title'),'Position',titleposition_original)