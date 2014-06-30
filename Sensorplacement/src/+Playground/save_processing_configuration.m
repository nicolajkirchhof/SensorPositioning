function save_processing_configuration(pc)
filename = [pc.common.workdir filesep 'pc_' pc.name '_' pc.tag ];
save(filename);

