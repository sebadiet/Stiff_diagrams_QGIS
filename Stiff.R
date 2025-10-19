#===================================================================#
#                   STIFF DIAGRAMAS GENERATOR                       #
#===================================================================#
#  This script is intended to help in generating Stiff maps for     #
# hydrochemical data interpretation.                                # 
#                                                                   # 
#  The scripts generate a separate .svg file for each water sample. #
#  The integration within QGIS software is possible by means of     #
# the writing of a .qml style file                                  #
#                                                                   # 
# Just follow the instructions, step by step.                       #
# For more information, please refer to the original publication:   #
#                                                                   # 
# Dietrich, S., 2025. An R script for integrating stiff diagrams    #
# in QGIS.                                                          #
#                                                                   # 
# Please, don't forget to cite this article.                        #
#                                                                   # 
# If you have any doubt, don't hesitate to e-mail me.               #
# sebadietrich@ihlla.org.ar                                         #
#===================================================================#
#                                                                   # 
#===================================================================#

#===================================================================#
# SECTION 0 - Data preparation                                      #
#===================================================================#

# Prepare a .csv file with the following information:
# a) ID: names of the samples. Use short names
# b) X and Y: coordiantes.
# c) Concentrations of the ions in mg/L or ppm.
# Name each column with the names of the ions as follows: 
# Na, Ca, Mg, K, Cl, SO4, HCO3, CO3, NO3.
#  If you have no data of any of these fields, complete them
# with a very low value, such as 1E-10. Otherwise, see 
# Data loading section to automatically replace NAs.
#
# You MUST respect the case in the field names.

#===================================================================#
# SECTION 1 - Data loading                                          #
#===================================================================#

# Type your file name
# You may wish to include the path if the file is not located in the
# same folder as the script.

file.name <- "Zabala2020_sep19.csv"

# Load the data into R

# Note that comma (",") is the default separation character under the
# "sep" option. Please, change accordingly.

chem.data <- read.table(file.name, header=TRUE, sep=",")

# Explore your data and look for errors
chem.data # The entire file
str(chem.data) #Data structure

# Optional - Replace NAs with small values
#chem.data[is.na(chem.data)] <- 1E-10
#chem.data # Check that the replacements were effectively taken place


#===================================================================#
# SECTION 2 - Units conversion and matrix generation                #
#===================================================================#
#-------------------------------------------------------------------#
# STEP 1 - Equivalente weight 
#-------------------------------------------------------------------#

# Elements and compounds
EW <- c(
  Ca    = 40.08/(+2), 
  Mg    = 24.31/(+2), 
  Na    = 22.99/(+1), 
  K     = 39.10/(+1), 
  Cl    = 35.45/(-1), 
  NO3   = 62.01/(-1),
  HCO3  = 61.02/(-1), 
  CO3   = 60.02/(-2), 
  SO4   = 96.07/(-2)
)

# Check the results
EW

#--------------------------------------------------------------#
# STEP 2 - Convertion from mg/l to meq 
#--------------------------------------------------------------#

ions <- c("Ca", "Mg", "Na", "K", "Cl", "NO3", "HCO3", "CO3", "SO4")

# Creation of an auxiliary raw matrix
m.aux <- as.matrix(
	sapply(ions, function(x) {chem.data[[x]] / EW[x]})
)
rownames(m.aux) <- chem.data$ID         # ID as a row name
colnames(m.aux) <- paste0(ions, ".meq") # Ions + meq as column name

# Check the matrix
m.aux
head(m.aux) # Check columns names (only the first six rows are shown.

# Creation of definite meq/l matrix

matrix.meq <- as.matrix(
	data.frame("Na + K" = m.aux[,"Na.meq"]   + m.aux[,  "K.meq"],
	   	 "Mg"       = m.aux[,"Mg.meq"],
		 "Ca"       = m.aux[,"Ca.meq"], 
		 "HCO3 + CO3"  = m.aux[,"HCO3.meq"] + m.aux[,"CO3.meq"],
		 "SO4"      = m.aux[,"SO4.meq"],
		 "Cl"       = m.aux[,"Cl.meq"],
	 # Optionally, you may want to add NO3 to Cl. In this case, comment the above line of code and uncomment the next one.
		 #"Cl + NO3"      = m.aux[,"Cl.meq"] + m.aux[, "NO3.meq"],
		 check.names = FALSE
))

