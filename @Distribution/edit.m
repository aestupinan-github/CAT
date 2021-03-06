
%% Method edit
% Edit Distribution object in GUI
%
% D.edit
% % or
% edit(D)
% opens a new GUI window which lets user define the distribution by
% choosing a grid and defining a function or giving values. The
% distribution is displayed in a plot in the GUI window.
%
% This function is used by the CAT GUI
%
% SEE ALSO
% CAT, CATTube, Distribution

% Copyright 2015-2016 David Ochsenbein
% Copyright 2012-2014 David Ochsenbein, Martin Iggland
% 
% This file is part of CAT.
% 
% CAT is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation version 3 of the License.
% 
% CAT is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function edit(O)
% Get distribution density definition
orig_densfnc = O.getFunction();
orig_densval = O.F;
if ~isempty(orig_densfnc)
    % Cut @(y) from front of definition
    orig_densfnc = func2str(orig_densfnc);
    orig_densfnc = orig_densfnc(5:end);
    orig_densval = [];
    % Set active field
    Dgui.density.activefield = 'function';
elseif ~isempty(orig_densval)
    orig_densfnc = '';
    orig_densval = O.F;
    % Set active field
    Dgui.density.activefield = 'values';
else
    % No distribution defined
    orig_densfnc = '';
    orig_densval = [];
    % Set active field to function by default
    Dgui.density.activefield = 'function';
end % if else
% Create the figure handle
Dgui.fighandle = figure(...
    'MenuBar','none',...
    'Name','Edit initial distribution',...
    'NumberTitle','off',...
    'Position',[200 200 550 545],...
    'Resize','off');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grid
%
% Panel
Dgui.grid.panel = uipanel('Parent',Dgui.fighandle,...
    'Title','Grid',...
    'Units','pixels',...
    'Position',[20 455 520 70]);
% Button group for the radio buttons
Dgui.grid.spacingtype = uibuttongroup('Parent',Dgui.grid.panel,...
    'Title','',...
    'Units','pixels',...
    'BorderType','none',...
    'Position',[10 10 100 40],...
    'SelectionChangeFcn',@(hObject,Eventdata)changegridtype(hObject,Eventdata));
% Radio button 'logarithmic'
Dgui.grid.spacingtype_log = uicontrol(Dgui.grid.spacingtype,...
    'Style','radiobutton',...
    'String','Log10',...
    'Position',[0 0 60 20]);
% Radio button 'linear'
Dgui.grid.spacingtype_lin = uicontrol(Dgui.grid.spacingtype,...
    'Style','radiobutton',...
    'String','Linear',...
    'Position',[0 20 60 20]);
% Calculate settings for currently defined distribution
if isempty(O.boundaries)
    % Make linear spacing default if empty
    orig_gmin = [];
    orig_gmax = [];
    orig_gspacing = [];
    Dgui.grid.spacingtype.SelectedObject = Dgui.grid.spacingtype_lin;
elseif allvaleq( diff( log10(O.boundaries) ) )
    % Log spacing
    orig_gmin = min(log10(O.boundaries));
    orig_gmax = max(log10(O.boundaries));
    orig_gspacing = mean(diff( log10( O.boundaries )));
    set(Dgui.grid.spacingtype_log,'value',1)
elseif allvaleq( diff( O.y) )
    % Linear spacing
    orig_gmin = min(O.boundaries);
    orig_gmax = max(O.boundaries);
    orig_gspacing = mean(diff( O.boundaries ));
    set(Dgui.grid.spacingtype_lin,'value',1)
else
    % custom
    orig_gmin = min(O.boundaries);
    orig_gmax = max(O.boundaries);
    orig_gspacing = mean(diff( O.boundaries ));
    set(Dgui.grid.spacingtype,'selectedobject',[])
end % if else
orig_gnumpoints = length(O.boundaries);
% Min field
Dgui.grid.min_text = uicontrol(Dgui.grid.panel,...
    'Style','text',...
    'String','Min.',...
    'Units','pixels',...
    'Position',[140 35 70 20]);
