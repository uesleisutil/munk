;;; xy_trend.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)         ;
; Created        - 08 Feb 2018                                       ;
; Last modified  - 08 Feb 2018                                       ;
; About          - Calculates the average, Mann-Kendall trend test,  ;
;                  the warming and then do a XY plot with a reg line ;
; Input          - CFSR monthly mean                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "/home/ueslei/NCL/loads.ncl"
begin

  ; Open file.
    cfsr = addfile("/media/ueslei/Ueslei/SC_2008/Dados/CFSR/cfsr_anon_nov.nc","r")

  ; Workstation
    pltType          = "png"
    pltType@wkWidth  = 1000
    pltType@wkHeight = 1000
    pltName          = "xy"
    pltDir           = "./"
    pltPath          = pltDir + pltName
    wks              = gsn_open_wks(pltType, pltName)

  ; Extract time.
    Times1   = cfsr->time
    Times2    = cd_calendar(Times1,0)
    Times3   = Times2(:,::6)
    Times4   = Times3(:,0)

  ; Extract variables.
    sst      = cfsr->TMP_L1_Avg(:,{-19:42.5},{307.5:304.5})
    lc       = cfsr->LAND_L1_Avg(:,{-19:42.5},{307.5:304.5})
    sst_lc1  = mask(sst,lc.ge.1,False)

  ; Calculate average
    sst_lc   = sst_lc1-273.15
    sst_avg1 = dim_avg(sst_lc)
    sst_avg  = dim_avg(sst_avg1)

  ; Calculate regression line.
  ; xAll(0,:) is te averaged SST over the years.
  ; xAll(1,:) is the regression.
    xAll       = new((/2,dimsizes(sst_avg)/),typeof(sst_avg))
    xAll(0,:)  = sst_avg
    reg        = regline(Times4,sst_avg)
    xAll(1,:)  = reg@yintercept + (Times4*reg)

  ; Calculate Mann-Kendall non-paramtric test.
    opt   = True
    trend = trend_manken(xAll(0,:),opt,0)

  ; Calculate 1979-2012 warming.
    warm = xAll(1,29)-xAll(1,0)

  ; Averaged SST Resources.
    res1                        = True
    res1@xyLineColors           = (/"red","black"/)  ; line colors
    res1@xyLineThicknesses      = (/4.0,4.0/)        ; line thicknesses
    res1@xyDashPatterns         = (/0.0,1.0/)        ; line patterns
    res1@xyMarkLineModes        = (/"MarkLines","Lines"/) ; markers?
    res1@xyMarkers              = (/16,         0/)          ; style
    res1@tiYAxisString          = "Averaged CFSR SST (~S~o~N~C)"
    res1@trYMaxF                = 26
    res1@trYMinF                = 24.4
    res1@trXMaxF                = 2011
    res1@trXMinF                = 1978
    res1@xyLineThicknessF       = 5.0
    res1@xyDashPattern          = 0
    res1@vpWidthF               = 0.8
    res1@vpHeightF              = 0.4
    res1@tmXTOn                 = False
    res1@tiYAxisFontHeightF     = 0.01
    res1@tmYLLabelFontHeightF   = 0.01
    res1@tmXBLabelFontHeightF   = 0.01
    res1@vpXF                   = 0.15
    res1@vpWidthF               = 0.58
    res1@vpHeightF              = 0.2
    res1@gsnDraw                = False
    res1@gsnFrame               = False
    res1@tmBorderThicknessF     = 4
    res1@tmXBMinorThicknessF    = 4
    res1@tmXBMajorThicknessF    = 4
    res1@tmYLMinorThicknessF    = 4
    res1@tmYLMajorThicknessF    = 4
    res1@tiXAxisString          = "Year"
    res1@tiXAxisFontHeightF     = 0.01
    res1@gsnXRefLine            = 2008
    res1@gsnXRefLineThicknesses = 3
    res1@gsnXRefLineDashPattern = 2
    res1@gsnXRefLineColor       = "blue"
    res1@tmXBMode               = "Manual"
    res1@tmXBTickStartF         = 1979
    res1@tmXBTickEndF           = 2010
    res1@tmXBTickSpacingF       = 4
    res1@tmYLMode               = "Manual"
    res1@tmYLTickStartF         = 24.5
    res1@tmYLTickEndF           = 26
    res1@tmYLTickSpacingF       = 0.20

  ; SST Trend resources.
    res2                      = True
    res2@trYMaxF              = 26
    res2@trYMinF              = 24.4
    res2@trXMaxF              = 2011
    res2@trXMinF              = 1978
    res2@xyLineThicknessF     = 5.0
    res2@tmYROn               = False
    res2@vpWidthF             = 0.8
    res2@vpHeightF            = 0.4
    res2@tiYAxisFontHeightF   = 0.01
    res2@tmYLLabelFontHeightF = 0.01
    res2@tmXBLabelFontHeightF = 0.01
    res2@vpXF                 = 0.15
    res2@vpWidthF             = 0.58
    res2@vpHeightF            = 0.2
    res2@gsnDraw              = False
    res2@gsnFrame             = False
    res2@xyLineColor          = "Black"

    ; Set up some legend resources.
    lgres                    = True
    lgres@lgLineColors       = (/"red"/)
    lgres@lgLineThicknessF   = 10.
    lgres@lgLabelFontHeightF = .5
    lgres@vpWidthF           = 0.1
    lgres@vpHeightF          = 0.05
    lgres@lgMonoDashIndex    = True
    lgres@lgPerimColor       = "white"
    lgres@lgPerimThicknessF  = 3.0
    labels                   = (/"  November mean"/)
    lbid                     = gsn_create_legend(wks,1,labels,lgres)

  ; Plot.
    plot = gsn_csm_xy2(wks,Times4,xAll(0,:),xAll(1,:),res1,res2)

  ; Set up resources to attach legend to map.
    amres                  = True
    amres@amParallelPosF   = -0.40
    amres@amOrthogonalPosF = -0.45
    annoid1                = gsn_add_annotation(plot,lbid,amres)

  ; Add text.
    tres               =  True
    tres@txFontHeightF = 0.01
    tres@txFontColor   = "blue"

    gsn_text(wks,plot,"2008",2009.4,24.453,tres)
    tx_min             = min(Times4)
    tx_max             = max(Times4)
    tx_just            = ((tx_max)+(tx_min))/2
    gsn_text(wks,plot,"1979 - 2008 warming: 0.8 ~S~o~N~C",tx_just,24.453,tres)
    gsn_text(wks,plot," 24.93 ~S~o~N~C",1979.5,24.89,tres)
    gsn_text(wks,plot," 25.73 ~S~o~N~C",2008.5,25.67,tres)

  ; Overlay one plot on the other, so they become one plot.
    draw(plot)
    frame(wks)

  ; Trim figure
    system("convert -trim "+pltPath+"."+pltType+" "+pltPath+"."+pltType)

end