# Analize the generated final matrix
print(noquote(formatC(matrix.meq, digits = 2, format = "f", width = 6)))

#===================================================================#
# SECTION 3 - Stiff diagrams generation
#===================================================================#

#  This section ends up with the Stiff diagram generation and the 
# reference diagram. The section was dividid into five steps.

#-------------------------------------------------------------------#
# STEP 1 - Graphic scale selection
#-------------------------------------------------------------------#
# In this step, a proper graphic scale is decided

# Choose the rounding increment (2, 5, or 10) for the scaling

# Inspect absolute minimum and maximum values for each ion and the select
# a rounding value accordingly.

cat("The absolute minimum values are:", 
    capture.output(print(apply(abs(matrix.meq), 2, min))), sep = "\n")
cat("The absolute maximum values are:", 
    capture.output(print(apply(abs(matrix.meq), 2, max))), sep = "\n")

round.value <- 5 

max.scale <- ceiling(max(abs(matrix.meq))/round.value)*round.value
cat("The calculated max scale is:\n", 
    max.scale, "meq/l\n")


# If you do not agree with with automatic scale, uncomment the following lines, enter your desired value and check the entered scale by running the cat function.

#max.scale <- 30 

#cat("The manually selected max scale is:\n", 
#    max.scale, "meq/l\n")

#--------------------------------------------------------------#
# STEP 2 - Aspect ratio
#--------------------------------------------------------------#
# Define the ratio between length and width.
# aspect.ratio < 1 -> wider diagrams
# aspect.ratio > 1 -> higher diagrams

aspect.ratio <- 0.6 # A value of 0.6 is highly recommended.  

#--------------------------------------------------------------#
# STEP 3 - Diagrams colour.
#--------------------------------------------------------------#

#  Select one among the 657 R built-in colors. Use colors() to get a
# list of all of them. 
#  Visit https://r-graph-gallery.com/42-colors-names.html for details.
#  Some options are provided below. Some of them, may be graded by adding
# a number from 1 to 4 at the end of the color name. 
#  Colours may be also provided as an RGB code using rgb() function. 
#  To select the provided colors just uncomment the desired line

matrix.color <- "springgreen"   # 1 up to 4 may be addd at the end
#matrix.color <- "lavenderblush" # 1 up to 4 may be addd at the end
#matrix.color <- "mediumorchid"  # 1 up to 4 may be addd at the end
#matrix.color <- "deepskyblue"   # 1 up to 4 may be addd at the end
#matrix.color <- "forestgreen"

#--------------------------------------------------------------#
# STEP 4 - Stiff plotting
#--------------------------------------------------------------#

#  An .svg file for each sample is created. They are named with the
# ID field in the data file. A different folder is created each time
# users change the scale.

folder.name <- paste0("svg_", max.scale, "_meq")
dir.create(folder.name, showWarnings = FALSE)

#  Creates an empty vector with the number of rows in the matrix
mypath <- character(dim(matrix.meq)[1])

#  Function to create the diagrams.
for (i in 1:dim(matrix.meq)[1]) {
        x <- matrix.meq[i, 1:dim(matrix.meq)[2]]*(-1)
        y <- c(1, 0.5, 0, 0, 0.5, 1)

        mypath[i] <- file.path(getwd(), folder.name, paste(rownames(matrix.meq)[i], ".svg", sep = ""))
        print(mypath[i])  
        svg(file = mypath[i], 
	    height = 5*aspect.ratio, 
	    width = 5, 
	    bg = "transparent"
	)
	par(mar = c(0.5, 0.5, 2, 0.5))
        plot(x, y, 
	     xlim = c(-max.scale, max.scale), 
	     ylim = c(-0.2, 1.2), 
	     axes = FALSE, 
	     ann = FALSE, 
	     xaxs = "i", 
	     yaxs = "i", 
	     cex = 0.0
	)
        polygon(x, y, 
		col = matrix.color, 
		border = "black", 
		lwd = 1.0
	)
        lines(c(0, 0), c(-0.1, 1.1), lwd = 1.0)
        dev.off()
        Sys.sleep(0.1)
}

