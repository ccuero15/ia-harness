---
name: daily_analysis
description: Procedimiento estructurado para transformar logs, commits y transcripciones en reportes ejecutivos (Daily/Weekly) para Fibex Corporativo.
---

# Procedimiento de Generación de Reportes

Al activarse esta skill, el agente debe actuar como **@PM_TechnicalLead** siguiendo estos pasos:

## 1. Fase de Ingesta y Análisis

* **Extracción Multimodal**: Procesa archivos de soporte, grabaciones o texto identificando "speakers" y tiempos.
* **Filtrado de Ruido**: Enfocarse exclusivamente en:
  * **Tickets/Issues**: IDs específicos (ej: Issue #51).
  * **Stack**: Laravel, PHP, JavaScript, NextJs, TypeScript, ReactJS, TailwindCSS, Eloquent, HubSpot, etc.
  * **Trazabilidad**: Nombres de archivos, ramas de Git o grabaciones (ej: `Meeting_Christian_29042026.docx`).
  * **Metricas**: Tiempos, Esfuerzo, Costos, etc.
* **Validación de Persistencia**: Consultar el `engram-memory-protocol` para detectar estancamientos o reincidencia en bloqueos previos.
* **Mapeo Oficial de Integrantes**:
  * **Salvador Villa (SV)**: Ingeniero Backend
  * **Freddy Becerra (FB)**: Desarrollador Frontend
  * **Juan Izaguirre (JI)**: Ingeniero Frontend
  * **Hugo Brunicardi (HB)**: Desarrollador Frontend
  * **Edinson Cabello (EC)**: Ingeniero Frontend
  * **Edgardo Gonzalez (EG)**: Ingeniero QA

## 2. Estándares de Formato (Toolkit)

* **Jerarquía**: Usar `#` y `##` para secciones; `---` para separar roles.
* **Estilo**: Bullet points concisos. **Negrita** para términos técnicos, issues y nombres clave.
* **Idioma**: Explicaciones en Español Técnico / Código y variables en Inglés.

---

## 3. Output: Reporte Daily Integrado

**Título: Reporte Daily - Fibex Corporativo** **Fecha:** [Día, Mes, Año] | **Supervisor:** Christian Cuero
 
* **[Nombre y Rol]:** (Ej:Ingeniero de software: Salvador Villa - Backend)
  * **Actividades Realizadas (Ayer):** Logros técnicos e #Issues resueltos.
  * **Plan de Trabajo (Hoy):** Tareas prioritarias para las próximas 24h.
  * **Bloqueos:** Factores técnicos/externos que impiden el avance.

### Sección de Gestión (Christian Cuero)

* **Acciones y Acuerdos:** Decisiones tomadas para destrabar procesos o priorizar entregas (QA, validaciones).

---

## 4. Output: Reporte Semanal (Weekly)

* **Hitos de la Semana:** Resumen ejecutivo de objetivos alcanzados.
* **QA Pendiente:** Tareas esperando aprobación.
* **Next Steps:** Objetivos estratégicos para la próxima semana.
* **Dependencias:** Insumos faltantes (logos, formularios HubSpot, etc.).

---

## 5. Regla de Salida (Lean-Mode)

Tras generar el reporte en el `Dossier Interno`, la respuesta en `stdout` debe ser:
`Status` | `Memory Sync` | `Critical Finding` (Límite < 50 palabras).
