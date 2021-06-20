function [a, d, alpha, tetha] = calculateDenavitHartenbergParam(basisVektorList,quaternionZeroList, quaternionVektorList)
    % Startinitialiserung 
    d_value_before=0;
    a_value_before=0;
    alpha_value_before=0;
    tetha_value_before = 0;
    for i=1:length(quaternionZeroList) % for Schleife von Link 1 bis Link n_max
        q0 = quaternionZeroList(i); % i-te Wert aus Vektor wird übernommen
        q  = quaternionVektorList(i,:); % i-te Zeile aus qVektor wird übernommen
        r  = basisVektorList(i,:); % i-te Zeile aus rVektor wird übernommen

        Q =  UnitQuaternion(Quaternion([q0,q]));
        
        %Berechnet Rotationsmatrix aus Quaternionen
        RotMat = Q.R;
        % Berechnung von a_i:
        acos(RotMat(1,1));
        if acos(RotMat(1,1)) == tetha_value_before % RotMat(1,1) entspricht cos(tetha)
            tetha_i = 0;
        else
            tetha_i = abs(acos(RotMat(1,1)) - tetha_value_before);
            tetha_value_before = acos(RotMat(1,1));
        end
        
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
        
        % store value in the output
        a(i,1) = a_i;
        d(i,1) = d_i;
        alpha(i,1) = alpha_i;
        tetha(i,1) = tetha_i;
    end % for Schleifen Ende
end

