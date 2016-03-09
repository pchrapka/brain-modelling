function check_package(pkg_name, pkg_path)
%CHECK_PACKAGE checks if package path exists
%   CHECK_PACKAGE(PKG_NAME, PKG_PATH)

if ~exist(pkg_path, 'dir')
    error('fbt:check_package',...
        '%s\nPackage directory does not exist\n\t%s\n\tSee README\n',...
        pkg_name, pkg_path);
end

end