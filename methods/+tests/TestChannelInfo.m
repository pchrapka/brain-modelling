classdef TestChannelInfo < matlab.unittest.TestCase
    
    properties
        params_aal;
    end
    
    properties (TestParameter)
        prop = {'region','hemisphere'};
    end
    
    methods (TestClassSetup)
        function setup(testCase)
            testCase.params_aal.label = {'Precentral R','Lingual L','Paracentral Lobule L','Vermis 4 5'};
            testCase.params_aal.coord = randn(4,3);
            testCase.params_aal.region = {'Motor','Occipital','Parietal','Cerebellum'};
            testCase.params_aal.region_order = [2 7 5 9];
            testCase.params_aal.hemisphere = {'Right','Left','Left','None'};
            testCase.params_aal.hemisphere_order = [1 3 3 2];
        end
    end
    
    methods (Test)
        function test_ChannelInfo_label(testCase)
            
            label = {'Channel1'};
            a = ChannelInfo(label);
            
            testCase.verifyEqual(a.label,label);
            testCase.verifyEmpty(a.coord);
            testCase.verifyEmpty(a.region);
            testCase.verifyEmpty(a.region_order);
            testCase.verifyEmpty(a.hemisphere);
            testCase.verifyEmpty(a.hemisphere_order);
            
            % check no input
            testCase.verifyError(...
                @() ChannelInfo(), 'MATLAB:minrhs');
            
            % check string input
            testCase.verifyError(...
                @() ChannelInfo(label{1}), 'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_ChannelInfo_coord(testCase)
            
            label = {'Channel1','Channel2'};
            coord = [1 2 3; 2 3 4];
            a = ChannelInfo(label,'coord',coord);
            
            testCase.verifyEqual(a.label,label);
            testCase.verifyEqual(a.coord,coord);
            testCase.verifyEmpty(a.region);
            testCase.verifyEmpty(a.region_order);
            testCase.verifyEmpty(a.hemisphere);
            testCase.verifyEmpty(a.hemisphere_order);
            
            % less coords than labels
            testCase.verifyError(...
                @() ChannelInfo(label,'coord',randn(1,3)), 'ChannelInfo:InvalidInput');
            % more cords than labels
            testCase.verifyError(...
                @() ChannelInfo(label,'coord',randn(3,3)), 'ChannelInfo:InvalidInput');
            
            % 1 dim
            testCase.verifyError(...
                @() ChannelInfo(label,'coord',randn(2,1)), 'ChannelInfo:InvalidInput');
            % 4 dim
            testCase.verifyError(...
                @() ChannelInfo(label,'coord',randn(2,4)), 'ChannelInfo:InvalidInput');
            % multi dim
            testCase.verifyError(...
                @() ChannelInfo(label,'coord',randn(2,3,2)), 'ChannelInfo:InvalidInput');
            
            % test 2 dim expansion
            label = {'Channel1','Channel2'};
            coord = randn(2,2);
            a = ChannelInfo(label,'coord',coord);
            
            testCase.verifyEqual(a.label,label);
            % should expand to 3 dim
            testCase.verifyEqual(a.coord,[coord [0;0]]);
        end
        
        function test_ChannelInfo_prop(testCase,prop)
            
            label = {'Channel1','Channel2'};
            name = {'Prop1','Prop2'};
            name_order = [1 2];
            coord = [1 2 3; 2 3 4];
            
            prop_order = [prop '_order'];
            
            % add prop names
            a = ChannelInfo(label,'coord',coord,prop,name);
            
            testCase.verifyEqual(a.label,label);
            testCase.verifyEqual(a.coord,coord);
            testCase.verifyEqual(a.(prop),name);
            testCase.verifyEmpty(a.(prop_order));
            
            % add order and prop names
            a = ChannelInfo(label,'coord',coord,prop,name,prop_order,name_order);
            
            testCase.verifyEqual(a.label,label);
            testCase.verifyEqual(a.coord,coord);
            testCase.verifyEqual(a.(prop),name);
            testCase.verifyEqual(a.(prop_order),name_order);
            
            % add order without prop names
            a = ChannelInfo(label,'coord',coord,prop_order,name_order);
            
            testCase.verifyEqual(a.label,label);
            testCase.verifyEqual(a.coord,coord);
            testCase.verifyEmpty(a.(prop));
            testCase.verifyEmpty(a.(prop_order));
            
            % less prop names than labels
            testCase.verifyError(...
                @() ChannelInfo(label,'coord',coord,prop,name(1)),...
                'ChannelInfo:InvalidInput');
            % more prop names than labels
            testCase.verifyError(...
                @() ChannelInfo(label,'coord',coord,prop,[name, 'this one']),...
                'ChannelInfo:InvalidInput');
            
            % less prop orders than labels
            testCase.verifyError(...
                @() ChannelInfo(label,'coord',coord,prop,name,prop_order,name_order(1)),...
                'ChannelInfo:InvalidInput');
            % more prop orders than labels
            testCase.verifyError(...
                @() ChannelInfo(label,'coord',coord,prop,name,prop_order,[name_order 3]),...
                'ChannelInfo:InvalidInput');
        end
        
        function test_populate_aal(testCase,prop)
            
            a = ChannelInfo(testCase.params_aal.label,'coord',testCase.params_aal.coord);
            a.populate('aal');
            
            prop_order = [prop '_order'];
            testCase.verifyEqual(a.(prop),testCase.params_aal.(prop));
            testCase.verifyEqual(a.(prop_order),testCase.params_aal.(prop_order));
            
            % try populating again
            testCase.verifyWarning(...
                @() a.populate('aal'), 'ChannelInfo:AlreadySet');
        end
        
        function test_populate_aal2(testCase,prop)
                
            prop_order = [prop '_order'];
            % add prop names
            a = ChannelInfo(testCase.params_aal.label,'coord',testCase.params_aal.coord,...
                prop,testCase.params_aal.(prop));
            % try populating
            testCase.verifyWarning(...
                @() a.populate('aal'), 'ChannelInfo:AlreadySet');
            
            % try adding prop order first
            a = ChannelInfo(testCase.params_aal.label,'coord',testCase.params_aal.coord,...
                prop_order,testCase.params_aal.(prop_order));
            % populate should produce no warning
            testCase.verifyWarningFree(@() a.populate('aal'));
            
        end
        
        function test_populate_default(testCase)
            
            a = ChannelInfo(testCase.params_aal.label,...
                'coord',testCase.params_aal.coord,...
                'region',testCase.params_aal.region,...
                'hemisphere',testCase.params_aal.hemisphere);
            a.populate('default');
            
            testCase.verifyEqual(a.region,testCase.params_aal.region);
            testCase.verifyEqual(a.hemisphere,testCase.params_aal.hemisphere);
            
            % should have same amount of uniques
            testCase.verifyEqual(length(unique(a.region_order)),....
                length(unique(testCase.params_aal.region_order)));
            testCase.verifyEqual(length(unique(a.hemisphere_order)),....
                length(unique(testCase.params_aal.hemisphere_order)));
            
            a = ChannelInfo(testCase.params_aal.label,...
                'coord',testCase.params_aal.coord);
           testCase.verifyError(...
                @() a.populate('default'), 'ChannelInfo:NoInformation'); 
            
            a = ChannelInfo(testCase.params_aal.label,...
                'coord',testCase.params_aal.coord,....
                'region',testCase.params_aal.region);
           testCase.verifyError(...
                @() a.populate('default'), 'ChannelInfo:NoInformation'); 
            
            a = ChannelInfo(testCase.params_aal.label,...
                'coord',testCase.params_aal.coord,....
                'hemisphere',testCase.params_aal.hemisphere);
           testCase.verifyError(...
                @() a.populate('default'), 'ChannelInfo:NoInformation'); 
        end
    end
    
end