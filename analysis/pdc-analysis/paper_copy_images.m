%% paper_copy_images

outdir = fullfile('output','paper');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

images = [];
k = 1;

%% gPDC
images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-07-14-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i6-opnone-thresh0.00-0.0000-0.0049.eps');
    %'2017-06-20-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f512-ds4-seed-in-i5-opnone-thresh0.00-0.0000-0.0098.eps');
images(k).file_out = 'hemileft-to-auditory-left-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-07-14-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i1-opnone-thresh0.00-0.0000-0.0049.eps');
    %'2017-06-20-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f512-ds4-seed-in-i1-opnone-thresh0.00-0.0000-0.0098.eps');
images(k).file_out = 'hemileft-to-temporal-left-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-07-14-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i7-opnone-thresh0.00-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-motor-left-paper.eps';
k = k+1;

%% gPDC H=100
images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-07-14-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i6-opnone-thresh0.00-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-auditory-left-h100-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-07-14-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i1-opnone-thresh0.00-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-temporal-left-h100-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-07-14-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i7-opnone-thresh0.00-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-motor-left-h100-paper.eps';
k = k+1;

%% gPDC surrogate
images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-08-02-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i6-opnone-threshsig-estimate_ind_channels-0.0000-0.0049.eps');
    %'2017-06-22-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f512-ds4-seed-in-i5-opnone-threshsig-estimate_ind_channels-0.0000-0.0098.eps');
images(k).file_out = 'hemileft-to-auditory-left-surrogate-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-08-02-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i1-opnone-threshsig-estimate_ind_channels-0.0000-0.0049.eps');
    %'2017-06-22-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f512-ds4-seed-in-i1-opnone-threshsig-estimate_ind_channels-0.0000-0.0098.eps');
images(k).file_out = 'hemileft-to-temporal-left-surrogate-paper.eps';
k = k+1;


images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-08-02-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-in-i7-opnone-threshsig-estimate_ind_channels-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-motor-left-surrogate-paper.eps';
k = k+1;

%% gPDC standard deviation
images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-07-14-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-std-seed-in-i6-opnone-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-auditory-left-std-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-07-28-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p100-removed-pdc-dynamic-diag-f2048-41-ds4-std-seed-in-i6-opnone-0.0000-0.0049.eps');
images(k).file_out = 'hemileft-to-auditory-left-std-100-paper.eps';
k = k+1;

%% connectivity matrices
images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-07-14-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-adjacency-idx192-768-0.0000-0.0024.eps');
    %'2017-06-20-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f512-ds4-adjacency-idx192-768-0.0000-0.0098.eps');
images(k).file_out = 'hemileft-adjacency-summary.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemiright-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-07-14-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-adjacency-idx192-768-0.0000-0.0024.eps');
    %'2017-06-20-MCMTLOCCD_TWL4-T20-C7-P3-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f512-ds4-adjacency-idx192-768-0.0000-0.0098.eps');
images(k).file_out = 'hemiright-adjacency-summary.eps';
k = k+1;

%% connectivity matrices H=100
images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-07-14-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-adjacency-idx192-768-0.0000-0.0024.eps');
images(k).file_out = 'hemileft-adjacency-summary-h100.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemiright-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-07-14-MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-adjacency-idx192-768-0.0000-0.0024.eps');
images(k).file_out = 'hemiright-adjacency-summary-h100.eps';
k = k+1;

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


for i=1:length(images)
    outfile = fullfile(outdir,images(i).file_out);
    [success,message,messageid] = copyfile(images(i).file,outfile);
    if success ~= 1
        warning('could not copy %s',images(i).file);
        disp(message);
        disp(messageid);
    end
end