#--------------------------------------------------------------#
# STEP 5 - Stiff reference diagrams
#--------------------------------------------------------------#
#  A diagram is generated with the aim at being included in the 
# references on the final map created with the layout. This Stiff diagram differs from the others by including axis labels and by the positioning of the represented ions. 

# By default, the first element is plotted for reference.
reference <- 1 # Change the order number of your disered sample
# Valores a graficar
x <- matrix.meq[reference, 1:dim(matrix.meq)[2]]*(-1)
y <- c(1, 0.5, 0, 0, 0.5, 1)

# Tick marks 
# By default, three tick marks between zero and the maximum value are set
num.ticks <- 4 # Default value
at.ticks <- seq(-max.scale, max.scale, abs(max.scale - 0)/num.ticks)

# Labels
# By default, only one label between zero and the maximum value is set
num.label <- 2 # Default value
at.lab <- seq(-max.scale, max.scale, abs(max.scale - 0)/num.label) 

# Ions text position
xtext <- c(rep(-max.scale,3), rep(max.scale,3))
ytext <- c(1.05, 0.5,-0.05, -0.05, 0.5, 1.05)

# Text adjustment
adj.text <- c(rep(4,3), rep(2,3))

# Scale file path
mypath.scale <- file.path(getwd(), folder.name, paste("Scale_", max.scale, "_meq_", rownames(matrix.meq)[reference], ".png", sep = ""))

# Print the scale file. Run the code to the end of this section
png(file = mypath.scale, 
     height = 5*aspect.ratio, 
     width = 5, 
     bg = "transparent", 
     units = "in", 
     res = 200
)
par(mar = c(0.2, 0.9, 3.5, 0.9))
par(mgp = c(2, 0.2, 0.1))
plot(x, y, 
     xlim = c(-max.scale, max.scale), 
     ylim = c(-0.1, 1.2), 
     axes = FALSE, 
     ann = FALSE, 
     xaxs = "i", 
     yaxs = "i", 
     cex = 0.0
)
  polygon(x, y, 
	  col = matrix.color, 
	  border = "black", 
	  lwd = 1
  )
  polygon(x, y, 
	  border = "black", 
	  lwd = 2
  )  
  lines(c(0, 0), c(-0.1, 1.1), lwd = 2)
  axis(3, 
       at = at.lab, 
       labels = NA, 
       tck = 0.04, 
       lwd = 0.8, 
       cex.axis = 0.8, 
       pos = 1.2
  )
  axis(3, 
       at = at.ticks, 
       labels = ifelse(at.ticks %in% at.lab, abs(at.ticks), ""), 
       tck = -0.02, 
       lwd = 0.5, 
       cex.axis = 1.5, 
       pos = 1.2
  )
  text(xtext, ytext, 
       colnames(matrix.meq), 
       pos = adj.text, 
       cex = 1.2,
       offset = 0.0
  )
  mtext("meq/l", 
	side = 3, 
	line = 1.5, 
	cex = 2
  )
dev.off()

#==============================================================#
# SECTION 4 - Generation of a .qml QGIS style file
#==============================================================#

# Select the size. A value between 40 and 50 mm is recommended.
size <- 40 # mm 

# RUN TO THE END WITHOUT CHANGING ANYTHING.

# Function to generate a specified number of UUID-like strings

generateMultipleUUIDs <- function(n) {
  hex.chars <- c(0:9, letters[1:6])
  uuids <- vector("character", length = n)

  for (i in 1:n) {
    uuid <- paste0(
      paste0(sample(hex.chars, 8, replace = TRUE), collapse = ''),
      "-",
      paste0(sample(hex.chars, 4, replace = TRUE), collapse = ''),
      "-4",
      paste0(sample(hex.chars[1:3], 3, replace = TRUE), collapse = ''),
      "-",
      paste0(c("8", "9", "a", "b")[sample(1:4, 1)],
             paste0(sample(hex.chars, 3, replace = TRUE), collapse = ''),
             "-",
             paste0(sample(hex.chars, 12, replace = TRUE), collapse = '')
      )
    )
    uuids[i] <- uuid
  }

  return(uuids)
}

