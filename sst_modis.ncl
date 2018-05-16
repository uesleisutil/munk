;;; modis_sst.ncl ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Autor              - Ueslei Adriano Sutil                                    ;
; Email              - ueslei@outlook.com                                      ;
; Criado em          - 08 May 2018                                             ;
; Última atualização - 16 May 2018                                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Carrega as funções do NCL.
; Alterar o diretório para o local onde você colocou o arquivo loads.ncl
load "/home/ueslei/NCL/loads.ncl"
begin

; Abre os arquivos do Modis-Aqua
; Deixar todos os arquivos na mesma pasta para que o script escaneie todos os
; arquivos.
modis_files_s = systemfunc("ls /media/ueslei/Ueslei/SC_2008/Scripts/NCL/A20*")
modis_files_n = dimsizes(modis_files_s)
modis_files   = addfiles(modis_files_s,"r")

; Cria o loop para criar as figuras de acordo com o arquivo.
do modis_loop = 0,modis_files_n-1

  ; Opções de plotagem.
  pltType          = "png"
  pltType@wkWidth  = 1000
  pltType@wkHeight = 1000
  pltName          = "sst_modis_"+modis_loop
  pltDir           = "./"
  pltPath          = pltDir + pltName
  wks              = gsn_open_wks(pltType, pltName)
  gsn_define_colormap(wks, "MPL_jet")

  ; Extrai as variáveis.
  ; A variável SST do Modis-Aqua está escrita em formato short.
  ; É necessário transformar para formato float com a função short2float.
  lat_m       = modis_files[modis_loop]->lat
  lon_m       = modis_files[modis_loop]->lon
  sst_m_float = modis_files[modis_loop]->sst
  sst_m       = short2flt(sst_m_float)

  ; Recursos gerais para plotagem.
  res                               = True
  res@gsnFrame                      = False
  res@gsnDraw                       = False
  res@gsnLeftString                 = " "
  res@gsnRightString                = " "
  res@gsnCenterString               = " "
  res@gsnCenterStringOrthogonalPosF = 0.01
  res@gsnAddCyclic                  = False
  res@tiXAxisString                 = " "
  res@tiYAxisString                 = " "
  res@sfXArray                      = lon_m
  res@sfYArray                      = lat_m

  ; Recursos de mapa I.
  mpres                               = res
  mpres@mpDataSetName                 = "Earth..4"
  mpres@mpDataBaseVersion             = "MediumRes"
  mpres@mpOutlineOn                   = True
  mpres@mpOutlineSpecifiers           = (/"Brazil:states"/)
  mpres@mpProvincialLineColor         = "black"
  mpres@mpGeophysicalLineColor        = "black"
  mpres@mpNationalLineColor           = "black"
  mpres@pmLegendOrthogonalPosF        = -0.99
  mpres@pmLegendParallelPosF          = 1.0
  mpres@mpProvincialLineThicknessF    = 3
  mpres@mpNationalLineThicknessF      = 3
  mpres@mpGeophysicalLineThicknessF   = 3.0
  mpres@mpPerimOn                     = True
  mpres@mpPerimLineThicknessF         = 3.0
  mpres@mpGridAndLimbOn               = False
  mpres@mpGridLatSpacingF             = 1
  mpres@mpGridLonSpacingF             = 1
  mpres@tmXBTickSpacingF              = 1
  mpres@tmYLTickSpacingF              = 1
  mpres@mpMinLonF                     = -49.0
  mpres@mpMaxLonF                     = -44.0
  mpres@mpMinLatF                     = -27.0
  mpres@mpMaxLatF                     = -23.0
  mpres@mpLandFillColor               = "gray"
  mpres@tmXBLabelFontHeightF          = 0.012
  mpres@tmYROn                        = False
  mpres@tmXTOn                        = False

  ; Recursos para a variável SST.
  res_sst_m                           = res
  res_sst_m@cnFillOn                  = True
  res_sst_m@cnLinesOn                 = False
  res_sst_m@cnLevelSelectionMode      = "ManualLevels"
  res_sst_m@cnMinLevelValF            = 15
  res_sst_m@cnMaxLevelValF            = 27
  res_sst_m@cnLevelSpacingF           = 0.5
  res_sst_m@lbLabelFontHeightF        = 0.014
  res_sst_m@lbTitleFontHeightF        = .015
  res_sst_m@lbTitleString             = "[~S~o~N~C]"
  res_sst_m@lbOrientation             = "Horizontal"
  res_sst_m@lbTitleFontThicknessF     = 1
  res_sst_m@pmLabelBarOrthogonalPosF  = 0.139
  res_sst_m@pmLabelBarWidthF          = 0.5
  res_sst_m@pmLabelBarHeightF         = 0.059
  res_sst_m@gsnCenterString           = "Modis-Aqua: SST"

  ; Cria o contorno para a SST, porém ainda não plota a figura.
  contour_sst = gsn_csm_contour(wks,sst_m,res_sst_m)

  ; Recursos de mapa II.
  ; Plota em projeção Cilíndrica Equidistante, seguindo o formato dos dados do Modis- Aqua.
  mpres@gsnFrame = False
  mpres@gsnDraw  = False
  mpres          = wrf_map_resources(modis_files[modis_loop],mpres)
  map            = gsn_csm_map_ce(wks,mpres)

  ; Plota a SST usando overlay.
  overlay(map,contour_sst)
  draw(map)
  frame(wks)

  ; Corta o espaço em branco em volta doa figura.
  system("convert -trim "+pltPath+"."+pltType+" "+pltPath+"."+pltType)

end do
end
