function [plausible, msg] = checkPlausibilityQuaternion(quaternionZeros,quaternionVektors)
    for i=1: length(quaternionZeros)
        if quaternionVektors(i,1) <= 1  && quaternionVektors(i,2) <= 1   && quaternionVektors(i,3) <= 1  % Überprüfung der der Quaternionen q1, q2, q3 <=1
        else
            msg = 'Quaternion muss kleiner als 1!\n - Bitte Eingabe der Quaternionen überprüfen';
            plausible=0; % Plausibilität ist nicht gegeben (error_quaternionen==1)
            return;
        end
    end
    
    for i=1: length(quaternionZeros)
        if quaternionZeros(i) <= 1 % Überprüfung der Quaternion q0 <=1
        else
            msg = 'Quaternion muss kleiner als 1!\n - Bitte Eingabe der Quaternionen überprüfen';
            plausible=0; % Plausibilität ist nicht gegeben (error_quaternionen==1)
            return; % Schleifenabbruch
        end
    end
    
    for i=1: length(quaternionZeros) 

       AbbruchKrit = quaternionZeros(i)^2+quaternionVektors(i,1)^2+quaternionVektors(i,2)^2+quaternionVektors(i,3)^2;

       if AbbruchKrit == 0
            msg = 'Bitte Eingabe der Quaternionen überprüfen!\nq0^2+q1^2+q2^2+q3^2 ist ungleich 1';
            plausible=0; % Plausibilität ist nicht gegeben (error_quaternionen==1)
            return; % Schleifenabbruch
       end

    end
    msg = "ok";
    plausible = 1;
end