# Generate 5 UUID-like strings
num.uuids.gen <- 1
num.uuids.ID  <- dim(matrix.meq)[1]
uuids.gen     <- generateMultipleUUIDs(num.uuids.gen) 
uuids.ID      <- generateMultipleUUIDs(num.uuids.ID) 

# Print the generated UUID-like strings
#print(uuids)

# Define the QML content with different SVG files for each point

qml.name <- paste0("stiff_", max.scale, "_meq.qml")
con1 <- file(qml.name, open = "w")

# HEADER 
cat("<","!DOCTYPE qgis PUBLIC ","\'http://mrcc.com/qgis.dtd\'"," \'SYSTEM\'",">", 
    "\n<qgis labelsEnabled=", "\"0\"", " readOnly=", "\"0\"", " styleCategories=", "\"LayerConfiguration|Symbology|Symbology3D|Labeling|Notes\"", " version=", "\"3.22.4-Białowieża\"", ">",
    "\n  <flags>",
    "\n    <Identifiable>", 1, "</Identifiable>",
    "\n    <Removable>", 1, "</Removable>",
    "\n    <Searchable>", 1, "</Searchable>",
    "\n    <Private>", 0, "</Private>",
    "\n  </flags>",
    "\n  <renderer-v2 type=","\"RuleRenderer\"", " symbollevels=", "\"0\"", " enableorderby=", "\"0\"", " referencescale=", "\"-1\"", " forceraster=", "\"0\"", ">",

    "\n    <rules key=\"{", uuids.gen, "}\">",
sep="", file = con1, append=TRUE)


for(i in 1:dim(matrix.meq)[1]){
   cat("\n      <rule label =\"", rownames(matrix.meq)[i], "\" symbol=\"", i-1, "\" filter=\"&quot;ID&quot; = \'", rownames(matrix.meq)[i], "\'\" key=\"{", uuids.ID[i],"}\"/>", 
sep="", file = con1, append = TRUE) 
}
cat("\n    </rules>",
    "\n    <symbols>",
sep="", file = con1, append=TRUE)

