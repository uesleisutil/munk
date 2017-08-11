load "/home/uesleisutil/NCL/loads.ncl"
begin

; Load WR data
wr      = asciiread("/home/uesleisutil/Documentos/INPE/PCI/2014/Outputs/trajetoria/wr_I_t01.txt",-1,"string")
wr_slp  = stringtofloat(str_get_field(wr(::), 3," "))

; Load WRS data
wrs      = asciiread("/home/uesleisutil/Documentos/INPE/PCI/2014/Outputs/trajetoria/wrs_I_t01.txt",-1,"string")
wrs_slp  = stringtofloat(str_get_field(wrs(::), 3," "))

; Load WRF data
wrf      = asciiread("/home/uesleisutil/Documentos/INPE/PCI/2014/Outputs/trajetoria/wrf_I_t01.txt",-1,"string")
wrf1_slp = stringtofloat(str_get_field(wrf(::), 3," "))

; Load data
data = ispan(1,30,1)

; Plotting options
pltType = "png" ; ps, eps, pdf, ....
pltName = "xy" ; whatever
pltDir = "./" ; plot directory ["./" is current directory]
pltPath = pltDir + pltName
wks  = gsn_open_wks("png","xy")

; Plotting options for time series plot
res                      = True
res@gsnMaximize          = True
res@gsnDraw              = False
res@gsnFrame             = False
res@trXMinF              = (min(data))
res@trXMaxF              = (max(data))
res@vpXF                 = 0.15
res@vpWidthF             = 0.58
res@vpHeightF            = 0.2
res@tiYAxisString        = "Min sea level pressure (hPa)"
res@tiMainString         = "~Z60~ Minimum Sea level pressure from 18Z 24 August 2014 to 09Z 28 August 2014"
res@tiMainFontHeightF    = 0.02
res@tiXAxisString        = "Time"
res@tiYAxisFontColor     = "black"
res@tiYAxisFontHeightF   = 0.01
res@tiXAxisFontHeightF   = 0.01
res@tmXBLabelFontHeightF = 0.01
res@tmYLLabelFontHeightF = 0.01
res@tmXBMode             = "Explicit"
res@tmXBValues           = ispan(1,30,2)
res@tmXBLabels           =  (/"18Z24","00Z25","06Z25","12Z25","18Z25","00Z26","06Z26","12Z26","18Z26","00Z27","06Z27","12Z27","18Z27","00Z28","06Z28","09Z28"/)
;res@tmXBLabelDeltaF      =  0.1
res@tmXBLabelJust        = "CenterRight"
res@tmXBLabelAngleF      =  50.
res@tmXBMinorValues      = ispan(1,30,1)

;---Resources for legend
res@pmLegendWidthF         = 0.12
res@pmLegendHeightF        = 0.15
res@pmLegendOrthogonalPosF = -0.08
res@lgLabelFontHeightF     = .001
res@lgPerimOn              = False
res@lgItemOrder            = (/1,0/)
res@xyDashPattern          = 0

;---Turn off some tickmarks
res@tmXTOn                 = False
res@tmYROn                 = False
res@xyLineThicknessF       = 2.0
res@xyMonoDashPattern      = True

; WR resources
wr_res                        = res
wr_res@xyLineColors           = "red"
wr_res@xyLineThicknessF       = 8
wr_res@pmLegendParallelPosF   = 0.15
plot1 = gsn_csm_xy(wks,data,wr_slp,wr_res)

; WRS resources
wrs_res                        = res
wrs_res@xyLineColors           = "black"
wrs_res@xyLineThicknessF      = 8
wrs_res@pmLegendParallelPosF   = 0.15
plot2 = gsn_csm_xy(wks,data,wrs_slp,wrs_res)

; WRF resources
wrf1_res                        = res
wrf1_res@xyLineColors           = "blue"
wrf1_res@xyLineThicknessF      = 8
wrf1_res@pmLegendParallelPosF   = 0.15
plot3 = gsn_csm_xy(wks,data,wrf1_slp,wrf1_res)

; Set up some legend resources.
lgres                    = True
lgres@lgLineColors       = (/"blue","red","black"/)
lgres@lgLineThicknessF   = 20.
lgres@lgLabelFontHeightF = .48
lgres@vpWidthF           = 0.25
lgres@vpHeightF          = 0.15
lgres@lgMonoDashIndex    = True
lgres@lgPerimColor       = "white"
lgres@lgPerimThicknessF  = 3.0
labels                   = (/"  WRF","  WRF + ROMS","  WRF + ROMS + SWAN"/)
lbid                     = gsn_create_legend(wks,3,labels,lgres)

; Set up resources to attach legend to map.
amres                  = True
amres@amParallelPosF   =  0.35
amres@amOrthogonalPosF = -0.30
annoid1                = gsn_add_annotation(plot1,lbid,amres)

; Overlay one plot on the other, so they become one plot.
overlay(plot1,plot2)
overlay(plot1,plot3)

draw(plot1)
frame(wks)

; Minimize blank space
system("convert -trim "+pltPath+"."+pltType+" "+pltPath+"."+pltType)


end
