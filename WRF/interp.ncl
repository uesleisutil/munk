;*******************************************************************;
;* Script    - interp.ncl                                          *;
;*                                                                 *;
;* Author    - Regiane Moura                                       *;
;*                                                                 *;
;* Created   - 11 set 2015                                         *;
;* Update    - 11 set 2015                                         *;
;*                                                                 *;
;* About     - This program is a script that will interp a series  *;
;*             of variables from WRF and COAWST to GHRSST and      *;
;*             QuikSCAT data in order to make maps.                *;
;*******************************************************************;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Prototype scripts, open file and begin.                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; 1.1. Prototype scripts.

   load "/home/ueslei/Documentos/NCL/scripts/loads.ncl"
 
  ; 1.2. Begin.

   begin

  ; 1.3. Files.

   dir1 = "/home/ueslei/Documentos/Dissertação/Dados/WRF/"
   a    = addfile(dir1+"wrfout_d01_2006-09-01_00:00:00","r")

   dir2 = "/home/ueslei/Documentos/Dissertação/Dados/COAWST/"
   b    = addfile(dir2+"wrfout_d01_2006-09-01_00:00:00","r")

   dir3 = "/home/ueslei/Documentos/Dissertação/Dados/GHRSST/"
   c    = addfile(dir3+"20060901.nc","r")

   dir4 = "/home/ueslei/Documentos/Dissertação/Dados/QUIKSCAT/"
   d    = addfile(dir4+"200609010000-200609020000.nc","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Model coordinates and landmask and isolate lat & lon           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; 2.1. Coordinates.

   nl0       = 772       ; lat 15S   - arquivo 899 x 745
   nl1       = 112       ; lat 50S  

   ml0       = 65        ; lon 65W
   ml1       = 679       ; lon 25W

 ; 2.2. Landmask.

   lsm       = a->LANDMASK(0,nl1:nl0,ml0:ml1)

   lat2d     = a->XLAT(0,nl1:nl0,ml0:ml1)
   lon2d     = a->XLONG(0,nl1:nl0,ml0:ml1)      
   
 ; 2.3. Isolate lat/lon components of mass coordinate system and label/establish them in proper arrays

   lat       = lat2d(:,0)
   lon       = lon2d(0,:)
   lat@units = "degrees_north"
   lon@units = "degrees_east"
   lat!0     = "south_north"
   lon!0     = "west_east"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Creates SST Latitude and Longitude for WRF, then interpolate.  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  sst                   = a->SST(0,nl1:nl0,ml0:ml1)
  sst                   = sst-273.16
  sst1                  = mask(sst,lsm.ge.1,False)   ; mask
  copy_VarCoords(sst, sst1)

  south_north           = fspan(-50,-15,661)         ; calculate x values
  south_north@long_name = "south_north"
  south_north@units     = "degree_north"
  sst1&south_north      = south_north          

  west_east             = fspan(-65,-25,615)         ; lon
  west_east@long_name   = "west_east"
  west_east@units       = "degree_east"
  sst1&west_east        = west_east          
 
  fiCyclicX             = True  

  xo                    = fspan(-65,-25,140)         ; informações de lat/lon obtidas do arquivo original, 144 e 73 = resolução
  yo                    = fspan(-50,-15,160)         ;  espacial do ncep que correspondem a um domínio de 2,5lat x 2,5lon

  fo                    = 0

  sst1_interp           = linint2_Wrap(lon,lat,sst1,fiCyclicX,xo,yo,fo)

	sst1_interp!0	        = "south_north"
	sst1_interp!1	        = "west_east"
	south_north@units     = "degree_north"
	west_east@units       = "degree_east"

  delete([/sst,sst1/])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Creates SST Lat and Long for COAWST, then interpolate          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  sst                   = b->SST(0,nl1:nl0,ml0:ml1)
  sst                   = sst-273.16
  sst1                  = mask(sst,lsm.ge.1,False)    
  copy_VarCoords(sst, sst1)

  south_north           = fspan(-50,-15,661)          
  south_north@long_name = "south_north"
  south_north@units     = "degree_north"
  sst1&south_north      = south_north          

  west_east             = fspan(-65,-25,615)         
  west_east@long_name   = "west_east"
  west_east@units       = "degree_east"
  sst1&west_east        = west_east          
 
  sst2_interp           = linint2_Wrap(lon,lat,sst1,fiCyclicX,xo,yo,fo)

	sst2_interp!0	        = "south_north"       
	sst2_interp!1	        = "west_east"
	south_north@units     = "degree_north"
	west_east@units       = "degree_east"

  delete([/sst,sst1/])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 5. Set GHRSST.                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  sstg = short2flt(c->analysed_sst(0,{-15:-50},{-65:-25}))
  sst  = sstg-273.16
  copy_VarCoords(sstg, sst)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 6. Creates Wind Lat and Long for WRF, then interpolate            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  u                     = a->U10(0,nl1:nl0,ml0:ml1)  
  v                     = a->V10(0,nl1:nl0,ml0:ml1)

  u1                    = mask(u,lsm.ge.1,False)     
  copy_VarCoords(u, u1)
  v1                    = mask(v,lsm.ge.1,False)     
  copy_VarCoords(v, v1)

  south_north           = fspan(-50,-15,661)         
  south_north@long_name = "south_north"
  south_north@units     = "degree_north"
  u1&south_north        = south_north          
  v1&south_north        = south_north 

  west_east             = fspan(-65,-25,615)             
  west_east@long_name   = "west_east"
  west_east@units       = "degree_east"
  u1&west_east          = west_east          
  v1&west_east          = west_east        

  u1_interp             = linint2_Wrap(lon,lat,u1,fiCyclicX,xo,yo,fo)

	u1_interp!0	          = "south_north"
	u1_interp!1	          = "west_east"
	south_north@units     = "degree_north"
	west_east@units       = "degree_east"

  v1_interp             = linint2_Wrap(lon,lat,v1,fiCyclicX,xo,yo,fo)
	v1_interp!0	          = "south_north"
	v1_interp!1	          = "west_east"
	south_north@units     = "degree_north"
	west_east@units       = "degree_east"

  delete([/u,v,u1,v1/])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 7. Creates Wind Lat and Long for COAWST, then interpolate            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  u                     = b->U10(0,nl1:nl0,ml0:ml1)  
  v                     = b->V10(0,nl1:nl0,ml0:ml1)

  u1                    = mask(u,lsm.ge.1,False)    
  copy_VarCoords(u, u1)
  
  v1                    = mask(v,lsm.ge.1,False)   
  copy_VarCoords(v, v1)

  south_north           = fspan(-50,-15,661)      
  south_north@long_name = "south_north"
  south_north@units     = "degree_north"
  u1&south_north        = south_north          
  v1&south_north        = south_north 

  west_east             = fspan(-65,-25,615)        
  west_east@long_name   = "west_east"
  west_east@units       = "degree_east"
  u1&west_east          = west_east          
  v1&west_east          = west_east         

  u2_interp             = linint2_Wrap(lon,lat,u1,fiCyclicX,xo,yo,fo)

	u1_interp!0	          = "south_north"
	u1_interp!1	          = "west_east"
	south_north@units     = "degree_north"
	west_east@units       = "degree_east"

  v2_interp             = linint2_Wrap(lon,lat,v1,fiCyclicX,xo,yo,fo)
	v1_interp!0	          = "south_north"
	v1_interp!1	          = "west_east"
	south_north@units     = "degree_north"
	west_east@units       = "degree_east"

  delete([/u,v,u1,v1/])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 8. Set QuikSCAT zonal and meridional components.                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  u = short2flt(d->zonal_wind_speed({-15:-50},{-65:-25}))
  v = short2flt(d->meridional_wind_speed({-15:-50},{-65:-25}))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 9. Workstation options.                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  wks_type = "png"
; wks_type@wkWidth = 2500
; wks_type@wkHeight = 2500       

  wks      = gsn_open_wks(wks_type,"plt_wsst_3")
  gsn_define_colormap(wks, "MPL_jet")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 11. Resources.                                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ; 11.1. Create plots.

   plot = new(3,graphic) 

 ; 11.2. Global Resources.

   res                           = True
   res@gsnDraw                   = False             ; don't draw
   res@gsnFrame                  = False             ; don't advance frame

   res@lbLabelBarOn              = False
   res@lbLabelAutoStride         = True              ; optimal label stride

   res@gsnScalarContour          = True              ; contours desired
   res@cnFillOn                  = True  
   res@cnLinesOn                 = False             ; turn off contour lines
   res@cnLineLabelsOn            = False             ; turn off contour line labels
   res@cnLevelSelectionMode      = "ManualLevels"    ; set manual contour levels
   res@cnMinLevelValF            = 0.                ; set min contour level
   res@cnMaxLevelValF            = 30.               ; set max contour level
   res@cnLevelSpacingF           = 1                 ; set contour spacing
   res@cnInfoLabelOn             = False             ; turn off contour label

   res@vcRefMagnitudeF           = 10.0              ; define vector ref mag
   res@vcRefAnnoString1          = "Vento: 10 m s~S~-1~N~"
   res@vcRefLengthF              = 0.047             ; define length of vec ref
   res@vcRefAnnoOrthogonalPosF   = 0.165
   res@vcRefAnnoParallelPosF     = 0.100
   res@vcRefAnnoFontHeightF      = 0.015
   res@vcRefAnnoOn               = True

   res@gsnLeftString             = " " 
   res@gsnRightString            = " "               ; "~" is txFuncCode
   res@vcMinDistanceF            = 0.03
   res@vcGlyphStyle              = "CurlyVector"     ; turn on curley vectors
   res@vcLineArrowColor          = "Black"           ; change vector color
   res@vcLineArrowThicknessF     = 2.5               ; change vector thickness

 ; 11.5. Plot 1 Resources.

   res1                          = res
   res1@gsnCenterString          = "WRF"
   res1@vcRefAnnoOn              = False

 ; 11.6. Plot 2 Resouces.

   res2                          = res
   res2@gsnCenterString          = "COAWST"
   res2@vcRefAnnoOn              = True

  ; 11.7. Plot 3 Resources.

   res3                          = res
   res3@gsnCenterString          = "Satellite Data"
   res3@vcRefAnnoOn              = False

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 12. Plots.                                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  plot(0) = gsn_csm_vector_scalar(wks,u1_interp,v1_interp,sst1_interp,res1) ; wrf
  plot(1) = gsn_csm_vector_scalar(wks,u2_interp,v2_interp,sst2_interp,res2) ; coawst
  plot(2) = gsn_csm_vector_scalar(wks,u,v,sst,res3) ; satellite

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 12. Panel resources, plot & end.                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ; 12.1. Panel Resources.

   resP                          = True
   resP@gsnPanelLabelBar         = True                 ; barra de cores igual p todas
   resP@gsnPanelFigureStrings    = (/"a","b","c", "d", "e", "f"/) ; add strings to panel
   resP@amJust                   = "TopLeft"            ; posição das letras ==> a) b) etc
   resP@lbLabelFontHeightF       = 0.001                ; tamanho dos gsnPanelFigureStrings (a,b,c,d...)
   resP@lbLabelFontHeightF       = 0.010
   resP@lbTitleFontHeightF       = 1.015                 ; make title smaller
   resP@lbTitleFontThicknessF    = 1
   resP@pmLabelBarOrthogonalPosF = -0.015
   resP@pmLabelBarParallelPosF   = 0.060
   resP@pmLabelBarWidthF         = 0.3
   resP@pmLabelBarHeightF        = 0.049 
   resP@lbTitleOn                = True
   resP@lbTitleString            =  "Temperatura da Superf"+iacute+"cie do mar (~S~o~N~C)"
   resP@lbTitlePosition          = "Top"
   resP@lbTitleFontHeightF       = 0.009

   ;resP@gsnPanelRowSpec         = True                  ; painéis complexos
   resP@gsnPanelCenter           = True                  ; novo comando ;-) - para centralizar, se for false ele alinha para esquerda
   resP@txString                 = "01/09/2006"

 ; 12.2. Plot.

   gsn_panel(wks,plot,(/1,3/),resP)              ; now draw as one plot

 ; 12.3. End.

   end
	
	















