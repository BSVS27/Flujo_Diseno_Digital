# Flujo para la Generanción de un SoC con las herramientas y Bibliotecas de Synopsys.
## Introducción
En el presente git se pretende enseñar y proveer los scripts necesarios para tormar un diseño en RTL y llevarlo hasta su sintesís física utilizando las bibliotecas de 180 nm de Synopsys.  Se proveé a modo de ejemplo el código RTL de una ALU a la cual se le aplicara todos los procesos necesarios para converger su síntesis física.  


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
  * **work:**
* **Back_end:** En esta carpeta se encuentra todos los archivos necesarios para la ejecución de la síntesis física. Su estructura es igual a la de front_end con la diferencia que su objetivo es la síntesis física.
* **Prime_time:**
* **Simulación:**
  * **Simulación RTL:** Dentro de ella se realizan las simulaciones funcionales del RTL y las simulacion usada para generar el saif correspondiente. Existe una carpeta destinada para cada tipo de test.
  * **Simulación post-synthesis:** Dentro de ella se realizan las simulaciones funcionales del netlist a nivel de compuertas y las simulacion usada para generar el saif correspondiente. Existe una carpeta destinada para cada tipo de test. 
 * **Simulación física:** Dentro de ella se realizan las simulaciones funcionales del netlist a nivel físico.
<p align="center">
  <img src="imagenes/Diagrama_carpetas.png">
</p>