for(i in 1:dim(matrix.meq)[1]){
   cat(
    "\n      <symbol type=\"", "marker", "\" alpha=\"", 1, "\" clip_to_extent=\"", 1, "\" force_rhr=\"", 0, "\" name =\"", i-1, "\">", 
    "\n        <data_defined_properties>", 
    "\n          <Option type=\"Map\">", 
    "\n            <Option type=\"QString\" value=\"\" name=\"name\"/>", 
    "\n            <Option name=\"properties\"/>", 
    "\n            <Option type=\"QString\" value=\"collection\" name=\"type\"/>", 
    "\n          </Option>", 
    "\n        </data_defined_properties>", 
    "\n        <layer class=\"", "SvgMarker", "\" locked=\"", 0, "\" pass=\"", 0, "\" enabled=\"", 1, "\">", 
    "\n          <Option type=\"Map\">", 
    "\n            <Option type=\"QString\" value=\"", 0, "\" name=\"angle\"/>", 
    "\n            <Option type=\"QString\" value=\"", matrix.color[i], "\" name=\"color\"/>", 
    "\n            <Option type=\"QString\" value=\"", 0, "\" name=\"fixedAspectRatio\"/>", 
    "\n            <Option type=\"QString\" value=\"", 1, "\" name=\"horizontal_anchor_point\"/>", 
    "\n            <Option type=\"QString\" value=\"", mypath[i], "\" name=\"name\"/>", 
    "\n            <Option type=\"QString\" value=\"", "0,0", "\" name=\"offset\"/>", 
    "\n            <Option type=\"QString\" value=\"", "3x:0,0,0,0,0,0", "\" name=\"offset_map_unit_scale\"/>", 
    "\n            <Option type=\"QString\" value=\"", "MM", "\" name=\"offset_unit\"/>", 
    "\n            <Option type=\"QString\" value=\"", "50,87,128,255", "\" name=\"outline_color\"/>", 
    "\n            <Option type=\"QString\" value=\"", 0.4, "\" name=\"outline_width\"/>", 
    "\n            <Option type=\"QString\" value=\"", "3x:0,0,0,0,0,0", "\" name=\"outline_width_map_unit_scale\"/>", 
    "\n            <Option type=\"QString\" value=\"", "MM", "\" name=\"outline_width_unit\"/>", 
    "\n            <Option name=\"parameters\"/>", 
    "\n            <Option type=\"QString\" value=\"", "diameter", "\" name=\"scale_method\"/>", 
    "\n            <Option type=\"QString\" value=\"", size, "\" name=\"size\"/>", 
    "\n            <Option type=\"QString\" value=\"", "3x:0,0,0,0,0,0", "\" name=\"size_map_unit_scale\"/>", 
    "\n            <Option type=\"QString\" value=\"", "MM", "\" name=\"size_unit\"/>", 
    "\n            <Option type=\"QString\" value=\"", 1, "\" name=\"vertical_anchor_point\"/>", 
    "\n          </Option>", 
    "\n          <prop k=\"angle\" v=\"", 0, "\"/>", 
    "\n          <prop k=\"color\" v=\"", matrix.color[i], "\"/>", 
    "\n          <prop k=\"fixedAspectRatio\" v=\"", 0, "\"/>", 
    "\n          <prop k=\"horizontal_anchor_point\" v=\"", 1, "\"/>", 
    "\n          <prop k=\"name\" v=\"", mypath[i], "\"/>", 
    "\n          <prop k=\"offset\" v=\"", "0,0", "\"/>", 
    "\n          <prop k=\"offset_map_unit_scale\" v=\"", "3x:0,0,0,0,0,0", "\"/>", 
    "\n          <prop k=\"offset_unit\" v=\"", "MM", "\"/>", 
    "\n          <prop k=\"outline_color\" v=\"", "50,87,128,255", "\"/>", 
    "\n          <prop k=\"outline_width\" v=\"", "0.4", "\"/>", 
    "\n          <prop k=\"outline_width_map_unit_scale\" v=\"", "3x:0,0,0,0,0,0", "\"/>", 
    "\n          <prop k=\"outline_width_unit\" v=\"", "MM", "\"/>", 
    "\n          <prop k=\"parameters\" v=\"\"/>", 
    "\n          <prop k=\"scale_method\" v=\"diameter\"/>", 
    "\n          <prop k=\"size\" v=\"", size, "\"/>", 
    "\n          <prop k=\"size_map_unit_scale\" v=\"", "3x:0,0,0,0,0,0", "\"/>", 
    "\n          <prop k=\"size_unit\" v=\"", "MM", "\"/>", 
    "\n          <prop k=\"vertical_anchor_point\" v=\"", 1, "\"/>", 
    "\n          <data_defined_properties>", 
    "\n            <Option type=\"Map\">", 
    "\n              <Option type=\"QString\" value=\"\" name=\"name\"/>", 
    "\n              <Option name=\"properties\"/>", 
    "\n              <Option type=\"QString\" value=\"", "collection", "\" name=\"type\"/>", 
    "\n            </Option>", 
    "\n          </data_defined_properties>", 
    "\n        </layer>", 
    "\n      </symbol>", 
sep="", file = con1, append = TRUE) 
}

cat(
    "\n    </symbols>", 
    "\n  </renderer-v2>", 
    "\n  <blendMode>0</blendMode>", 
    "\n  <featureBlendMode>0</featureBlendMode>", 
    "\n  <previewExpression>\"ID\"</previewExpression>", 
    "\n  <layerGeometryType>0</layerGeometryType>", 
    "\n</qgis>", 
sep="", file = con1, append=TRUE)


close(con1)       

#==============================================================#
# END OF THE SCRIPT
#==============================================================#
