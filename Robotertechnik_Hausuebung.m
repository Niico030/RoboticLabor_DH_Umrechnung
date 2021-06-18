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
    % 3) Plausibilitätsprüfung der vom Benutzer eingegeben Werte (error==1
    %       => Abbruch!
    % 4) Aus den Quaternionen die Rotationsmatrix berechnen
    %       => aus RotMat lassen sich theta und alpha bestimmen
    % 5) Aus den Vektoren lassen sich die Abstände a und d berechenen
    %       => Homogenematrix nicht notwendig, RotMat und Vektoren
    %          ausreichend zur Bestimmung der Denavit Hartenbergparameter
    % 6) Einzelne Linkobjekte werden erstellt
    % 7) Erstellen von Seriallink Objekt des Robotermodells
    % 8) Roboter plotten

%% Durchführung
clear;
clc;

% Eingabeaufforderung Nutzer:
%q0:
q0_list=[0.7071 0.7071 0 0.7071 1 1];
%q1, q2, q3:
qVek_list=[0.7071 0 0; 0.7071 0 0; 1 0 0; -0.7071 0 0; 0 0 0; 0 0 0];
%Vektor zum Ursprung in Basiskoordinaten:
rVek_list=[0 0 0; 0.56 0 0; 0.56 0 0; 0.56 0 -0.515; 0.56 0 -0.515; 0.56 0 -0.425];


%% Überprüfung Plausibilität Quaternion:
    % 1) q0, q1, q2, q3 müssen <= 1 sein
    
error_quaternion=0;
    
for i=1: length(qVek_list)
    if qVek_list(i,1) <= 1  && qVek_list(i,2) <= 1   && qVek_list(i,3) <= 1  % Überprüfung der der Quaternionen q1, q2, q3 <=1
    else
        disp('Bitte Eingabe der Quaternionen überprüfen')
        error_quaternion=1; % Plausibilität ist nicht gegeben (error_quaternionen==1)
        break; % Schleifenabbruch
    end
end

for i=1: length(q0_list)
    if q0_list(i) <= 1 % Überprüfung der Quaternion q0 <=1
    else
        disp('Bitte Eingabe der Quaternionen überprüfen')
        error_quaternion=1; % Plausibilität ist nicht gegeben (error_quaternionen==1)
        break; % Schleifenabbruch
    end
end

%% Überprüfung Plausibilität Basisvektoren:
    % Überprüfung mindestens eine Variable (x,y,z) der Basiskoordinaten muss
    % gleich mit dem vorherigen Link sein, damit Gelenke miteinerander
    % verbunden sind

error=0;
    
for i=1: length(rVek_list)-1
    if rVek_list(i,1) == rVek_list((i+1),1)  || rVek_list(i,2) == rVek_list((i+1),2)  || rVek_list(i,3) == rVek_list((i+1),3) % Überprüfung der Koordinaten Link i und Link i+1 
    else
        disp('Link Objekte können nicht miteinander verbunden werden- Bitte Vektoren überprüfen')
        error=1; % Plausibilität ist nicht gegeben (error==1)
        break; % Schleifenabbruch
    end
end

%% Berechnungsalgorithmus

% Startinitialiserung 
d_value_before=0;
a_value_before=0;
alpha_value_before=0;

% length(q0_list) gibt Länge des Array aus und somit Anzahl der Link Objekte
n_max= length(q0_list);  

if error==0 && error_quaternion==0 % Wenn keine Probleme bei der Plausibilitätsprüfung aufgetreten sind (error == 0 und error_quaternion)
    for i=1: n_max % for Schleife von Link 1 bis Link n_max
        disp('---------------------------')
        disp('Link Objekt: ') % Anzeigen der Nummer des Link Objektes 
        disp(i)
        q0 = q0_list(i) % i-te Wert aus Vektor wird übernommen
        q  = qVek_list(i,:) % i-te Zeile aus qVektor wird übernommen
        r  = rVek_list(i,:) % i-te Zeile aus rVektor wird übernommen

        Q =  UnitQuaternion(Quaternion([q0,q]));
        
        %Berechnet Rotationsmatrix aus Quaternionen
        RotMat = Q.R

        % Berechnung von a_i: 
            % Abstand zwischen der zi-1 und zi Achse entlang der xi Achse
        a_i = r(1); % a_i bekommt den Wert aus dem Vektor r zugewiesen
        if a_i == a_value_before % Wenn a_i = a_i-1 ist dann ist der Abstand ai=0
            a_i = 0;
        else
            a_i = abs(a_value_before - r(1)); % wenn a_i ungleich a_i-1 dann wird vom vorherigen Wert der r(1) Wert subtrahiert
            if a_value_before == 0 % wenn a_i-1 = 0 ist dann beträgt der Wert a_i = r(1) 
                a_i = r(1);
            end
            a_value_before = r(1); % a_i-1 bekommt den Wert r(1) zugewiesen für nächste Schleife 
        end
        
        % Berechnung von d_i: 
            % Abstand zwischen der xi-1 und xi Achse entlang der Zi-1 Achse
        d_i = r(3); % Analog a_i
        if d_i == d_value_before
            d_i = 0;
        else
            d_i = abs(d_value_before - r(3));
            d_value_before = r(3);
        end

        % Berechnung von alpha_i:  
            % Winkel zwischen der zi und zi-i Achse entlang xi Achse
        acos(RotMat(3,3)); 
        if acos(RotMat(3,3)) == alpha_value_before % RotMat(3,3) entspricht cos(alpha)
            alpha_i = 0;
        else
            alpha_i = abs(acos(RotMat(3,3)) - alpha_value_before);
            alpha_value_before = acos(RotMat(3,3));
        end



        % L(i) = Link([theta, d, a , alpha])
        L(i) = Link([0, d_i, a_i, alpha_i]);

    end % for Schleifen Ende
    % Zusammenbau der einzel Link Objekte zu Roboter
    Robot = SerialLink(L, 'name', 'Roboter Hausuebung SS21')
    
    % Winkel zwischen der xi und xi-1 Achse entlang der zi-1 Achse
        % kann alternativ durch RotMat(1,1) bestimmt werden über arccos
    theta = [0 0 0 0 0 0];
    
    % Plot des Roboters
    Robot.plot(theta)
    
end % if Bedingung ende
 