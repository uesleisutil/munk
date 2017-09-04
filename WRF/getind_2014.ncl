; Find the indices (subscripts) closest to the user specified lat/lon coordinate pairs

load "/home/ueslei/NCL/loads.ncl"
begin

  ; Open WRF file
  it    = 01
  lon   = (/-44.633/)
  lat   = (/-30.011/)

  f     = addfile("/media/ueslei/Ueslei/INPE/2014/Outputs/WRS/wrs_I_t01.nc","r")
  lat2d = f->XLAT(0,:,:)
  lon2d = f->XLONG(0,:,:)
                                          ; return 2d subscripts
  nm   = getind_latlon2d (lat2d,lon2d, lat, lon)
  lat1 = nm(0,0)
  lon1 = nm(0,1)
  sst1 = wrf_user_getvar(f,"SST",it)
  sst  = sst1(lat1,lon1)-273.15

  print(sst)
end
