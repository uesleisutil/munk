load "/home/ueslei/NCL/loads.ncl"
begin

  ; Load B116192 buoy data
  b01     = asciiread("/media/ueslei/Ueslei/INPE/2014/Dados/PNBOIA/B116192_lonlat.csv",-1,"string")
  b01_lon = stringtofloat(str_get_field(b01(::), 5," "))
  b01_lat = stringtofloat(str_get_field(b01(::), 6," "))

  ; Load B116286 buoy data
  b02     = asciiread("/media/ueslei/Ueslei/INPE/2014/Dados/PNBOIA/B116286_lonlat.csv",-1,"string")
  b02_lon = stringtofloat(str_get_field(b02(::), 5," "))
  b02_lat = stringtofloat(str_get_field(b02(::), 6," "))

  ; Load B116287 buoy data
  b03     = asciiread("/media/ueslei/Ueslei/INPE/2014/Dados/PNBOIA/B116287_lonlat.csv",-1,"string")
  b03_lon = stringtofloat(str_get_field(b03(::), 5," "))
  b03_lat = stringtofloat(str_get_field(b03(::), 6," "))

  ; Load Rio Grande buoy data
  b04     = asciiread("/media/ueslei/Ueslei/INPE/2014/Dados/PNBOIA/Brio_grande_argos_lonlat.csv",-1,"string")
  b04_lon = stringtofloat(str_get_field(b04(::), 5," "))
  b04_lat = stringtofloat(str_get_field(b04(::), 6," "))

  ; Workstation
  pltType = "png" ; ps, eps, pdf, ....
  pltName = "buoy" ; whatever
  pltDir = "./" ; plot directory ["./" is current directory]
  pltPath = pltDir + pltName
  wks = gsn_open_wks("png","buoy")

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
  res@mpMinLonF                   = -55.0             ; longitude oeste
  res@mpMaxLonF                   = -40.0             ; longitude leste
  res@mpMinLatF                   = -45.0             ; latitude sul
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
  res@tiMainString                = "~Z60~ Buoy localizations"
  res@tiMainFontHeightF           = 0.02
  res@tmXTOn                      = False
  res@tmYROn                      = False

  ; Plot tracks.
  track = gsn_csm_map_ce(wks,res)

  ; Add text, if desired.
  txres               = True
  txres@txFontHeightF = 20.017
  txres@txFontColor   = "black"
  txres@txJust        = "BottomCenter"
  txres@txPosYF       = 31.5
  txres@txFont        = "helvetica-bold"
  text1 = gsn_add_text(wks,track,"B116192",b01_lon(0),b01_lat(0)+0.15,txres)
  text2 = gsn_add_text(wks,track,"B116286",b02_lon(0),b02_lat(0)+0.45,txres)
  text3 = gsn_add_text(wks,track,"B116287",b03_lon(0),b03_lat(0)+0.15,txres)
  text4 = gsn_add_text(wks,track,"Rio Grande",b04_lon(0),b04_lat(0)+0.25,txres)

  ; B116192 line resources.
  pres                  = True
  pres@gsLineThicknessF = 9.0
  pres@gsLineColor      = "black"
  line1 = gsn_add_polyline(wks,track,b01_lon,b01_lat,pres)

  ; B116286 line resources.
  pres                  = True
  pres@gsLineThicknessF = 9.0
  pres@gsLineColor      = "black"
  line2 = gsn_add_polyline(wks,track,b02_lon,b02_lat,pres)

  ; B116287 line resources.
  pres                  = True
  pres@gsLineThicknessF = 9.0
  pres@gsLineColor      = "black"
  line3 = gsn_add_polyline(wks,track,b03_lon,b03_lat,pres)

  ; Rio Grande buoy line resources.
  pres                  = True
  pres@gsLineThicknessF = 30.0
  pres@gsLineColor      = "black"
  line4 = gsn_add_polyline(wks,track,b04_lon,b04_lat,pres)

  ; Draw
  draw(track)
  frame(wks)

  ; Minimize blank space
  system("convert -trim "+pltPath+"."+pltType+" "+pltPath+"."+pltType)
end
