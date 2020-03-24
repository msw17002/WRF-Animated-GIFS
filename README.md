# WRF-Animated-GIFS
NCL code that compiled multiple .png files into an animated gif. 

What is required:
Run WRF with radar diagnostics from the Air Force Weather Agency's (AFWA) diagnostics... ie. afwa_radar_opt must be set to '1' for a the domain you'd like to process this code with.

See the following manual for additional details on AFWA diagnostics:
https://www2.mmm.ucar.edu/wrf/users/docs/AFWA_Diagnostics_in_WRF.pdf

I also used 5-m shapefiles for country boundaries and U.S. state boundaries (will upload later).

You also need to install NCL...

What is the output:
Animated .gif(s) of,
coutoured MSLP, shaded 2m-T, and wind vectors
contoured MSLP and shaded 10-m wind velocity
contoured MSLP, shaded RADAR composite reflectivity (AFWA), and wind vectors
