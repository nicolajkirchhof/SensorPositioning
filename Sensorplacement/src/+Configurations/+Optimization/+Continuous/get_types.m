function types = get_types( )
%TYPES returns a list of all workspace configuration types
%   Detailed explanation goes here

types = get_package_functions(mfilename('fullpath'));
