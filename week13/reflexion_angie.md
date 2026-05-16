# Reflection Essay — Week 13
### Angelina R.

---

Antes de empezar esta práctica, mi relación con Docker se limitaba a usarlo como una forma de tener librerías o entornos específicos para otras prácticas de la carrera. Era una herramienta que usaba sin entender realmente qué había detrás. Kubernetes y Terraform directamente no existían en mi vocabulario técnico. Seis semanas después, tengo una visión completamente distinta de cómo funciona la infraestructura moderna.

Lo que más me ha costado, sin duda, ha sido todo lo relacionado con redes. Las NetworkPolicies de Kubernetes, el diseño de subredes con CIDR, entender cómo fluye el tráfico entre pods... son conceptos que en la carrera apenas tocamos, y notaba que me faltaba base. Cuando algo no funcionaba — un timeout, una conexión bloqueada — me costaba saber si el problema era la política de ingress, la de egress, el selector, o simplemente que el pod no había arrancado bien. Con el tiempo aprendí a diagnosticar sistemáticamente, pero fue el área donde más tiempo perdí y donde siento que todavía tengo más por aprender.

Por contraste, Docker fue lo que más me enganchó. Sabía usarlo superficialmente, pero no había entendido su propósito real: garantizar que una aplicación se comporta igual en cualquier máquina. Cuando ves que la misma imagen que corres en local es exactamente la que se despliega en producción, el concepto de "funciona en mi máquina" desaparece. Eso tiene mucho valor en equipos donde cada persona tiene un entorno distinto. Además, escribir un Dockerfile desde cero y ver cómo cada línea tiene un impacto en el tamaño y la seguridad de la imagen me pareció más interesante de lo que esperaba.

Lo que más me sorprendió fue lo accesibles que son Kubernetes y Terraform. Tenía la idea de que eran herramientas para grandes empresas con equipos de infraestructura dedicados, difíciles de aprender y de poner en marcha. Pero con Minikube y un par de archivos YAML ya tienes un clúster funcionando, con escalado automático y recuperación ante fallos. Y con Terraform, definir toda la infraestructura en código y poder recrearla desde cero con un solo comando es algo que antes me parecía magia y ahora entiendo perfectamente.

Sobre el orden de la práctica, creo que está muy bien pensado. Cada semana introduce una necesidad real que la siguiente herramienta viene a resolver: primero empaquetas la aplicación, luego necesitas coordinar varios contenedores, luego necesitas escalar en producción, luego automatizar, y finalmente asegurar y observar. Es una progresión natural que refleja cómo evoluciona de verdad una infraestructura cuando una empresa crece. No cambiaría el orden.

De cara al futuro, me llama mucho más el mundo cloud — es lo que domina el mercado ahora mismo y donde están las oportunidades.
 
En resumen, esta práctica me ha dado una visión mucho más completa de lo que significa construir y operar infraestructura moderna. No como una lista de comandos a memorizar, sino como un conjunto de decisiones de diseño con sus trade-offs: ¿Docker Compose o Kubernetes? ¿Terraform o Ansible? ¿Cuándo segmentar la red? ¿Cómo garantizar que lo que funciona hoy siga funcionando cuando el equipo crezca? 
