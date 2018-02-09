;;; xy_prec.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Author         - Ueslei Adriano Sutil (ueslei@outlook.com)         ;
; Created        - 09 Feb 2018                                       ;
; Last modified  - 09 Feb 2018                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "/home/ueslei/NCL/loads.ncl"
begin

  ; Load Major Gercino data.
    mj          = asciiread("/media/ueslei/Ueslei/SC_2008/Dados/Chuvas/major_gercino_final.csv",-1,"string")
    year1       = str_get_field(mj,1," ,")
    year        = stringtofloat(year1)
    day_max_mj1 = str_get_field(mj,2," ,")
    day_max_mj  = stringtofloat(day_max_mj1)
    accumul_mj1 = str_get_field(mj,3," ,")
    accumul_mj  = stringtofloat(accumul_mj1)

  ; Plotting options.
    pltType          = "png"
    pltType@wkWidth  = 1000
    pltType@wkHeight = 1000
    pltName          = "xy_prec"
    pltDir           = "./"
    pltPath          = pltDir + pltName
    wks              = gsn_open_wks(pltType, pltName)

  ; Major Gercino resources
    res1                        = True
    res1@gsnDraw                = False
    res1@gsnFrame               = False
    res1@xyLineColors           = "red"
    res1@xyLineThicknesses      = 4.0
    res1@xyDashPatterns         = 0.0
    res1@xyMarkLineModes        = "MarkLines"
    res1@xyMarkers              = 16
    res1@tiYAxisString          = "Daily precipitation maxima (mm)"
    res1@trYMaxF                = 350
    res1@trYMinF                = 0
    res1@trXMaxF                = 2015
    res1@trXMinF                = 1943
    res1@xyLineThicknessF       = 5.0
    res1@xyDashPattern          = 0
    res1@tmXTOn                 = False
    res1@tiYAxisFontHeightF     = 0.01
    res1@tmYLLabelFontHeightF   = 0.01
    res1@tmXBLabelFontHeightF   = 0.01
    res1@vpXF                   = 0.15
    res1@vpWidthF               = 0.58
    res1@vpHeightF              = 0.2
    res1@tmBorderThicknessF     = 4
    res1@tmXBMinorThicknessF    = 4
    res1@tmXBMajorThicknessF    = 4
    res1@tmYLMinorThicknessF    = 4
    res1@tmYLMajorThicknessF    = 4
    res1@tiXAxisString          = "Year"
    res1@tiXAxisFontHeightF     = 0.01
    res1@tmXBMode               = "Manual"
    res1@tmXBTickStartF         = 1945
    res1@tmXBTickEndF           = 2015
    res1@tmXBTickSpacingF       = 7
    res1@tiYAxisFontColor       = "red"
    res1@xyMarkerColors         = "red"

    res2                        = True
    res2@gsnDraw                = False
    res2@gsnFrame               = False
    res2@xyLineColors           = "blue"
    res2@xyLineThicknesses      = 4.0
    res2@xyDashPatterns         = 0.0
    res2@xyMarkLineModes        = "MarkLines"
    res2@xyMarkers              = 14
    res2@tiYAxisString          = "Accumulated precipitation (mm)"
    res2@trYMaxF                = 950
    res2@trYMinF                = 0
    res2@trXMaxF                = 2015
    res2@trXMinF                = 1943
    res2@xyLineThicknessF       = 5.0
    res2@xyDashPattern          = 0
    res2@tmXTOn                 = False
    res2@tiYAxisFontHeightF     = 0.01
    res2@tmYLLabelFontHeightF   = 0.01
    res2@tmXBLabelFontHeightF   = 0.01
    res2@vpXF                   = 0.15
    res2@vpWidthF               = 0.58
    res2@vpHeightF              = 0.2
    res2@tmBorderThicknessF     = 4
    res2@tmYRMinorThicknessF    = 4
    res2@tmYRMajorThicknessF    = 4
    res2@tiXAxisFontHeightF     = 0.01
    res2@tmXBMode               = "Manual"
    res2@tmXBTickStartF         = 1945
    res2@tmXBTickEndF           = 2015
    res2@tmXBTickSpacingF       = 8
    res2@xyMarkerColors         = "blue"
    res2@tiYAxisFontColor       = "blue"

    ; Set up some legend resources.
    lgres                    = True
    lgres@lgLineColors       = (/"red", "blue"/)
    lgres@lgLineThicknessF   = 8.
    lgres@lgLabelFontHeightF = .20
    lgres@vpWidthF           = 0.15
    lgres@vpHeightF          = 0.04
    lgres@lgMonoDashIndex    = True
    lgres@lgPerimColor       = "white"
    lgres@lgPerimThicknessF  = 3.0
    labels                   = (/"   Daily maxima", "  Accumulated precipitation"/)
    lbid                     = gsn_create_legend(wks,2,labels,lgres)

  ; Plot.
    plot = gsn_csm_xy2(wks,year,day_max_mj,accumul_mj,res1,res2)

  ; Set up resources to attach legend to map.
    amres                  = True
    amres@amParallelPosF   = -0.35
    amres@amOrthogonalPosF = -0.40
    annoid1                = gsn_add_annotation(plot,lbid,amres)

  ; Accumulated 2008 precipitation
    tres1               = True
    tres1@txFontColor   = "Blue"
    tres1@txFontHeightF  = 0.01
    gsn_text(wks,plot,"890 mm",2004.3,330,tres1)

  ; Maximum 2008 precipitation
    tres2               = True
    tres2@txFontColor   = "red"
    tres2@txFontHeightF  = 0.01
    gsn_text(wks,plot,"300 mm",2011.7,300,tres2)

  ; Insert cool legend polymakers.
    mres1               = True
    mres1@gsMarkerIndex = 14 ; marker style (filled circle)
    mres1@gsMarkerSizeF = 8.0 ; marker size
    mres1@gsMarkerColor = "blue" ; maker color
    markers1 = gsn_add_polymarker(wks,plot,1945.45,331,mres1)

  ; Insert cool legend polymakers.
    mres2               = True
    mres2@gsMarkerIndex = 16 ; marker style (filled circle)
    mres2@gsMarkerSizeF = 8.0 ; marker size
    mres2@gsMarkerColor = "red" ; maker color
    markers2 = gsn_add_polymarker(wks,plot,1945.45,299.7,mres2)


    draw(plot)
    frame(wks)

  ; Trim figure
    system("convert -trim "+pltPath+"."+pltType+" "+pltPath+"."+pltType)


end
