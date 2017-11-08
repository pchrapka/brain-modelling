%% paper_copy_images

outdir = fullfile('publications','paper');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

images = [];
k = 1;

%% gPDC
images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-03-MCMTLOCCD_TWL4-T20-C7-P4-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i6-opnone-thresh0.00-0.0000-0.0049.eps');
    %'2017-07-14-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i6-opnone-thresh0.00-0.0000-0.0049.eps');
    %'2017-06-20-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f512-ds4-seed-in-i5-opnone-thresh0.00-0.0000-0.0098.eps');
images(k).file_out = 'hemileft-to-auditory-left-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-03-MCMTLOCCD_TWL4-T20-C7-P4-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i1-opnone-thresh0.00-0.0000-0.0049.eps');
    %'2017-07-14-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i1-opnone-thresh0.00-0.0000-0.0049.eps');
    %'2017-06-20-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f512-ds4-seed-in-i1-opnone-thresh0.00-0.0000-0.0098.eps');
images(k).file_out = 'hemileft-to-temporal-left-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-03-MCMTLOCCD_TWL4-T20-C7-P4-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i7-opnone-thresh0.00-0.0000-0.0049.eps');
    %'2017-07-14-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i7-opnone-thresh0.00-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-motor-left-paper.eps';
k = k+1;

%% gPDC surrogate - coupling
images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-03-MCMTLOCCD_TWL4-T20-C7-P4-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i6-opnone-threshsig-estimate_ind_channels-0.0000-0.0049.eps');
    %'2017-08-02-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i6-opnone-threshsig-estimate_ind_channels-0.0000-0.0049.eps');
    %'2017-06-22-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f512-ds4-seed-in-i5-opnone-threshsig-estimate_ind_channels-0.0000-0.0098.eps');
images(k).file_out = 'hemileft-to-auditory-left-surrogate-coupling-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-03-MCMTLOCCD_TWL4-T20-C7-P4-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i1-opnone-threshsig-estimate_ind_channels-0.0000-0.0049.eps');
    %'2017-08-02-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i1-opnone-threshsig-estimate_ind_channels-0.0000-0.0049.eps');
    %'2017-06-22-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f512-ds4-seed-in-i1-opnone-threshsig-estimate_ind_channels-0.0000-0.0098.eps');
images(k).file_out = 'hemileft-to-temporal-left-surrogate-coupling-paper.eps';
k = k+1;


images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-03-MCMTLOCCD_TWL4-T20-C7-P4-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i7-opnone-threshsig-estimate_ind_channels-0.0000-0.0049.eps');
    %'2017-08-02-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i7-opnone-threshsig-estimate_ind_channels-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-motor-left-surrogate-coupling-paper.eps';
k = k+1;

%% gPDC surrogate - non-stationary
images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-03-MCMTLOCCD_TWL4-T20-C7-P4-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i6-opnone-threshsig-estimate_stationary_ns-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-auditory-left-surrogate-ns-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-03-MCMTLOCCD_TWL4-T20-C7-P4-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i1-opnone-threshsig-estimate_stationary_ns-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-temporal-left-surrogate-ns-paper.eps';
k = k+1;


images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-03-MCMTLOCCD_TWL4-T20-C7-P4-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i7-opnone-threshsig-estimate_stationary_ns-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-motor-left-surrogate-ns-paper.eps';
k = k+1;

%% gPDC standard deviation
% images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
%     'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
%     '2017-11-07-MCMTLOCCD_TWL4-T20-C7-P4-lambda0.9900-gamma1.000e-05-p100-removed-pdc-dynamic-diag-f2048-41-ds4-std-seed-in-i6-opnone-0.0000-0.0049.eps');
%     %'2017-07-14-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-std-seed-in-i6-opnone-0.0000-0.0049.eps');
% images(k).file_out = 'hemileft-to-auditory-left-std-paper.eps';
% k = k+1;
% 
% images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
%     'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
%     '2017-11-07-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p100-removed-pdc-dynamic-diag-f2048-41-ds4-std-seed-in-i6-opnone-0.0000-0.0049.eps');
%     %'2017-07-28-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p100-removed-pdc-dynamic-diag-f2048-41-ds4-std-seed-in-i6-opnone-0.0000-0.0049.eps');
% images(k).file_out = 'hemileft-to-auditory-left-std-100-paper.eps';
% k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-07-MCMTLOCCD_TWL4-T20-C7-P4-lambda0.9900-gamma1.000e-05-p100-removed-pdc-dynamic-diag-f2048-41-ds4-std-seed-in-i1-opnone-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-temporal-left-std-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-07-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p100-removed-pdc-dynamic-diag-f2048-41-ds4-std-seed-in-i1-opnone-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-temporal-left-std-100-paper.eps';
k = k+1;

%% gPDC H=100
images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-03-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i6-opnone-thresh0.00-0.0000-0.0049.eps');
    %'2017-07-14-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i6-opnone-thresh0.00-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-auditory-left-h100-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-03-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i1-opnone-thresh0.00-0.0000-0.0049.eps');
    %'2017-07-14-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i1-opnone-thresh0.00-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-temporal-left-h100-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-03-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i7-opnone-thresh0.00-0.0000-0.0049.eps');
    %'2017-07-14-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i7-opnone-thresh0.00-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-motor-left-h100-paper.eps';