Dgui.grid.min = uicontrol(Dgui.grid.panel,...
    'Style','edit',...
    'String',num2str(orig_gmin),...
    'TooltipString','Starting point of calculation grid',...
    'Units','pixels',...
    'Callback',@(hObject,Eventdata)changegrid(hObject,Eventdata,'min'),...
    'Position',[140 10 70 30],...
    'BackgroundColor','w');
% Spacing field
Dgui.grid.spacing_text = uicontrol(Dgui.grid.panel,...
    'Style','text',...
    'String','Spacing',...
    'Units','pixels',...
    'Position',[215 35 70 20]);
Dgui.grid.spacing = uicontrol(Dgui.grid.panel,...
    'Style','edit',...
    'String',num2str(orig_gspacing),...
    'Enable','off',...
    'TooltipString','Spacing of grid points',...
    'Units','pixels',...
    'Position',[215 10 70 30]);
% Max field
Dgui.grid.max_text = uicontrol(Dgui.grid.panel,...
    'Style','text',...
    'String','Max.',...
    'Units','pixels',...
    'Position',[290 35 70 20]);
Dgui.grid.max = uicontrol(Dgui.grid.panel,...
    'Style','edit',...
    'String',num2str(orig_gmax),...
    'TooltipString','End point of calculation grid',...
    'Units','pixels',...
    'Callback',@(hObject,Eventdata)changegrid(hObject,Eventdata,'max'),...
    'Position',[290 10 70 30],...
    'BackgroundColor','w');
% Number of gridpoints field
Dgui.grid.numpoints_text = uicontrol(Dgui.grid.panel,...
    'Style','text',...
    'String','Gridpoints',...
    'Units','pixels',...
    'Position',[380 35 70 20]);
Dgui.grid.numpoints = uicontrol(Dgui.grid.panel,...
    'Style','edit',...
    'String',num2str(orig_gnumpoints),...
    'TooltipString','Number of grid points',...
    'Units','pixels',...
    'Callback',@(hObject,Eventdata)changegrid(hObject,Eventdata,'numpoints'),...
    'Position',[380 10 70 30],...
    'BackgroundColor','w');
Dgui.grid.browse = uicontrol(Dgui.grid.panel,...
    'Style','pushbutton',...
    'String','Browse',...
    'Value',0,...
    'Callback',@(hObject,eventdata) distBrowse(hObject,eventdata,'boundaries','double'),...
    'Position',[460 10 50 30]...
    );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Population density
%
% Panel
Dgui.density.panel = uipanel('Parent',Dgui.fighandle,...
    'Title','Population density',...
    'Units','pixels',...
    'Position',[20 275 520 160]);
% Button group for the radio buttons
Dgui.density.ftype = uibuttongroup('Parent',Dgui.density.panel,...
    'Title','',...
    'Units','pixels',...
    'BorderType','none',...
    'Position',[10 10 100 120],...
    'SelectionChangeFcn',@(hObject,Eventdata)changeftype(hObject,Eventdata));
% Radio button 'normal'
Dgui.density.ftype_nor = uicontrol(Dgui.density.ftype,...
    'Style','radiobutton',...
    'String','Normal',...
    'Position',[0 87 80 20]);
Dgui.density.function_mu = uicontrol(Dgui.density.panel,...
    'Style','text',...
    'String','Mean',...
    'Units','pixels',...
    'Callback',@(hObject,Eventdata)changeparam(hObject,Eventdata,'normal'),...
    'Position',[85 120 100 20]);
Dgui.density.function_sigma = uicontrol(Dgui.density.panel,...
    'Style','text',...
    'String','Variance',...
    'Units','pixels',...
    'Callback',@(hObject,Eventdata)changeparam(hObject,Eventdata,'normal'),...
    'Position',[190 120 100 20]);
Dgui.density.function_nor_mu = uicontrol(Dgui.density.panel,...
    'Style','edit',...
    'String','',...
    'TooltipString','Mean',...
    'enable','off',...
    'Units','pixels',...
    'Callback',@(hObject,Eventdata)changeparam(hObject,Eventdata,'normal'),...
    'Position',[85 90 100 30]);
