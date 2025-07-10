#==============================================================#
#                 MAPA DE DIAGRAMAS STIFF
#==============================================================#
# Este script genera un archivo de estilo .qml de QGIS 
# para la realización de mapas de Stiff
#==============================================================#

#==============================================================#
# INSTRUCCIONES

# 1) ARCHIVO DE DATOS
# Preparar un archivo .csv que contenga la siguiente información:
# Nombre de los puntos: ID (respectar nombre y mayúsculas)
# Coordenadas: X e Y (respectar nombre y mayúsculas)
# Concentraciones de iones mayoritarios en mg/L
# Los nombres de los iones se deben poner como el símbolo químico
# sin las cargas. Ej: Ca, Na, Cl, SO4, etc.

# 2) FUNCIONAMIENTO DEL SCRIPT
# Abrir R en la misma carpeta donde se ubica el archivo .csv 
# Recorrer las secciones del script siguiendo las instrucciones
# en cada una
# El script generará un archivo .svg por cada pozo con la forma del
# diagrama de Stiff, los cuales serán guardados en una subcarpeta
# llamada "svg" dentro de la carpeta actual.

# 3) FIN DEL PROCESO
# El proceso termina con la generación del archivo de estilo
# .qml en la sección 5, que será denominado "stiff_[max.escala].qml".

# 4) CARGAR EN QGIS
# Entrar en las propiedades de la capa y cargar el archivo de 
# estilo generado. 