k = k+1;

%% gPDC H=100 surrogate - coupling
images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-04-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i6-opnone-threshsig-estimate_ind_channels-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-auditory-left-h100-surrogate-coupling-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-04-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i1-opnone-threshsig-estimate_ind_channels-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-temporal-left-h100-surrogate-coupling-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-04-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i7-opnone-threshsig-estimate_ind_channels-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-motor-left-h100-surrogate-coupling-paper.eps';
k = k+1;

%% gPDC H=100 surrogate - non-stationary
images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-03-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i6-opnone-threshsig-estimate_stationary_ns-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-auditory-left-h100-surrogate-ns-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-03-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i1-opnone-threshsig-estimate_stationary_ns-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-temporal-left-h100-surrogate-ns-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-03-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i7-opnone-threshsig-estimate_stationary_ns-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-motor-left-h100-surrogate-ns-paper.eps';
k = k+1;

%% connectivity matrices
images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-07-MCMTLOCCD_TWL4-T20-C7-P4-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-adjacency-idx192-768-0.0000-0.0024.eps');
    %'2017-07-14-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-adjacency-idx192-768-0.0000-0.0024.eps');
    %'2017-06-20-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f512-ds4-adjacency-idx192-768-0.0000-0.0098.eps');
images(k).file_out = 'hemileft-adjacency-summary.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemiright-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-08-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-adjacency-idx192-768-0.0000-0.0024.eps');
    %'2017-07-14-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-adjacency-idx192-768-0.0000-0.0024.eps');
    %'2017-06-20-MCMTLOCCD_TWL4-T20-C7-P3-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f512-ds4-adjacency-idx192-768-0.0000-0.0098.eps');
images(k).file_out = 'hemiright-adjacency-summary.eps';
k = k+1;

%% connectivity matrices H=100
images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-07-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-adjacency-idx192-768-0.0000-0.0024.eps');
    %'2017-07-14-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-adjacency-idx192-768-0.0000-0.0024.eps');
images(k).file_out = 'hemileft-adjacency-summary-h100.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemiright-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-11-07-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-adjacency-idx192-768-0.0000-0.0024.eps');
    %'2017-07-14-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-adjacency-idx192-768-0.0000-0.0024.eps');
images(k).file_out = 'hemiright-adjacency-summary-h100.eps';
k = k+1;

%% connectivity matrices H=100, other subjects

% image_type = 'png';
image_type = 'eps'; % ideal for publication, however problem viewing on ubuntu when generated with R2015b
subject = [];
j=1;
subject(j).subject = 's05';
subject(j).date = '2017-11-07';
subject(j).order_left = '5';
subject(j).order_right = '5';
j = j+1;

subject(j).subject = 's09';
subject(j).date = '2017-11-07';
subject(j).order_left = '8';
subject(j).order_right = '7';
j = j+1;

subject(j).subject = 's13';
subject(j).date = '2017-10-31';
subject(j).order_left = '7';
subject(j).order_right = '5';
j = j+1;

for j=1:length(subject)
    images(k).file = fullfile('output',['std-' subject(j).subject '-10'],'aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
        'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
        [subject(j).date '-MCMTLOCCD_TWL4-T100-C7-P' subject(j).order_left '-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-adjacency-idx192-768-0.0000-0.0024.' image_type]);
    images(k).file_out = ['hemileft-adjacency-summary-h100-' subject(j).subject '.' image_type];
    k = k+1;
    
    images(k).file = fullfile('output',['std-' subject(j).subject '-10'],'aal-coarse-19-outer-nocer-hemiright-audr2-v1r2',...
        'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
        [subject(j).date '-MCMTLOCCD_TWL4-T100-C7-P' subject(j).order_right '-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-adjacency-idx192-768-0.0000-0.0024.' image_type]);
    images(k).file_out = ['hemiright-adjacency-summary-h100-' subject(j).subject '.' image_type];
    k = k+1;
end

%% rauschecker model
images(k).file = fullfile('output','img','2017-07-14-conn-rauschecker-scott-adjacency-idx1-1-0.0000-0.5000.eps');
images(k).file_out = 'rauschecker-scott-conn-summary.eps';
k = k+1;

%% surrogate histogram
% images(k).file = fullfile('output','img',...
%     '2017-07-13-surrogate-hist-sample257-n100.eps');
% images(k).file_out = 'surrogate-hist-sample257.eps';
% k = k+1;

images(k).file = fullfile('output','img',...
    '2017-08-03-surrogate-hist-sample257-n100-row2-col4.eps');
images(k).file_out = 'surrogate-hist-sample257-row2-col4.eps';
k = k+1;


%% copy images
for i=1:length(images)
    outfile = fullfile(outdir,images(i).file_out);
    [success,message,messageid] = copyfile(images(i).file,outfile);
    if success ~= 1
        warning('could not copy %s',images(i).file);
        disp(message);
        disp(messageid);
    end
end