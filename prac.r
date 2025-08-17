#...QMS517 prac 6 - geospatial analysis
#
#my.nasa.name = "christopher.aiken"
#my.nasa.pwd = "9fgyRqBfzhX.sWM"

library(terra)
library(tidyterra)
library(rnaturalearth)

#...read in the chl file from the github:
#   https://github.com/christopheraiken/QMS517-prac6/blob/main/AQUA_MODIS.20250101_20250131.L4m.MO.GSM.chl_gsm.9km.nc
#   and/or read in your own from: 
#   https://oceandata.sci.gsfc.nasa.gov/directdataaccess/
chl_file = "AQUA_MODIS.20250101_20250131.L4m.MO.GSM.chl_gsm.9km.nc"
chl = rast(chl_file)
#   look at the file name.  what exactly does this file contain?
#   check the metadata: eg what is the coordinate reference system?
chl
crs(chl)
dim(chl)
nrow(chl)
ncol(chl)
nlyr(chl)
ncell(chl)

#...Australia's EEZ
eez_url = "https://pacificdata.org/data/dataset/1cdf7b81-c0fa-4981-a106-c06a1e3fc74c/resource/17350800-9c8d-48da-ba74-5c3bee2778e6/download/au_eez_pol_april2022.kml"
eez = vect(eez_url)
#   again check the metadata.  what does the file contain?

#...gebco bathymetry
gebco_url = "/vsicurl/https://gebco2022.s3.valeria.science/gebco_2022_complete_cog.tif"
bathy = rast(gebco_url,win=ext(eez.oz))
#    metadata?!

#...country boundaries
countries = rnaturalearth::ne_countries(scale = "medium")
#    are they all on the same coordinate reference system?

#...quick and dirty plot
plot(log(chl))
plot(countries,lwd=0.1,add=T)
plot(eez,lwd=2,add=T)

#...we can mask out everything outside the eez
chl_new <- mask(chl, eez, touches = FALSE)
#  didn't work?  why not??? how do we fix???

#...to plot
plot(log(chl_new))

#...to crop (what does the second argument mean?)
chl_new = crop(chl_new,ext(eez))

#...plot again
plot(log(chl_new))

#...write out a layer as a geotiff - can be imported to google earth/other GIS
writeRaster(chl_new, "my_geotiff.tif", overwrite=TRUE)