Dgui.density.function_nor_sigma = uicontrol(Dgui.density.panel,...
    'Style','edit',...
    'String','',...
    'TooltipString','Variance',...
    'enable','off',...
    'Units','pixels',...
    'Callback',@(hObject,Eventdata)changeparam(hObject,Eventdata,'normal'),...
    'Position',[190 90 100 30]);
% Radio button 'lognormal'
Dgui.density.ftype_lognor = uicontrol(Dgui.density.ftype,...
    'Style','radiobutton',...
    'String','Lognormal',...
    'Position',[0 47 80 20]);
Dgui.density.function_lognor_mu = uicontrol(Dgui.density.panel,...
    'Style','edit',...
    'String','',...
    'TooltipString','Mean',...
    'enable','off',...
    'Units','pixels',...
    'Callback',@(hObject,Eventdata)changeparam(hObject,Eventdata,'lognormal'),...
    'Position',[85 50 100 30]);
%
Dgui.density.function_lognor_sigma = uicontrol(Dgui.density.panel,...
    'Style','edit',...
    'String','',...
    'TooltipString','Variance',...
    'enable','off',...
    'Units','pixels',...
    'Callback',@(hObject,Eventdata)changeparam(hObject,Eventdata,'lognormal'),...
    'Position',[190 50 100 30]);
% Radio button 'custom'
Dgui.density.ftype_custom = uicontrol(Dgui.density.ftype,...
    'Style','radiobutton',...
    'String','Custom',...
    'value',1,...
    'Position',[0 7 60 20]);
% @(y) label
Dgui.density.function_text2 = uicontrol(Dgui.density.panel,...
    'Style','text',...
    'String','@(y)',...
    'Units','pixels',...
    'Position',[80 10 30 20]);
Dgui.density.function = uicontrol(Dgui.density.panel,...
    'Style','edit',...
    'String',orig_densfnc,...
    'TooltipString','Function defining population density',...
    'Units','pixels',...
    'enable','on',...
    'backgroundcolor','w',...
    'Callback',@(hObject,Eventdata)changedensity(hObject,Eventdata,'function'),...
    'Position',[110 10 180 30]);
% Values field
% Text
Dgui.density.values_text = uicontrol(Dgui.density.panel,...
    'Style','text',...
    'String','Values',...
    'Units','pixels',...
    'Position',[295 80 150 20]);
% Input box
Dgui.density.values = uicontrol(Dgui.density.panel,...
    'Style','edit',...
    'String',regexprep(data2str(orig_densval),'\[|\]',''),...
    'TooltipString','Values defining population density (separate with space). You can use workspace variables as well.',...
    'Units','pixels',...
    'backgroundcolor','w',...
    'Callback',@(hObject,Eventdata)changedensity(hObject,Eventdata,'values'),...
    'Position',[295 50 150 30]);
Dgui.density.browse = uicontrol(Dgui.density.panel,...
    'Style','pushbutton',...
    'String','Browse',...
    'Value',0,...
    'Callback',@(hObject,eventdata) distBrowse(hObject,eventdata,'F','double'),...
    'Position',[460 50 50 30]...
    );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preview
%
% Panel
Dgui.preview.panel = uipanel('Parent',Dgui.fighandle,...
    'Title','Preview',...
    'Units','pixels',...
    'Position',[20 45 520 220]);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OK, Reset, Cancel buttons
%
% OK Button
Dgui.buttons.ok = uicontrol(Dgui.fighandle,...
    'Style','pushbutton',...
    'String','OK',...
    'Value',0,...
    'Callback',@returnVals,...
    'Position',[70 10 100 30]...
    );
% Reset Button
Dgui.buttons.ok = uicontrol(Dgui.fighandle,...
    'Style','pushbutton',...
    'String','Reset',...
    'Value',0,...
    'Callback',@resetVals,...
    'Position',[200 10 100 30]...
    );
% Cancel Button
Dgui.buttons.ok = uicontrol(Dgui.fighandle,...
    'Style','pushbutton',...
    'String','Cancel',...
    'Value',0,...
    'Callback',@cancelDgui,...
    'Position',[330 10 100 30]...
    );
