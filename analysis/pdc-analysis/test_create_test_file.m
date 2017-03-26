%% test_create_test_file

% not working

%% save test file
create_pdc_test = false;
if create_pdc_test
    create_pdc_test_file = false;
    create_pdc_test_meta_file = false;
    
    test_outdir = fullfile('output','test');
    if ~exist(test_outdir,'dir')
        mkdir(test_outdir);
    end
    
    pdc_test_file = fullfile(test_outdir,'pdc-test.mat');
    pdc_test_meta_file = fullfile(test_outdir,'pdc-meta-test.mat');
    
    if create_pdc_test_file
        ntestsamples = 20;
        pdcdata = loadfile(pdc_files{1});
        
        testdata = [];
        testdata.pdc = pdcdata.pdc(1:ntestsamples,:,:,:);
        
        save_parfor(pdc_test_file, testdata);
        clear pdcdata;
        clear testdata
    end
    
    if create_pdc_test_meta_file
        testdata = [];
        testdata.fsample = fsample;
        testdata.atlas_name = atlas_name;
        testdata.patch_labels = patch_labels;
        testdata.patch_centroids = patch_centroids;
        testdata.time = time;
        testdata.pdcfile = pdc_test_file;
        
        save_parfor(pdc_test_meta_file,testdata);
        clear testdata
    end
end