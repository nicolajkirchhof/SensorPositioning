function dec = decomposition()

dec.types = struct('obstacle_expansion', 0, 'hertel_mehlhorn', 1, 'keil_snoeyink', 2, 'ear_clipping', 3, 'opt_length', 4, 'monotone', 5);
dec.type = [];
dec.boundaries = {};

