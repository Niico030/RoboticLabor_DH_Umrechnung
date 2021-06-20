function plausible = checkPlausibilityBasiskoorsystem(Basiskoorsystem)
    [r, c] = size(Basiskoorsystem)
    if r == 1
        plausible = 1;
        return;
    end
    
    for i=1: length(Basiskoorsystem)-1
        if Basiskoorsystem(i,1) == Basiskoorsystem((i+1),1)  || Basiskoorsystem(i,2) == Basiskoorsystem((i+1),2)  || Basiskoorsystem(i,3) == Basiskoorsystem((i+1),3) % Überprüfung der Koordinaten Link i und Link i+1 
            plausible=1;
        else
            plausible=0; % Plausibilität ist nicht gegeben (error==1)
            return; % Schleifenabbruch
        end
    end
end

