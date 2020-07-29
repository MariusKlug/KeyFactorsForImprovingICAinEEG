function setfigpos(pos,fig_handle)

if ~exist('fig_handle','var')
	fig_handle = gcf;
end
set(fig_handle,'position',pos);