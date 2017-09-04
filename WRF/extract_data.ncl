;;; extract_data.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 04 Sep 2017                                      ;
; Last modified  - 04 Sep 2017                                      ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "/home/uesleisutil/NCL/loads.ncl"
begin

  ; Load WRF data.
  data = addfile("/media/uesleisutil/Ueslei/INPE/2014/Outputs/WRS/wrs_I_t01.nc","r")
  lat2d = data->XLAT(0,:,:)
  lon2d = data->XLONG(0,:,:)

  ; Load buoy data.
  b01     = asciiread("/media/uesleisutil/Ueslei/INPE/2014/Dados/PNBOIA/B116192_post.csv",-1,"string")
  b01_lon = stringtofloat(str_get_field(b01(::), 5," "))
  b01_lat = stringtofloat(str_get_field(b01(::), 6," "))

  ; Select buoy points.
  lat =  b01_lat
  lon =  b01_lon

  ;
  lines = 6
  sstvar = new((/lines/),float)

  do i=0,1
   latlonind = getind_latlon2d(lat2d,lon2d,lat(i),lon(i))
   latind    = latlonind(0,0)
   lonind    = latlonind(0,1)

   ; SST
   sst1   = wrf_user_getvar(data,"SST",i)
   sst2   = sst1(latind,latind)
   sst3   = sst2-273.15
   ;sstvar(i)    = sst3(i)
   sst = sst3
   asciiwrite("sst.txt"+(i+1), sst)

   ; Wind speed
   ;wind_u = wrf_user_getvar(data,"U10",i)
   ;wind_v = wrf_user_getvar(data,"V10",i)
   ;u1 = wrf_user_unstagger(wind_u,wind_u@stagger)
   ;v1 = wrf_user_unstagger(wind_v,wind_v@stagger)
   ;u=u1(latind,lonind)
   ;v=v1(latind,lonind)
   ;spd = sqrt(u*u + v*v)
   ;copy_VarCoords(v,spd)
   ;asciiwrite("windspeed_"+(i+1)+".txt" , spd)

   ; Sea level pressure
   ;slp1 = wrf_user_getvar(data,"slp",i)
   ;slp  = slp1(latind,lonind)
   ;printVarSummary(slp)
   ;asciiwrite("slp_"+(i+1)+".txt" , slp)
  end do
end
