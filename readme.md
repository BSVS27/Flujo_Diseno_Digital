# Flujo para la Generanción de un SoC con las herramientas y Bibliotecas de Synopsys.
## Introducción
En el presente git se pretende enseñar y proveer los scripts necesarios para tormar un diseño en RTL y llevarlo hasta su sintesís física utilizando las bibliotecas de 180 nm de XFAB.  Se proveé a modo de ejemplo el código RTL de una ALU a la cual se le aplicara todos los procesos necesarios para converger su síntesis física.  


## Flujo
El flujo inicia usando como entrada el código verilog que describe el RTL. Inicialmente se verifica su funcionamiento y luego se corre una simulación especial para extraer un archivo saif. Estos tipos de archivos contienen la información de switching para hacer una estimación de potencia de un diseño bajo las condiciones expuestas en la simulación. Ambos archivos (RTL y saif) se utilizan en la herramienta **Design Compiler** para ejecutar la síntesis y obtener un archivo verilog a nivel de compuertas con una primera estimación de consumo. Para la síntesis física se corre un proceso similar con la diferencia que se utiliza como entrada el verilog a nivel de compuertas y el archivo saif de su simulación. Al final de todo este flujo se quiere obtener un archivo GDSII que utiliza el fabricante para la construcción del chip. El flujo utilizado se muestra en la próxima imagen.
<p align="center">
  <img src="imagenes/Flujo_topo.png">
</p>

## Jerarquía de Carpetas
Con el fin de mantener todos los archivos ordenados y una localización estandarizada para los scripts se utiliza la siguiente jerarquía de carpetas:

* **Front_end:** En esta carpeta se encuentran todos los archivos fuente, scipts y carpetas necesarias para la sintesis a nivel de compuertas apartir del RTL especificado. Se compone de las siguientes carpetas :
  * **Source:** En ella estan todos los archivos que sirven de entrada para la síntesis del RTL. (Código verilog y Saif de la simulación). Aquí también se guarda el netlist de salida con la información de las compuertas.
  * **scripts:** En esta carpeta estan guardados todos los scripts utilizados para la síntesis lógica.
  * **reports:** Aquí se guardan los reportes generados por el **Design Compiler**.
  * **db:** En ella se guardan los archivos resultantes, que no son reportes, de la síntesis lógica.
  * **work:** En esta carptera se guardan los archivos temporales durante la ejecución de los scripts.
* **Back_end:** En esta carpeta se encuentra todos los archivos necesarios para la ejecución de la síntesis física. Su estructura es igual a la de front_end con la diferencia que su objetivo es la síntesis física.
* **Prime_time:**
* **Simulación:**
  * **Simulación RTL:** Dentro de ella se realizan las simulaciones funcionales del RTL y las simulacion usada para generar el saif correspondiente. Existe una carpeta destinada para cada tipo de test.
  * **Simulación post-síntesis:** Dentro de ella se realizan las simulaciones funcionales del netlist a nivel de compuertas y las simulacion usada para generar el saif correspondiente. Existe una carpeta destinada para cada tipo de test. 
  * **Simulación física:** Dentro de ella se realizan las simulaciones funcionales del netlist a nivel físico.
<p align="center">
  <img src="imagenes/Diagrama_carpetas.png">
</p>

# Descarga Git
Para descargar este repositorio se utiliza la intrucción ``git clone`` desde la terminal ubicada en el sitio de trabajo. Existen dos formas de usar esta instrucción que son utilizando la dirección https o la dirección ssh. Usualmente se usa la https, pero debido a que centos tiene un problema con ella se usará la ssh. 
```
git clone git@github.com:esolera/Flujo_Diseno_Digital.git
```
En caso de que también falle la ssh, se puede descargar el zip desde la pagina de github. Finlizada la clonación es necesario entrar en el repositorio para continuar con el tutorial.
# Simulación de RTL
## Simulación Funcional
Antes de iniciar cualquier síntesis es necesario haber verificado que RTL no contenga errores (Esto siempre es un paso fundamental). Para ellos se destino un espacio de trabajo en ```Simulaciones/Sim_RTL/funcional/```. En el caso de la alu se tiene dentro de esta carpeta un test y un archivo file_list. Se utiliza la herramienta vcs para realizar simulaciones sobre el file_list el cual llama a todos los archivos verilog incluyendo al diseño y al test. Para ejecutar la simulación solo se debe ejecutar los siguientes comandos:
```
vcs -sverilog -debug_access+all -R -full64 -gui -f file_list
```
 Es importante denotar que el file_list debe verse así donde por último se llama al test:
```
../../../front_end/source/top.sv
../../../front_end/source/ALU_2.sv
../../../front_end/source/Barrel_Shifter.sv
../../../front_end/source/csk_bloque.sv
../../../front_end/source/CSK_sin_mux.sv
test_top.sv
```
Después de su ejecución se abrira una interfaz gráfica con toda la información del diseño y el test. Para iniciar la simulación primero debe seleccionarse las ondas que desean verse como se muestra en la figura. 

<p align="center">
  <img src="imagenes/vcs_RTL.png">
</p>
Esto abrira una ventana en la cual se debera apretar el boton de run que se muestra en la próxima imagen para ejecutar la simulación. Para tener una mejor visualización de todas las ondas hay que apretar el boton de escalado, si durante todo el tiempo la bandera de error se mantuvo en bajo significa que el diseño aprobo la prueba.

<p align="center">
  <img src="wave_RTL.png">
</p>

## Simulación SAIF
# Síntesis Lógica
Ya con el repositorio clonado se iniciara explicando en esta sección como tomar diseño RTL y sintetizarlo a nivel de compuertas con las herramientas Design Compiler. Se utilizará a modo de ejemplo una ALU diseñada en el laboratorio DCILAB. 

Antes de iniciar es necesario correr el script que instancia todas las varaibles locales utilizadas para localizar las herramientas de synopsys. Este script esta ubicado en el directorio principal y se llama "**synopsys_tools.sh**". Para su ejecución copie este comando:
```
source synopsys_tools.sh
```
Ahora deben dirigirse a la carpeta front_end y abrir todo el contenido que hay en scripts con algun editor de texto, en este caso se usara sublime text. Para realizar esto ejecute los siguientes comandos:
```
cd front_end
subl scripts/*
```
Todos los scripts se han desplegado en su pantalla, y debe dirigirse al llamado **run_all.tcl**. Este programa es usado para llamar a todos los scripts y ejecutar la síntesis en un solo comando. Todos los scripts que él llama se han abierto ya en el editor de texto, a excepción de 2 :
* **el user**: Instancia una serie de variables con nombres y direcciones que las herramientas necesitan para que encontrar y guardar archivos en su lugar correspondiente.
* **common_setup.tcl:** Inicia agregando unas direcciones en el search path para que las herramientas encuentren la información de la tecnología que necesitan para la sintesís.
Ambos estan ubicados en la carpeta principal por que son usados por todas las herramientas para setear el ambien de diseño.
Ahora se abrirá la herramienta **Design Compiler**:
```
dc_shell -topo
```
