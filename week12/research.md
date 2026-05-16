# Week 12 - Investigación: Servicios de Red e Identidad

## 1. Servicios de Red

### DNS (Domain Name System)

DNS traduce nombres de dominio (como `greendecorp.internal`) en direcciones IP. Sino, habría que memorizar la IP de cada servicio, lo cual no escala. El dispositivo pregunta al servidor DNS y este devuelve la IP correspondient

Para el sistema que estamos haciendo es esencial tener DNS interno para que los servicios se comuniquen por nombre en lugar de por IP. En Kubernetes esto ya viene resuelto con CoreDNS, que permite que los pods se encuentren entre sí usando el nombre del Service.

### DHCP (Dynamic Host Configuration Protocol)

DHCP asigna automáticamente una IP y configuración de red (máscara, gateway, DNS) a cada dispositivo que se conecta. Sin DHCP habría que configurar manualmente cada portátil, móvil o servidor, lo que con 20+ personas es inviable y propenso a conflictos de IPs duplicadas.

Las IPs se asignan por tiempo limitado (lease), así que cuando un dispositivo se desconecta, su IP queda libre para otro. Esto hace que añadir nuevos empleados o dispositivos no requiera intervención del administrador.

### NTP (Network Time Protocol)

NTP sincroniza los relojes de todos los sistemas con una fuente de tiempo fiable. Si los certificados TLS tienen fechas de validez, los tokens de autenticación expiran en segundos, y los logs pierden su utilidad si los eventos no están ordenados correctamente.

En un entorno con múltiples contenedores y nodos como el nuestro, si los relojes no están sincronizados, correlacionar logs de distintos servicios para diagnosticar un fallo se vuelve muy difícil.

## 2. Gestión de Identidad

### Autenticación vs. Autorización

**Autenticación** es verificar quién eres, el sistema comprueba que tus credenciales son válidas.

**Autorización** es decidir qué puedes hacer una vez autenticado. Por ejemplo, un desarrollador puede leer logs de producción pero no borrar pods.

### LDAP, Active Directory y SSO

**LDAP** es un protocolo estándar para gestionar directorios de usuarios y grupos. Las aplicaciones lo consultan para autenticar usuarios o saber a qué grupos pertenecen. 

**Active Directory (AD)** es la implementación de Microsoft sobre LDAP y Kerberos. Es el estándar en entornos Windows y permite gestionar usuarios, equipos y políticas de seguridad desde un único punto. 

**SSO (Single Sign-On)** permite autenticarse una sola vez y acceder a múltiples sistemas sin volver a introducir credenciales.Sin SSO, cada aplicación tiene su propia base de usuarios y olvidar eliminar una cuenta es un riesgo real.

### Recomendación para GreenDevCorp

Con 20+ personas y crecimiento previsto, recomendamos **Keycloak**, una solución open source de gestión de identidad que soporta SSO, LDAP y se integra con Kubernetes via OpenID Connect.

La alternativa sería **Google Workspace** si ya se usa Gmail, ya que ofrece SSO integrado sin gestionarinfraestructura extra.

Para una empresa técnica como GreenDevCorp, Keycloak es la opción más adecuada. Si el equipo de operaciones es pequeño, Google Workspace es una alternativa válida con menos overhead.

---

## 3. Análisis de Seguridad

**Escape de tráfico entre entornos** — si las NetworkPolicies no están bien definidas, un pod de desarrollo podría accedera producción. Mitigación: `default-deny-all` en todos los namespaces y reglas de permitido explícitas y mínimas.

**Credenciales comprometidas** — sin SSO centralizado, una contraseña robada da acceso a múltiples sistemas. Mitigación: SSO + MFA obligatorio.

**Accesos temporales no revocados** — los accesos de partners o contratistas tienden a no eliminarse a tiempo. Mitigación: cuentas con expiración automática gestionadas desde el directorio central.

**Misconfiguration de NetworkPolicies** — una regla mal escrita puede bloquear tráfico legítimo o permitir tráfico no deseado. Mitigación: testear siempre en staging antes de aplicar en producción y documentar qué permite cada regla.

**Falta de auditoría** — sin logs centralizados de acceso es imposible saber quién hizo qué y cuándo. Mitigación: centralizar logs de autenticación y revisarlos periódicamente.
