; Find the indices (subscripts) closest to the user specified lat/lon coordinate pairs

  load "/home/uesleisutil/NCL/loads.ncl"

; 1.2. Begin.
  
 begin

; 1.3. Open files.

 f   = addfile("/home/uesleisutil/Documentos/Dissertação/Dados/wrf.nc","r")

lat2d = f->XLAT(0,:,:)
lon2d = f->XLONG(0,:,:)

printVarSummary(lat2d)
printVarSummary(lon2d)
printMinMax(lat2d, True)
printMinMax(lon2d, True)

lat   = (/ -25 /)   ; user specified coordinate pairs
lon   = (/ -45 /)
                                          ; return 2d subscripts
nm = getind_latlon2d (lat2d,lon2d, lat, lon)

print(nm)

end
