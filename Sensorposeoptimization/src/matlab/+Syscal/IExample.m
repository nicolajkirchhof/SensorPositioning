classdef IExample 
    %EXAMPLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        preprocessor
        filter
        extractor %should be merged
        tracker
        
        State;
        Id = 'Unknown'
    end
    
    methods
        function self = Example() 
            self.reset();
        end
        function self = reset(self)
            self.State.filterInputs.Measurement =  {[]}; %meta :-D
            self.State.filterInputs.ControlInput = 0;
            self.State.hypotheses = [];
            self.State.tracker_hypotheses = [];
        end
        
        function self = eval(self, data, reference, recordList, waitbar)
            self.reset();
            
            %range: the index into the data
            if nargin<  5
                waitbar = Tools.Waitbar();
            end
            
            
           % numElements = numel(data);
            
            
            numIterations =  data.length();
            cnt = 1;
            tElapsed = realmax;
            
            %%
            dataNames = data.gettimeseriesnames();
            numDataEntries = numel(dataNames);
            %convert timeseries
            tscSensorData = cell(1,numDataEntries);
            for itTsc=1:numDataEntries
                tscSensorData{itTsc} = data.(dataNames{itTsc});
            end
            %%
            %%
            if  ~isempty(reference)
                refDataNames = reference.gettimeseriesnames();
                numRefEntries = numel(refDataNames);
                %convert timeseries
                tscRefData = cell(1,numRefEntries);
                for itTsc=1:numRefEntries
                    tscRefData{itTsc} = reference.(refDataNames{itTsc});
                end
            else
                tscRefData = cell(0);
            end
            %%
            
            %% The magic happens
            for i = 1 : numIterations
                %% Preamble
                %self.prestep();
                tStart = tic;
                if (cnt>numIterations), break;end;
                %minTime = round(min(minTime,(numIterations-cnt)*tElapsed));
                minTime  = round( (numIterations-cnt)*tElapsed);
                wbMsg = ['Remaining seconds: ', num2str(minTime)];
                if ~isempty(waitbar)
                    if waitbar.update(cnt/numIterations, wbMsg),break;end;
                end
                cnt = cnt+1;
                %% Execute code
                content = cell(1,numDataEntries);
                for itTsc=1:numDataEntries
                    content{itTsc} = tscSensorData{itTsc}.getdatasamples(i)';
                end
                
                self.step(content);
                
                if nargin > 3 && ~isempty(recordList)
                    record = Tools.ListItem();
                    
                    record.Item.iteration  = i;
                    if (~isempty(tscRefData))
                        for itRef=1:numel(tscRefData)
                            self.State.reference.State(:,itRef)    = tscRefData{itRef}.getdatasamples(i)';
                        end
                       self.State.reference.Cardinality = numel(tscRefData);
                    end
                    record.Item = self.State;
                    recordList.push_back( record );
                end
                %% plotting etc.
                %self.poststep();
                tElapsed = toc(tStart);
            end
            if ~isempty(waitbar)
                delete(waitbar);
            end
        end
    end
    methods
        
        function self = step(self, data)
            if ~isempty(self.preprocessor)
                data = self.preprocessor.apply(data);
            end
            
            hypotheses   = self.State.hypotheses;
            filterInputs = self.State.filterInputs;
            
            
            %% RUN            
            filterInputs.Measurement =  data;
            filterInputs.ControlInput = 0;
            
            
            if ~isempty(self.filter)
                hypotheses = self.filter.filter( filterInputs, hypotheses );
            else
                hypotheses = [];
            end
      
            
            %% Extract States % pure estimate
            if ~isempty(self.extractor)
                estimate = self.extractor.extract( hypotheses );
            else
                estimate = [];
            end
            
            %% Label to ID
            if ~isempty(self.tracker)
                %%fake
                tracker_input.State = estimate.State;
                tracker_input.Measurement = filterInputs.Measurement;
                tracker_hypotheses = self.tracker.Filter.filter( tracker_input, self.State.tracker_hypotheses);
                track  = self.tracker.Extractor.extract( tracker_hypotheses );
            else
                track = [];
                tracker_hypotheses = [];
            end
            
            self.State.hypotheses = hypotheses;
            self.State.estimate = estimate;
            self.State.filterInputs = filterInputs;
            self.State.track = track;
            
            self.State.tracker_hypotheses = tracker_hypotheses;
            
        end
        
    end
    
end

