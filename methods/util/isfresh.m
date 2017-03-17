function fresh = isfresh(outfile,prevfile)
fresh = false;
if exist(outfile,'file')
    prev_time = get_timestamp(prevfile);
    out_time = get_timestamp(outfile);
    if prev_time > out_time
        fresh = true;
    end
end
end