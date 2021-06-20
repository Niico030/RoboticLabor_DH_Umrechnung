# RoboticLabor_DH_Umrechnung

Verpflichtende Hausübung Robotertechnik SS21 
Gruppe: Muhammad Hanif, Till Gostner, Nico Mayer
   
Aufgabenstellung: 
Erstellen Sie unter Verwendung der Denavit- Hartenberg Konvention einen Algorithmus:
1. Bei dem der Nutzer, den Vektor zum Ursprung des i- ten Koordinatensystems in Basiskoordinaten angibt.
2. Die Orientierung des i-ten Koordinatensystem relativ zur Bsais in Form von Quaternionen (Euler Rodrigues Parameter) angibt
3. Diese Daten sollen vom Benutzer in Form einer Eingabeaufforderung abgefragt werden
4. Die Denavit Hartenberg Parameter berechnet werden
5. Der resultierende Roboter mit der Robotic Toolbox gezeichnet wird
        
Vorgehensweise zum Lösen der Hausübung 

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
