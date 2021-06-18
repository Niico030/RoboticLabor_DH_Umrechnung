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
        
%% Vorgehensweise



%% Durchführung
clear all;
clc;

d_old=0;
a_old=0;
alpha_old=0;
error=0;

% Eingabe Quaternionen:
q0_list=[0.7071 0.7071 0 0.7071 1 1];
qVek_list=[0.7071 0 0; 0.7071 0 0; 1 0 0; -0.7071 0 0; 0 0 0; 0 0 0];
rVek_list=[0 0 0; 0.56 0 0; 0.56 0 0; 0.56 0 -0.515; 0.56 0 -0.515; 0.56 0 -0.425];

% Überprüfung Plausibilität Basisvektoren:
    % Überprüfung mindestens eine Variable (x,y,z) der Basiskoordinaten muss
    % gleich mit dem vorherigen Link sein, damit Gelenke miteinerander
    % verbunden sind

for i=1: length(rVek_list)-1
    
    if rVek_list(i,1) == rVek_list((i+1),1)  || rVek_list(i,2) == rVek_list((i+1),2)  || rVek_list(i,3) == rVek_list((i+1),3) 
    else
        disp('Link Objekte können nicht miteinander verbunden werden')
        error=1;
        break;
    end
end



if error==0 
    for i=1: length(q0_list)
        disp('----------------Link Objekt: ----------------')
        disp(i)
        q0 = q0_list(i)
        q  = qVek_list(i,:)
        r  = rVek_list(i,:)

        Q =  UnitQuaternion(Quaternion([q0,q]))
        RotMat = Q.R

        d = r(3)
        if d == d_old
            d = 0;
        else
            d = abs(d_old - r(3));
            d_old = r(3);
        end

        %Winkel 'alpha_old' aus Zeile 3, Spalte 3
        acos(RotMat(3,3))
        if acos(RotMat(3,3)) == alpha_old
            alpha_rad = 0
        else
            alpha_rad = abs(acos(RotMat(3,3)) - alpha_old)  %[rad]
            alpha_old = acos(RotMat(3,3));
        end

        a = r(1)
        if a == a_old
            a = 0
        else
            a = abs(a_old - r(1));
            if a_old == 0
                a = r(1);
            end
            a_old = r(1);
        end



        %Syntax: L(i) = Link([theta, d, a , alpha_old])
        L(i) = Link([0, d, a, alpha_rad]);

    end 
    Robot = SerialLink(L, 'name', 'Robo')

    %Erstellen einer Winkel-Postion 
    theta = [0 0 0 0 0 0];
    
    Robot.plot(theta)
    
end
 