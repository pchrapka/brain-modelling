%% paper_copy_images

outdir = fullfile('output','paper');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

images = [];
k = 1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-06-20-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f512-ds4-seed-in-i5-opnone-thresh0.00-0.0000-0.0098.eps');
images(k).file_out = 'hemileft-to-auditory-left-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-06-20-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f512-ds4-seed-in-i1-opnone-thresh0.00-0.0000-0.0098.eps');
images(k).file_out = 'hemileft-to-temporal-left-paper.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-06-20-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f512-ds4-adjacency-idx192-768-0.0000-0.0098.eps');
images(k).file_out = 'hemileft-adjacency-summary.eps';
k = k+1;

images(k).file = fullfile('output','std-s03-10','aal-coarse-19-outer-nocer-hemiright-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata','img',...
    '2017-06-20-MCMTLOCCD_TWL4-T20-C7-P3-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f512-ds4-adjacency-idx192-768-0.0000-0.0098.eps');
images(k).file_out = 'hemiright-adjacency-summary.eps';
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