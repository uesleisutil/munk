load "/home/uesleisutil/NCL/loads.ncl"
begin

; Load WR data
wr     = asciiread("/home/uesleisutil/Documentos/INPE/PCI/2014/Outputs/trajetoria/wr_I_t01.txt",-1,"string")
wr_lon = stringtofloat(str_get_field(wr(::), 1," "))
wr_lat = stringtofloat(str_get_field(wr(::), 2," "))
wr_slp = stringtofloat(str_get_field(wr(::), 3," "))

; Load WRS data
wrs     = asciiread("/home/uesleisutil/Documentos/INPE/PCI/2014/Outputs/trajetoria/wrs_I_t01.txt",-1,"string")
wrs_lon = stringtofloat(str_get_field(wrs(::), 1," "))
wrs_lat = stringtofloat(str_get_field(wrs(::), 2," "))
wrs_slp = stringtofloat(str_get_field(wrs(::), 3," "))

; Load WRF data
wrf     = asciiread("/home/uesleisutil/Documentos/INPE/PCI/2014/Outputs/trajetoria/wrf_I_t01.txt",-1,"string")
wrf_lon = stringtofloat(str_get_field(wrf(::), 1," "))
wrf_lat = stringtofloat(str_get_field(wrf(::), 2," "))

; Load CFSR data
cfsr     = asciiread("/home/uesleisutil/Documentos/INPE/PCI/2014/Outputs/trajetoria/cfsr.txt",-1,"string")
cfsr_lon = stringtofloat(str_get_field(cfsr(::), 1," "))
cfsr_lat = stringtofloat(str_get_field(cfsr(::), 2," "))

; Workstation
wks = gsn_open_wks("png","track")

; Resources
res                             = True
res@gsnDraw                     = False
res@gsnFrame                    = False
res@gsnMaximize                 = True
res@mpFillOn                    = True
res@mpPerimOn                   = True
res@mpDataSetName               = "Earth..4"
res@mpDataBaseVersion           = "MediumRes"
res@mpOutlineOn                 = True
res@mpOutlineBoundarySets       = "National"
res@mpLimitMode                 = "LatLon"
res@mpMinLonF                   = -65.0             ; longitude oeste
res@mpMaxLonF                   = -35.0             ; longitude leste
res@mpMinLatF                   = -50.0             ; latitude sul
res@mpMaxLatF                   = -25.0             ; latitude norte
res@mpOceanFillColor            = "white"
res@mpLandFillColor             = "gray"
res@mpInlandWaterFillColor      = "white"
res@mpProvincialLineColor       = "black"
res@mpGeophysicalLineColor      = "black"
res@mpNationalLineColor         = "black"
res@mpGeophysicalLineThicknessF = 3
res@mpNationalLineThicknessF    = 3.0
res@gsnMajorLatSpacing          = 5
res@gsnMajorLonSpacing          = 5
res@gsnMinorLatSpacing          = 1
res@gsnMinorLonSpacing          = 1
;res@tiMainString                = "~Z80~ Ciclone extratropical de agosto de 2014"
res@tiMainFontHeightF = 0.02

; Plot track.
track = gsn_csm_map_ce(wks,res)

; Set up some legend resources.
lgres                    = True
lgres@lgLineColors       = (/"green4","blue","red","black"/)
lgres@lgLineThicknessF   = 20.
lgres@lgLabelFontHeightF = .48            ; set the legend label font thickness
lgres@vpWidthF           = 0.25           ; width of legend (NDC)
lgres@vpHeightF          = 0.15            ; height of legend (NDC)
lgres@lgMonoDashIndex    = True
lgres@lgPerimColor       = "white"       ; draw the box perimeter in orange
lgres@lgPerimThicknessF = 3.0            ; thicken the box perimeter
labels = (/"  CFSR","  WRF","  WRF + ROMS","  WRF + ROMS + SWAN"/)

; Create the legend.
lbid = gsn_create_legend(wks,4,labels,lgres)         ; create legend

; Set up resources to attach legend to map.
amres = True
amres@amParallelPosF   =  0.33         ; positive move legend to the right
amres@amOrthogonalPosF = -0.40                 ; positive move the legend down
annoid1 = gsn_add_annotation(track,lbid,amres)   ; attach legend to plot

; Add text of every 6 hours
txres               = True
txres@txFontHeightF = 0.017
txres@txFontColor   = "black"
txres@txJust        = "BottomCenter"
txres@txPosYF       = "20.5"
txres@txFont        = "helvetica-bold"
;text1 = gsn_add_text(wks,track,"18Z 24",wr_lat(0),wr_lon(0),txres)
;text1 = gsn_add_text(wks,track,"18Z 25",wr_lat(0+8),wr_lon(0+8),txres)
;text1 = gsn_add_text(wks,track,"18Z 26",wr_lat(0+16),wr_lon(0+16),txres)
;text1 = gsn_add_text(wks,track,"18Z 27",wr_lat(0+24),wr_lon(0+24),txres)
;text1 = gsn_add_text(wks,track,"09Z 28",wr_lat(0+29),wr_lon(0+29),txres)

; WR line resources.
pres                  = True
pres@gsLineThicknessF = 3.0
pres@gsLineColor      = "red"
line1 = gsn_add_polyline(wks,track,wr_lat,wr_lon,pres)

; WRS line resources.
pres                  = True
pres@gsLineThicknessF = 3.0
pres@gsLineColor      = "black"
line2 = gsn_add_polyline(wks,track,wrs_lat,wrs_lon,pres)

; WRF line resources.
pres                  = True
pres@gsLineThicknessF = 3.0
pres@gsLineColor      = "blue"
line3 = gsn_add_polyline(wks,track,wrf_lat,wrf_lon,pres)

; CFSR line resources.
pres                  = True
pres@gsLineThicknessF = 3.0
pres@gsLineColor      = "green4"
line4 = gsn_add_polyline(wks,track,cfsr_lat,cfsr_lon,pres)

; Add markers to the trajectories.
; WR markers.
mres_wr                = True         ; marker resources for best track
mres_wr@gsMarkerIndex  = 16           ; marker style (filled circle)
mres_wr@gsMarkerSizeF  = 8.0          ; marker size
mres_wr@gsMarkerColor  = "red"      ; maker color
marker_wr              = gsn_add_polymarker(wks,track,wr_lat,wr_lon,mres_wr)

; WRS markers.
mres_wrs                = True         ; marker resources for best track
mres_wrs@gsMarkerIndex  = 16           ; marker style (filled circle)
mres_wrs@gsMarkerSizeF  = 8.0          ; marker size
mres_wrs@gsMarkerColor  = "black"      ; maker color
marker_wrs              = gsn_add_polymarker(wks,track,wrs_lat,wrs_lon,mres_wrs)

; WRF markers.
mres_wrf                = True         ; marker resources for best track
mres_wrf@gsMarkerIndex  = 16           ; marker style (filled circle)
mres_wrf@gsMarkerSizeF  = 8.0          ; marker size
mres_wrf@gsMarkerColor  = "blue"      ; maker color
marker_wrf              = gsn_add_polymarker(wks,track,wrf_lat,wrf_lon,mres_wrf)

; CFSR markers.
mres_cfsr                = True         ; marker resources for best track
mres_cfsr@gsMarkerIndex  = 16           ; marker style (filled circle)
mres_cfsr@gsMarkerSizeF  = 8.0          ; marker size
mres_cfsr@gsMarkerColor  = "green4"      ; maker color
marker_cfsr              = gsn_add_polymarker(wks,track,cfsr_lat,cfsr_lon,mres_cfsr)

draw(track)
frame(wks)

end