plotDist([],[]);
uiwait;
%% % - Subfunctions
%% Function cancelDgui
    function cancelDgui(~,~)
        % Close the editing GUI without doing anything
        close(Dgui.fighandle)
        clear Dgui
    end % function cancelDgui
%% Function changedensity
    function changedensity(hObject,~,field)
        % Save active field
        Dgui.density.activefield = field;
        [~,f] = getDgui_current('values');
        set(Dgui.density.values,'string',data2str(f));
        if strcmp(field,'values')
            Dgui.density.ftype.SelectedObject = Dgui.density.ftype_custom;
            fakeEvent.NewValue = '';
            changeftype(hObject,fakeEvent);
        end
        plotDist
    end % function
    function changeparam(hObject,~,ftype)
        % Change background of the field not currently edited
        % Save active field - function or values
        % Set both background to default, then change current field to
        % white
        if strcmp(ftype,'normal') && ~isempty(str2num(get(Dgui.density.function_nor_sigma,'string'))) && ~isempty(str2num(get(Dgui.density.function_nor_mu,'string')))
            set(Dgui.density.function,'string',['1./',get(Dgui.density.function_nor_sigma,'string'),'*exp(-(y-',get(Dgui.density.function_nor_mu,'string'),').^2./(2*',get(Dgui.density.function_nor_sigma,'string'),'.^2))'])
            changedensity(hObject,[],'function')
        elseif strcmp(ftype,'lognormal') && ~isempty(str2num(get(Dgui.density.function_lognor_sigma,'string'))) && ~isempty(str2num(get(Dgui.density.function_lognor_mu,'string')))
            set(Dgui.density.function,'string',['1./(y','.*',get(Dgui.density.function_lognor_sigma,'string'),').*exp(-(log(y)-',get(Dgui.density.function_lognor_mu,'string'),').^2./(2*',get(Dgui.density.function_lognor_sigma,'string'),'.^2))'])
            changedensity(hObject,[],'function')
        end
    end % function
    function distBrowse(hObject,~,classvarname,classfilter)
        [vardata,varname] = browseVars(classfilter);
        if ~isempty(classvarname) && ~isempty(vardata)
            O.(classvarname) = vardata;
            % O.gui.source.(classvarname) = varname;
        end % if
        if isempty(strfind(get(get(hObject,'parent'),'title'),'density'))
            if allvaleq( diff( log10(O.boundaries) ) )
                % Log spacing
                set(Dgui.grid.min,'string',num2str(min(log10(O.boundaries))));
                set(Dgui.grid.max,'string',num2str(max(log10(O.boundaries))));
                set(Dgui.grid.spacing,'String',mean(diff( log10( O.boundaries ))));
                set(Dgui.grid.spacingtype_log,'value',1)
            elseif allvaleq( diff( O.boundaries) )
                % Linear spacing
                set(Dgui.grid.min,'string',num2str(min(O.boundaries)));
                set(Dgui.grid.max,'string',num2str(max(O.boundaries)));
                set(Dgui.grid.spacing,'String',mean(diff( O.boundaries )));
                set(Dgui.grid.spacingtype_lin,'value',1)
            else
                % custom
                set(Dgui.grid.min,'string',num2str(min(O.boundaries)));
                set(Dgui.grid.max,'string',num2str(max(O.boundaries)));
                set(Dgui.grid.spacing,'String',mean(diff( O.boundaries )));
                set(Dgui.grid.spacingtype,'selectedobject',[])
            end % if else
            set(Dgui.grid.numpoints,'string',num2str(numel(O.boundaries)));
        else
            fakeEvent.NewValue = '';
            changeftype(hObject,fakeEvent);
            set(Dgui.density.ftype,'selectedobject',[])
            set(Dgui.density.values,'string',data2str(O.F))
            changedensity(hObject,[],'function')
        end
    end % function
