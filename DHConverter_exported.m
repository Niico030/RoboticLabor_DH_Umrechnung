%% Verpflichtende Hausübung Robotertechnik SS21 
   % Gruppe: Muhammad Hanif, Till Gostner, Nico Mayer
   
   % Aufgabenstellung: 
    % Erstellen Sie unter Verwendung der Denavit- Hartenberg Konvention
    % einen Algorithmus:
        % - Bei dem der Nutzer, den Vektor zum Ursprung des i- ten
        %   Koordinatensystems in Basiskoordinaten angibt.
        % - Die Orientierung des i-ten Koordinatensystem relativ zur Bsais
        %   in Form von Quaternionen (Euler Rodrigues Parameter) angibt
        % - Diese Daten sollen vom Benutzer in Form einer
        %   Eingabeaufforderung abgefragt werden
        % - Die Denavit Hartenberg Parameter berechnet werden
        % - Der resultierende Roboter mit der Robotic Toolbox gezeichnet
        %   wird
        
%% Vorgehensweise zum Lösen der Hausübung 

    % 1) Eingabeaufforderung der Quaternionen
    % 2) Eingabeaufforderung der Vektoren zum Ursprung 
    % 3) Plausibilitätsprüfung der vom Benutzer eingegeben Werte
    %       %% Überprüfung Plausibilität Basisvektoren:
    %          Überprüfung mindestens eine Variable (x,y,z) der Basiskoordinaten muss
    %          gleich mit dem vorherigen Link sein, damit Gelenke miteinerander
    %          verbunden sind
    %       %% Überprüfung Plausibilität Quaternion:
    %           1) q0, q1, q2, q3 müssen <= 1 sein
    %           2) q0^2+q1^2+q2^2+q3^2 muss = 1 ergeben
    % 4) Aus den Quaternionen die Rotationsmatrix berechnen
    %       => aus RotMat lassen sich theta und alpha bestimmen
    % 5) Aus den Vektoren lassen sich die Abstände a und d berechenen
    %       => RotMat und Vektoren zur Bestimmung der Denavit Hartenbergparameter
    % 6) Einzelne Linkobjekte werden erstellt
    % 7) Erstellen von Seriallink Objekt des Robotermodells
    % 8) Roboter plotten

