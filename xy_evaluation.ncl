;;; xy_evaluation.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com) ;
; Created        - 20 Sep 2018                               ;
; Last modified  - 25 Sep 2018                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "/home/ueslei/NCL/loads.ncl"
begin

; Choose variable.
 ;dado = "temp2" ; 2 m Air temperature
 dado = "rh2"   ; 2 m Relative humidity
 ;dado = "slp"    ; Sea level pressure

 if (dado.eq."rh2") then
  merge = "yes"
  else
    merge = "no"
 end if

; Load data.
 if (dado.eq."temp2") then
  data        = asciiread("/media/ueslei/Ueslei/INPE/PCI/SC_2008/Construindo/Avaliando/temperatura.csv",-1,"string")
 end if
 if (dado.eq."slp") then
  data        = asciiread("/media/ueslei/Ueslei/INPE/PCI/SC_2008/Construindo/Avaliando/slp.csv",-1,"string")
 end if
 if (dado.eq."rh2") then
  data        = asciiread("/media/ueslei/Ueslei/INPE/PCI/SC_2008/Construindo/Avaliando/umidaderelativa.csv",-1,"string")
 end if
 strs         = str_split_csv(data, ",", 0)
 nums         = tofloat(strs)
 data_all     =  new((/6,18/),"float")
 data_all(0,:)= nums(:,0)
 data_all(1,:)= nums(:,1)
 data_all(2,:)= nums(:,2)
 data_all(3,:)= nums(:,3)
 data_all(4,:)= nums(:,4)
 data_all(5,:)= nums(:,5)

; Create nice axis labels.
 time     = asciiread("/media/ueslei/Ueslei/INPE/PCI/SC_2008/Construindo/Avaliando/tempo.csv",-1,"string")
 year     = toint(str_get_field(time,1," ,"))
 month    = toint(str_get_field(time,2," ,"))
 day      = toint(str_get_field(time,3," ,"))
 hour     = toint(str_get_field(time,4," ,"))
 minute   = toint(str_get_field(time,5," ,"))
 second   = toint(str_get_field(time,6," ,"))
 units    = "hours since 1900-01-01 00:00:00"
 time2    = cd_inv_calendar(year,month,day,hour,minute,second,units, 0)
 time2!0  = "time"

; Plotting options.
 pltType          = "png"
 pltType@wkWidth  = 1000
 pltType@wkHeight = 1000
 if (dado.eq."temp2") then
  pltName          = "xy_evaluation_temp2"
 end if
 if (dado.eq."slp") then
  pltName          = "xy_evaluation_slp"
 end if
 if (dado.eq."rh2") then
  pltName          = "xy_evaluation_rh2"
 end if
 pltDir           = "./"
 pltPath          = pltDir + pltName
 wks              = gsn_open_wks(pltType, pltName)

