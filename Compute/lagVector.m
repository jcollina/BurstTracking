function vectorStruct = lagVector(lagMat,chidx,chGrid)

transF = [-1 -1 ; -1 0 ; -1 1 ; 0 -1 ; 0 0 ; 0 1 ; 1 -1 ; 1 0 ; 1 1];

%%
vector = zeros(2,length(chidx));
loc = zeros(2,length(chidx));

avgLag = zeros(1,length(chidx));

for chan = 1:length(chidx)

    [y,x] = ind2sub(size(chGrid),find(chGrid==chidx(chan)));
    square = NaN(1,9);
    for ii = 1:9
        
        idx1 = transF(ii,1) + y;
        idx2 = transF(ii,2) + x;
        if ~(idx1 > 11 || idx1 < 1 || idx2 > 6 || idx2 < 1)
            chT = find(chidx==chGrid( idx1, idx2 ));

            if ~isempty(chT)
                sig = sign(chT - chan);
                square(ii) = sig * lagMat(min([chan,chT]),max([chan,chT]));
            end
        end
    end
    vectorTemp = transF;
    vectorTemp([1,3,7,9],:) = vectorTemp([1,3,7,9],:) .* sqrt(2);
    vectorTemp = nanmean(vectorTemp.*square');
    %vectorTemp = vectorTemp./(norm(vectorTemp));
    vector(:,chan) = [ -1*vectorTemp(2) vectorTemp(1) ];%cartesian, direction of burst propogation
    % example: vector = [ -1 -1 ] means that overall, the channels NE precede
    % the center channel and the channels SW follow.
    loc(:,chan) = [(x-1), (11-y)+1];
    avgLag(chan) = nanmean(abs(square([1:4,6:9])));
end

vectorStruct = struct(...
    'avgLag',avgLag,...
    'loc',loc,...
    'vector',vector...
    );
end