classdef DHConverter_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        CalculateDenavitHartenbergButton  matlab.ui.control.Button
        RemoveLastLinksButton          matlab.ui.control.Button
        BasiskoordinatensystemLabel    matlab.ui.control.Label
        QuationenLabel                 matlab.ui.control.Label
        TabGroup                       matlab.ui.container.TabGroup
        DenavitHartenbergParameterTab  matlab.ui.container.Tab
        DenavitTable                   matlab.ui.control.Table
        BasiskoorsysundQuationenTab    matlab.ui.container.Tab
        KoorsysUndQuationen            matlab.ui.control.Table
        ShowPlotButton                 matlab.ui.control.Button
        AddLinksButton                 matlab.ui.control.Button
        zEditField                     matlab.ui.control.NumericEditField
        zEditFieldLabel                matlab.ui.control.Label
        yEditField                     matlab.ui.control.NumericEditField
        yEditFieldLabel                matlab.ui.control.Label
        xEditField                     matlab.ui.control.NumericEditField
        xEditFieldLabel                matlab.ui.control.Label
        q2EditField                    matlab.ui.control.NumericEditField
        q2EditFieldLabel               matlab.ui.control.Label
        q3EditField                    matlab.ui.control.NumericEditField
        q3EditFieldLabel               matlab.ui.control.Label
        q1EditField                    matlab.ui.control.NumericEditField
        q1EditFieldLabel               matlab.ui.control.Label
        q0EditField                    matlab.ui.control.NumericEditField
        q0EditFieldLabel               matlab.ui.control.Label
    end

    
    properties (Access = private)
        Numbers_I               % Anzahl der Links
        BasisVektorsList        % Liste von Basiskoordinatensystem
        QuaternionZeroList      % Liste der q0
        QuaternionVektorList    % Lister der q vektor
        index = 0;              % Index der Angegebenen Links
        InputData = [];         % List der, Quternionen und Basiskoorsystem
        OutputData = [];        % List der Denavit Hartenberg Parameter
        aList                   % Liste der a
        dList                   % Liste der d
        alphaList               % Liste der alpha
        tethaList               % Liste der tetha
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: AddLinksButton
        function AddLinksButtonPushed(app, event)
            app.index = app.index + 1;
            % Add to the variable and check plausibility, if not plausible,
            % then the data will not be stored.
            app.BasisVektorsList(app.index,:) = [app.xEditField.Value, app.yEditField.Value, app.zEditField.Value];
            if checkPlausibilityBasiskoorsystem(app.BasisVektorsList) == 0
                warndlg("Link Objekte können nicht miteinander verbunden werden- Bitte Vektoren überprüfen und erneut eingeben!", "Warning");
                app.BasisVektorsList = app.BasisVektorsList(1:end-1,:);
                app.index = app.index - 1;
                return
            end
            % Add to the variable and check plausibility, if not plausible,
            % then the data will not be stored.
            app.QuaternionZeroList(app.index) = app.q0EditField.Value;
            app.QuaternionVektorList(app.index,:) = [app.q1EditField.Value, app.q2EditField.Value, app.q3EditField.Value];
            [Quaternion_plausible, msg] = checkPlausibilityQuaternion(app.QuaternionZeroList, app.QuaternionVektorList);
            if Quaternion_plausible == 0
                app.BasisVektorsList = app.BasisVektorsList(1:end-1,:);
                app.QuaternionZeroList = app.QuaternionZeroList(1:end-1,:);
                app.QuaternionVektorList = app.QuaternionVektorList(1:end-1,:);
                warndlg(msg, "Warning!");
                app.index = app.index - 1;
                return
            end
            % if everything ok, then data will be shown in the table!
            app.InputData(app.index,:) = [app.BasisVektorsList(app.index,:) app.QuaternionZeroList(app.index) app.QuaternionVektorList(app.index,:)];
            app.KoorsysUndQuationen.Data = app.InputData;
        end

        % Button pushed function: RemoveLastLinksButton
        function RemoveLastLinksButtonPushed(app, event)
            if app.index == 0
                warndlg("There is no row to be remove!","Warning");
            else
                app.BasisVektorsList = app.BasisVektorsList(1:end-1,:);
                app.QuaternionZeroList = app.QuaternionZeroList(1:end-1,:);
                app.QuaternionVektorList = app.QuaternionVektorList(1:end-1,:);
                app.InputData = app.InputData(1:end-1,:);
                app.KoorsysUndQuationen.Data = app.InputData;
                app.index = app.index - 1; 
            end
        end

        % Button pushed function: CalculateDenavitHartenbergButton
        function CalculateDenavitHartenbergButtonPushed(app, event)
            % calculate denavit hartenberg parameter --> see function calculateDenavitHartenbergParam
            if app.index == 0
                warndlg("Please input the basis coordinate and the quaternion first!","Warning");
            else
                [app.aList, app.dList, app.alphaList, app.tethaList] = calculateDenavitHartenbergParam(app.BasisVektorsList, app.QuaternionZeroList, app.QuaternionVektorList);
                app.OutputData = [app.aList, app.dList, app.alphaList, app.tethaList];
                app.DenavitTable.Data = app.OutputData; 
            end
        end

        % Button pushed function: ShowPlotButton
        function ShowPlotButtonPushed(app, event)
            if app.index < 2
                warndlg("2 Links are needed to plot!");
            else
                % Show robot if denavit hartenberg parameter is already set!
                if isempty(app.OutputData)
                    warndlg("Calculate DH parameter first!");
                else
                    showRobotInPlot(app.tethaList, app.dList, app.aList, app.alphaList);
                end
            end
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 818 316];
            app.UIFigure.Name = 'MATLAB App';

            % Create q0EditFieldLabel
            app.q0EditFieldLabel = uilabel(app.UIFigure);
            app.q0EditFieldLabel.HorizontalAlignment = 'right';
            app.q0EditFieldLabel.Position = [25 119 25 22];
            app.q0EditFieldLabel.Text = 'q0';

            % Create q0EditField
            app.q0EditField = uieditfield(app.UIFigure, 'numeric');
            app.q0EditField.Position = [65 119 100 22];

            % Create q1EditFieldLabel
            app.q1EditFieldLabel = uilabel(app.UIFigure);
            app.q1EditFieldLabel.HorizontalAlignment = 'right';
            app.q1EditFieldLabel.Position = [25 87 25 22];
            app.q1EditFieldLabel.Text = 'q1';

            % Create q1EditField
            app.q1EditField = uieditfield(app.UIFigure, 'numeric');
            app.q1EditField.Position = [65 87 100 22];

            % Create q3EditFieldLabel
            app.q3EditFieldLabel = uilabel(app.UIFigure);
            app.q3EditFieldLabel.HorizontalAlignment = 'right';
            app.q3EditFieldLabel.Position = [25 23 25 22];
            app.q3EditFieldLabel.Text = 'q3';

            % Create q3EditField
            app.q3EditField = uieditfield(app.UIFigure, 'numeric');
            app.q3EditField.Position = [65 23 100 22];

            % Create q2EditFieldLabel
            app.q2EditFieldLabel = uilabel(app.UIFigure);
            app.q2EditFieldLabel.HorizontalAlignment = 'right';
            app.q2EditFieldLabel.Position = [25 55 25 22];
            app.q2EditFieldLabel.Text = 'q2';

            % Create q2EditField
            app.q2EditField = uieditfield(app.UIFigure, 'numeric');
            app.q2EditField.Position = [65 55 100 22];

            % Create xEditFieldLabel
            app.xEditFieldLabel = uilabel(app.UIFigure);
            app.xEditFieldLabel.HorizontalAlignment = 'right';
            app.xEditFieldLabel.Position = [24 247 25 22];
            app.xEditFieldLabel.Text = 'x';

            % Create xEditField
            app.xEditField = uieditfield(app.UIFigure, 'numeric');
            app.xEditField.Position = [64 247 100 22];

            % Create yEditFieldLabel
            app.yEditFieldLabel = uilabel(app.UIFigure);
            app.yEditFieldLabel.HorizontalAlignment = 'right';
            app.yEditFieldLabel.Position = [24 215 25 22];
            app.yEditFieldLabel.Text = 'y';

            % Create yEditField
            app.yEditField = uieditfield(app.UIFigure, 'numeric');
            app.yEditField.Position = [64 215 100 22];

            % Create zEditFieldLabel
            app.zEditFieldLabel = uilabel(app.UIFigure);
            app.zEditFieldLabel.HorizontalAlignment = 'right';
            app.zEditFieldLabel.Position = [24 183 25 22];
            app.zEditFieldLabel.Text = 'z';

            % Create zEditField
            app.zEditField = uieditfield(app.UIFigure, 'numeric');
            app.zEditField.Position = [64 183 100 22];

            % Create AddLinksButton
            app.AddLinksButton = uibutton(app.UIFigure, 'push');
            app.AddLinksButton.ButtonPushedFcn = createCallbackFcn(app, @AddLinksButtonPushed, true);
            app.AddLinksButton.Position = [203 23 100 22];
            app.AddLinksButton.Text = 'Add Links';

            % Create ShowPlotButton
            app.ShowPlotButton = uibutton(app.UIFigure, 'push');
            app.ShowPlotButton.ButtonPushedFcn = createCallbackFcn(app, @ShowPlotButtonPushed, true);
            app.ShowPlotButton.Position = [664 23 100 22];
            app.ShowPlotButton.Text = 'Show Plot';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [193 63 587 230];

            % Create DenavitHartenbergParameterTab
            app.DenavitHartenbergParameterTab = uitab(app.TabGroup);
            app.DenavitHartenbergParameterTab.Title = 'Denavit Hartenberg Parameter';

            % Create DenavitTable
            app.DenavitTable = uitable(app.DenavitHartenbergParameterTab);
            app.DenavitTable.ColumnName = {'a'; 'alpha'; 'd'; 'tetha'};
            app.DenavitTable.RowName = {};
            app.DenavitTable.Position = [1 1 585 204];

            % Create BasiskoorsysundQuationenTab
            app.BasiskoorsysundQuationenTab = uitab(app.TabGroup);
            app.BasiskoorsysundQuationenTab.Title = 'Basiskoor.sys und Quationen';

            % Create KoorsysUndQuationen
            app.KoorsysUndQuationen = uitable(app.BasiskoorsysundQuationenTab);
            app.KoorsysUndQuationen.ColumnName = {'x'; 'y'; 'z'; 'q0'; 'q1'; 'q2'; 'q3'};
            app.KoorsysUndQuationen.RowName = {};
            app.KoorsysUndQuationen.Position = [1 1 585 200];

            % Create QuationenLabel
            app.QuationenLabel = uilabel(app.UIFigure);
            app.QuationenLabel.Position = [24 151 61 22];
            app.QuationenLabel.Text = 'Quationen';

            % Create BasiskoordinatensystemLabel
            app.BasiskoordinatensystemLabel = uilabel(app.UIFigure);
            app.BasiskoordinatensystemLabel.Position = [24 279 136 22];
            app.BasiskoordinatensystemLabel.Text = 'Basiskoordinatensystem';

            % Create RemoveLastLinksButton
            app.RemoveLastLinksButton = uibutton(app.UIFigure, 'push');
            app.RemoveLastLinksButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveLastLinksButtonPushed, true);
            app.RemoveLastLinksButton.Position = [327 23 118 22];
            app.RemoveLastLinksButton.Text = 'Remove Last Links';

            % Create CalculateDenavitHartenbergButton
            app.CalculateDenavitHartenbergButton = uibutton(app.UIFigure, 'push');
            app.CalculateDenavitHartenbergButton.ButtonPushedFcn = createCallbackFcn(app, @CalculateDenavitHartenbergButtonPushed, true);
            app.CalculateDenavitHartenbergButton.Position = [468 23 173 22];
            app.CalculateDenavitHartenbergButton.Text = 'Calculate Denavit Hartenberg';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = DHConverter_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end