; Resources.
 res                        = True
 res@gsnDraw                = False
 res@gsnFrame               = False
 if (dado.eq."temp2") then
  res@tiYAxisString          = "2 m Air temperature (~S~o~N~C)"
 end if
 if (dado.eq."slp") then
  res@tiYAxisString          = "Sea level pressure (hPa)"
 end if
 if (dado.eq."rh2") then
  res@tiYAxisString          = " 2 m Relative humidity (%)"
 end if
 res@xyLineColors           = (/"black", "red", "blue", "black", "red", "blue"/)
 res@xyLineThicknesses      = (/6.0, 6.0, 6.0, 4.0, 4.0, 4.0 /)
 res@xyDashPatterns         = (/0.0, 0.0, 0, 2, 2, 2 /)
 res@xyMarkLineModes        = (/"Lines", "Lines" , "Lines", "Lines", "Lines" , "Lines" /)
 res@xyMarkers              = (/16, 16, 16, 16, 16, 16/)
 res@tiMainFontHeightF      = 0.013
 if (dado.eq."temperatura") then
  res@trYMaxF                = 26
  res@trYMinF                = 15
 end if
 if (dado.eq."slp") then
  res@trYMaxF                = 1025
  res@trYMinF                = 1014
 end if
 if (dado.eq."rh2") then
  res@trYMaxF                = 100
  res@trYMinF                = 55
 end if
 res@xyLineThicknessF       = 5.0
 res@xyDashPattern          = 0
 res@tmXTOn                 = False
 res@tmYROn                 = False
 res@tiYAxisFontHeightF     = 0.01
 res@tmYLLabelFontHeightF   = 0.01
 res@tmXBLabelFontHeightF   = 0.01
 res@vpXF                   = 0.15
 res@vpWidthF               = 0.58
 res@vpHeightF              = 0.2
 res@tmBorderThicknessF     = 4
 res@tmXBMinorThicknessF    = 4
 res@tmXBMajorThicknessF    = 4
 res@tmYLMinorThicknessF    = 4
 res@tmYLMajorThicknessF    = 4
 res@tiXAxisString          = "Time (days)"
 res@tiXAxisFontHeightF     = 0.01
 res@xyMarkerColors         = (/"black", "red", "blue", "black", "red", "blue"/)

 ; Set time label.
  restime                = True
  restime@ttmFormat      = "%D %c %h"+"Z"
  restime@ttmMajorStride = 3
  restime@ttmMinorStride = 1
  time_axis_labels(time2,res,restime)

 ; Set up some legend resources for stations.
  lgres                    = True
  lgres@lgLineColors       = (/"black", "red", "blue"/)
  lgres@lgLineThicknessF   = 6.
  lgres@lgLabelFontHeightF = .1
  lgres@vpWidthF           = 0.13
  lgres@vpHeightF          = 0.04
  lgres@lgMonoDashIndex    = True
  lgres@lgPerimColor       = "white"
  lgres@lgPerimThicknessF  = 3.0
  labels                   = (/"   Indaial Station", "   Paranagu"+aacute+" Station", "   Florian"+oacute+"polis Station"/)
  lbid                     = gsn_create_legend(wks,3,labels,lgres)

 ; Set up some legend resources for simulation.
  lgres1                    = True
  lgres1@lgLineColors       = (/"black", "red", "blue"/)
  lgres1@lgLineThicknessF   = 4.
  lgres1@lgLabelFontHeightF = .1
  lgres1@vpWidthF           = 0.15
  lgres1@vpHeightF          = 0.04
  lgres1@lgMonoDashIndex    = True
  lgres1@lgPerimColor       = "white"
  lgres1@lgDashIndex        = "Dot"
  lgres1@lgPerimThicknessF  = 3.0
  labels1                   = (/"   Indaial Simulation", "   Paranagu"+aacute+" Simulation", "   Florian"+oacute+"polis Simulation"/)
  lbid1                     = gsn_create_legend(wks,3,labels1,lgres1)

 ; Plot.
  plot = gsn_csm_xy(wks,time2,data_all,res)

 ; Set up resources to attach legend to map.
  if (dado.eq."rh2") then
   amres                   = True
   amres@amParallelPosF    = -0.27
   amres@amOrthogonalPosF  = 0.88
   annoid1                 = gsn_add_annotation(plot,lbid,amres)
   amres1                  = True
   amres1@amParallelPosF   = 0.27
   amres1@amOrthogonalPosF = 0.88
   annoid2                 = gsn_add_annotation(plot,lbid1,amres1)
  end if

  if (dado.eq."slp") then
   txres                       = True
   txres@txPerimOn             = True
   txres@txBackgroundFillColor = "White"
   txres@txFontHeightF         = 0.015
   txid                        = gsn_create_text(wks, "a", txres)
   amres                       = True
   amres@amParallelPosF        = -0.65
   amres@amOrthogonalPosF      = -0.46
   annoid                      = gsn_add_annotation(plot, txid, amres)
  end if

  if (dado.eq."temp2") then
   txres                       = True
   txres@txPerimOn             = True
   txres@txBackgroundFillColor = "White"
   txres@txFontHeightF         = 0.015
   txid                        = gsn_create_text(wks, "b", txres)
   amres                       = True
   amres@amParallelPosF        = -0.65
   amres@amOrthogonalPosF      = -0.46
   annoid                      = gsn_add_annotation(plot, txid, amres)
  end if

  if (dado.eq."rh2") then
   txres                       = True
   txres@txPerimOn             = True
   txres@txBackgroundFillColor = "White"
   txres@txFontHeightF         = 0.015
   txid                        = gsn_create_text(wks, "c", txres)
   amres                       = True
   amres@amParallelPosF        = -0.65
   amres@amOrthogonalPosF      = -0.46
   annoid                      = gsn_add_annotation(plot, txid, amres)
  end if

 ; Do the plots.
  draw(plot)
  frame(wks)

 ; Trim figure
  system("convert -trim "+pltPath+"."+pltType+" "+pltPath+"."+pltType)

 ; Merge figures then delete trash.
 if (merge.eq."yes") then
  system("convert ./xy_evaluation_slp.png  ./xy_evaluation_temp2.png ./xy_evaluation_rh2.png -append xy_evaluation.png")
  system("rm -rf ./xy_evaluation_slp.png  ./xy_evaluation_temp2.png ./xy_evaluation_rh2.png")
 end if
end
