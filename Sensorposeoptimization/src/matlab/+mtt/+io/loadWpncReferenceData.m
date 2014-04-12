function [pos_ts, ref_ts] = loadWpncReferenceData()
coms = {'\\ds9\Measurements\2011-WPNC-CricketIR\abxcom9', '\\ds9\Measurements\2011-WPNC-CricketIR\abxcom10', '\\ds9\Measurements\2011-WPNC-CricketIR\abxcom11', '\\ds9\Measurements\2011-WPNC-CricketIR\abxcom12'};
events = readEventDescription('\\ds9\Measurements\2011-WPNC-CricketIR\CalibrationMeasurements.txt');
refs = parseReferencePositions('\\ds9\Measurements\2011-WPNC-CricketIR\BeaconsOverheadPositions.yaml');
refs = parseReferencePositions('\\ds9\Measurements\2011-WPNC-CricketIR\ReferencePointPositions.yaml', refs);
comsshort = {'abxcom9', 'abxcom10', 'abxcom11', 'abxcom12'};

%tsc_refs = tscollection;
events.coord = [];

for i = 1:numel(events.time)
    idx = find(strcmp({refs{:,1}}, events.id{i}), 1,'first');
    if ~isempty(idx)
        events.coord(i, :) = refs{idx, 2};
    else
        events.coord(i, :) = [nan nan nan];
    end
end


tsc_refs = timeseries(events.coord, events.time*100e-9, 'Name','ref');
count = 1;
stplVals = {};
for i = 1:numel(coms)
    tplVals{i} = load([coms{i} '.txt'], 'ascii');
end

pos_ts ={};
ref_ts={};

for j=1:2:numel(events.time)
    tsc = tscollection;
    for i = 1:numel(coms)
        tstart = events.time(j);
        tend = events.time(j+1);
        tidx = tplVals{i}(:,1) >= tstart & tplVals{i}(:,1) <= tend;
        basename = comsshort{i};
        mapping = {{[2:9],[10:17]},{[2:9],[10:17]},{[2:9],[10:17]},{[2:9],[10:17]}};
        
        for itMap = 1: numel(mapping{i});
            curMap = mapping{i}{itMap};
            curName = [basename '_' num2str(itMap-1)];
            data = tplVals{i}(tidx, curMap);
            time = tplVals{i}(tidx, 1)*100e-9;
            ts = timeseries(data, time,...
                'Name', curName);
            ts = setinterpmethod(ts, @nearestNeighbourInterpolation);
            urMap = mapping{i}{itMap};
            
            if ~isempty(tsc)
                ts = ts.resample(tsc.Time);
            end
            tsc = tsc.addts(ts);
        end
        count = count+1;
    end
    ref_ts{(j+1)/2} = tsc_refs.resample(tsc.Time);
    pos_ts{(j+1)/2} = tsc;
end