%% Function changegrid
    function changegrid(hObject,~,field)
        % Update spacing or gridpoints field when min, spacing, max or
        % gridpoints field changed
        newval = str2double(get(hObject,'String'));
        switch field
            case 'min'
                % New minimum point
                gmax = str2double(get(Dgui.grid.max,'String'));
                gnumpoints = str2double(get(Dgui.grid.numpoints,'String'));
                gmin = newval;
            case 'max'
                % New maximum point
                gmin = str2double(get(Dgui.grid.min,'String'));
                gnumpoints = str2double(get(Dgui.grid.numpoints,'String'));
                gmax = newval;
            case 'numpoints'
                % New number of points
                gmin = str2double(get(Dgui.grid.min,'String'));
                gmax = str2double(get(Dgui.grid.max,'String'));
                gnumpoints = newval;
        end % switch
        newspacing = (gmax - gmin) / (gnumpoints-1);
        set(Dgui.grid.spacing,'String',num2str(newspacing));
        changedensity(hObject,[],'function')
    end % function changespacing
%% Function changegridtype
    function changegridtype(hObject,Eventdata)
        % Change text infront of bracket
        if strcmp( get(Eventdata.NewValue,'String') , 'Linear')
            % Recalculate min, max, spacing
            gmin = 10^str2double(get(Dgui.grid.min,'String'));
            if ~isfinite(gmin)
                gmin = 0;
            end % if
            gmax = 10^str2double(get(Dgui.grid.max,'String'));
            gnumpoints = str2double(get(Dgui.grid.numpoints,'String'));
            gspacing = (gmax - gmin) / (gnumpoints-1);
        else
            % Recalculate min, max, spacing
            gmin = log10(str2double(get(Dgui.grid.min,'String')));
            if isinf(gmin)
                gmin = [];
            end % if
            gmax = log10(str2double(get(Dgui.grid.max,'String')));
            gnumpoints = str2double(get(Dgui.grid.numpoints,'String'));
            gspacing = (gmax - gmin) / (gnumpoints-1);
        end % if else
        % Set new values
        set(Dgui.grid.min,'String',num2str(gmin));
        set(Dgui.grid.spacing,'String',num2str(gspacing));
        set(Dgui.grid.max,'String',num2str(gmax));
    end % function
    function changeftype(~,Eventdata)
        set(Dgui.density.function,'enable','off')
        set(Dgui.density.function_lognor_sigma,'enable','off')
        set(Dgui.density.function_lognor_mu,'enable','off')
        set(Dgui.density.function_nor_sigma,'enable','off')
        set(Dgui.density.function_nor_mu,'enable','off')
        if strcmpi(get(Eventdata.NewValue,'string'),'normal')
            set(Dgui.density.function_nor_sigma,'enable','on','backgroundcolor','w')
            set(Dgui.density.function_nor_mu,'enable','on','backgroundcolor','w')
        elseif strcmpi(get(Eventdata.NewValue,'string'),'lognormal')
            set(Dgui.density.function_lognor_sigma,'enable','on','backgroundcolor','w')
            set(Dgui.density.function_lognor_mu,'enable','on','backgroundcolor','w')
        else
            set(Dgui.density.function,'enable','on','backgroundcolor','w')
        end
    end % function
