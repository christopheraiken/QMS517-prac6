#...QMS517 prac 6 - geospatial analysis
#
#...some analysis with the terra package
#
#   check here: https://cran.r-project.org/web/packages/terra/refman/terra.html
#
#   to get your own earthdata account, go here:
#
#   https://urs.earthdata.nasa.gov/users/new
#
#   here's mine if you get stuck:
#
#   my.nasa.name = "christopher.aiken"
#   my.nasa.pwd = "9fgyRqBfzhX.sWM"

library(sf)
library(terra)
library(tidyterra)
library(rnaturalearth)

#...read in the chl file from the github:
#   https://github.com/christopheraiken/QMS517-prac6/blob/main/AQUA_MODIS.20250101_20250131.L4m.MO.GSM.chl_gsm.9km.nc
#   and/or read in your own from: 
#   https://oceandata.sci.gsfc.nasa.gov/directdataaccess/
#chl_file = "AQUA_MODIS.20250101_20250131.L4m.MO.GSM.chl_gsm.9km.nc"   #...monthly
chl_file = "AQUA_MODIS.20250101_20250108.L4m.8D.GSM.chl_gsm.9km.nc"    #...eight daily
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
bathy = rast(gebco_url,win=ext(eez))
#    metadata?!

#...country boundaries
countries = ne_countries(scale = "medium",returnclass="sv")
#    are they all on the same coordinate reference system?

#...quick and dirty plots
plot(log(chl))
plot(countries,lwd=0.1,add=T)
plot(eez,lwd=2,add=T)

plot(bathy)
plot(countries,lwd=0.1,add=T)
plot(eez,add=T)

#...we can mask out everything outside the eez
chl_eez <- mask(chl, eez, touches = FALSE)
#  didn't work?  why not??? how do we fix???

#...to plot
plot(log(chl_eez))

#...to crop (what does the second argument mean?)
chl_eez = crop(chl_eez,ext(eez))

#...plot again
plot(log(chl_eez))

#...write out a layer as a geotiff - can be imported to google earth/other GIS
#   does it show up in the right place?
writeRaster(chl_eez, "my_geotiff.tif", overwrite=TRUE)

#...we can mask out all the deep water like this
shelf = bathy>(-200)
chl_shelf <- resample(chl,shelf,method="near")
chl_shelf <- mask(chl_shelf,shelf,maskvalues=F)
plot(log(chl_shelf))

#...some basic stats
summary(chl_eez)
autocor(chl_eez)

#...find contiguous regions
chl_patches = patches(chl_eez>0.5,zeroAsNA=T)
plot(chl_patches)

#...or with clustering
chl_clusters = k_means(chl_eez,centers=10)
plot(chl_clusters)

#...an example of interpolation to fill in gaps
ii = which(!is.na(values(chl_eez)))
good = extract(chl_eez,ii,xy=T)
chl_filled = interpIDW(chl_eez, as.matrix(good),radius=1)
plot(chl_filled)

#...exercises
#...1) download a week's worth of daily modis data, combine into a single raster, and use terra to make a composite
#...2) test whether there is more chlorophyll on the shelf or offshore around Tasmania
#...3) work out how to export a raster in a format that google earth doesn't turn into a black square
