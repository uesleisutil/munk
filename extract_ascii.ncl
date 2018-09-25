;;; extract_ascii.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)        ;
; Created        - 27 Mar 2018                                      ;
; Last modified  - 27 Mar 2018                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "/home/ueslei/NCL/loads.ncl"
begin

; Options
 lat    = (/-27.583 /)
 lon    = (/-48.566 /)
 t_step = -1

; Open files
 f = addfile("/media/ueslei/Ueslei/INPE/PCI/SC_2008/Outputs/normal/wrf_normal.nc","r")



; Convert lat and lon
 lat2d = f->XLAT(0,:,:)
 lon2d = f->XLONG(0,:,:)
 nm    = getind_latlon2d (lat2d,lon2d, lat, lon)
 lat1  = nm(0,0)
 lon1  = nm(0,1)

 ; Load variables
 tair1   = wrf_user_getvar(f,"rh2",-1)
 tair    = tair1(:,lat1,lon1)

 ; Display some informations
 print("The longitude "+lon+" coordinate is equal to "+lon1+" WRF grid point.")
 print("The latitude "+lat+" coordinate is equal to "+lat1+" WRF grid point.")

 ; Write
 asciiwrite("./rh_indaial.txt", tair)

end