%% Function getDgui_current
    function [xb,f,y] = getDgui_current(type)
        % Return currently defined xb vector and f values or function, if
        % defined.
        %
        % [xb,f] = getDgui_current('func')
        % returns f as a function, if defined (default)
        %
        % [xb,f] = getDgui_current('values')
        % returns f as values evaluated at y (lies in arithmetic mean of
        % boundary points defined in xb)
        if nargin < 1 || isempty(type)
            type = 'func';
        end % if
        % Get currently defined xb value
        % Use min:spacing:max, assume that number of gridpoints has been
        % calculated correctly
        xmin = str2double( get(Dgui.grid.min,'String') );
        xmax = str2double( get(Dgui.grid.max,'String') );
        xnumpoints = str2double( get( Dgui.grid.numpoints,'String') );
        try % assumes Matlab 2014b or higher, older versions should be covered by catch
            if strcmp( get(get(Dgui.grid.spacingtype,'SelectedObject'),'String') , 'Log10' )
                xb = logspace(xmin,xmax,xnumpoints);
            elseif strcmp( get(get(Dgui.grid.spacingtype,'SelectedObject'),'String') , 'Linear' )
                xb = linspace(xmin,xmax,xnumpoints);
            else
                xb = O.boundaries;
            end % if
        catch
            if strcmp( get(Dgui.grid.spacingtype.SelectedObject,'String') , 'Log10' )
                xb = logspace(xmin,xmax,xnumpoints);
            elseif strcmp( get(Dgui.grid.spacingtype.SelectedObject,'String') , 'Linear' )
                xb = linspace(xmin,xmax,xnumpoints);
            else
                xb = O.boundaries;
            end % if
        end
        % Calculate pivot points
        y = (xb(1:end-1)+xb(2:end))/2;
        % Get currently defined distribution function
        % Check for defined function
        if strcmp(Dgui.density.activefield,'function')
            fncstr = get(Dgui.density.function,'String');
            if ~isempty(fncstr)
                f = str2func([get(Dgui.density.function_text2,'String') fncstr]);
            else
                f = str2num(get(Dgui.density.values,'string'));
            end % if else
            % If values wanted, translate to values
            if strcmpi(type,'values')
                try
                    if isa(f,'function_handle')
                        f = f(y);
                    end
                catch ME
                    warndlg(...
                        sprintf('Distribution function could not be evaluated. Error: %s',ME.message),...
                        'Error evaluating given function','modal');
                end % try-catch
            end % if
        else
            % Get values field
            vals = get(Dgui.density.values,'String');
            try
                f = evalin('base',[ '[' vals ']' ]);
                if length(f) ~= length(y)
                    warndlg('Vector of values must have the right number of entries',...
                        'Error using given values','modal');
                    f = zeros(size(y));
                end % if
            catch ME
                warndlg(...
                    sprintf('Distribution values could not be applied. Error: %s',ME.message),...
                    'Error using given values','modal');
            end % try-catch
        end % if else
    end % function
%% Function plotDist
    function plotDist(~,~)
        % Check for the plot axis, create if it does not exist
        if ~isfield(Dgui.preview,'axes') || ~ishandle(Dgui.preview.axes)
            Dgui.preview.axes = axes('Parent',Dgui.preview.panel,...
                'Position',[0.13 0.19 0.75 0.73]);
            xlabel(Dgui.preview.axes,'y')
            ylabel(Dgui.preview.axes,'f(y)')
            box(Dgui.preview.axes,'on')
        else
            % If axes exists, clear any previous plots
            if isfield(Dgui.preview,'lines') && any(ishandle(Dgui.preview.lines))
                delete(Dgui.preview.lines)
            end % if
        end % if
        % Create new plot
        [~,f,y] = getDgui_current('values');
        if ~isempty(f)
            Dgui.preview.lines = line(y,f,'marker','o');
        end
        try % assumes Matlab 2014b or higher, older versions should be covered by catch
            if strcmp( get(get(Dgui.grid.spacingtype,'SelectedObject'),'String') , 'Log10' )
                set(gca,'xscale','log')
            else
                set(gca,'xscale','linear')
            end
        catch
            if strcmp( get(Dgui.grid.spacingtype.SelectedObject,'String') , 'Log10' )
                set(gca,'xscale','log')
            else
                set(gca,'xscale','linear')
            end
        end
    end % function plotDist
%% Function returnVals
    function returnVals(~,~)
        % Set values to distribution, close GUI
        % Get currently defined values
        [xb,f] = getDgui_current;
        % Set these values
        O.boundaries = xb;
        O.F = f;
        % Close the GUI
        close(Dgui.fighandle)
        clear Dgui
    end % function
%% Function resetVals
    function resetVals(~,~)
        % Reset fields to the values which were valid when the window was
        % opened
        set(Dgui.grid.min,'String',num2str(orig_gmin));
        set(Dgui.grid.max,'String',num2str(orig_gmax));
        set(Dgui.grid.spacing,'String',num2str(orig_gspacing));
        set(Dgui.grid.numpoints,'String',num2str(orig_gnumpoints));
        set(Dgui.density.function,'String',orig_densfnc);
        set(Dgui.density.values,'String',regexprep(data2str(orig_densval),'\[|\]',''));
    end % function resetVals
end % function editDist
