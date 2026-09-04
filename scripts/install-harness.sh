#!/usr/bin/env bash
# =============================================================================
# IA Harness — Global Host-Level Runtime Installer (Linux / macOS)
# =============================================================================
# Installs ia-harness assets into canonical global paths (~/.gemini and ~/.agents/skills)
# Usage:
#   ./scripts/install-harness.sh [--engine All|Gemini|OpenCode] [--force]
# =============================================================================

set -euo pipefail

# Colores ANSI
CLR_RESET="\033[0m"
CLR_CYAN="\033[1;36m"
CLR_GREEN="\033[1;32m"
CLR_YELLOW="\033[1;33m"
CLR_MAGENTA="\033[1;35m"
CLR_GRAY="\033[0;37m"
CLR_RED="\033[1;31m"

ENGINE=""
FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --engine)
      ENGINE="$2"
      shift 2
      ;;
    -e)
      ENGINE="$2"
      shift 2
      ;;
    --force|-f)
      FORCE=true
      shift
      ;;
    Gemini|OpenCode|All)
      ENGINE="$1"
      shift
      ;;
    *)
      echo -e "${CLR_YELLOW}[WARN] Opción desconocida: $1${CLR_RESET}"
      shift
      ;;
  esac
done

# Menú interactivo si no se especificó --engine
if [[ -z "${ENGINE}" ]]; then
  echo -e "${CLR_MAGENTA}============================================================${CLR_RESET}"
  echo -e "${CLR_MAGENTA}         IA HARNESS — INSTALADOR GLOBAL DE RUNTIME         ${CLR_RESET}"
  echo -e "${CLR_MAGENTA}============================================================${CLR_RESET}"
  echo -e "Seleccione el entorno a instalar en este equipo:\n"
  echo -e "  ${CLR_CYAN}[1] Gemini / Antigravity${CLR_RESET}"
  echo -e "  ${CLR_CYAN}[2] OpenCode${CLR_RESET}"
  echo -e "  ${CLR_CYAN}[3] Ambas (Instalaciones independientes sin mezclar)${CLR_RESET}"
  echo -e "  ${CLR_GRAY}[Q] Salir${CLR_RESET}\n"
  read -rp "Opción [1-3, Q]: " CHOICE
  case "${CHOICE}" in
    1) ENGINE="Gemini" ;;
    2) ENGINE="OpenCode" ;;
    3) ENGINE="All" ;;
    [Qq])
      echo -e "\n${CLR_YELLOW}Instalación cancelada por el usuario.${CLR_RESET}"
      exit 0
      ;;
    *)
      echo -e "\n${CLR_RED}[ERROR] Opción inválida: '${CHOICE}'. Abortando instalación.${CLR_RESET}"
      exit 1
      ;;
  esac
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
USER_HOME="${HOME}"

# Rutas de origen en el repositorio (Aisladas por motor)
GEMINI_DIR="${REPO_ROOT}/gemini"
GEMINI_SKILLS_SRC="${GEMINI_DIR}/.agent/skills"
WORKFLOWS_SRC="${GEMINI_DIR}/.agent/workflows"
SPECIFY_SRC="${GEMINI_DIR}/.specify"
HOOKS_SRC="${GEMINI_DIR}/hooks"
GEMINI_MD_SRC="${GEMINI_DIR}/GEMINI.md"
SETTINGS_SRC="${GEMINI_DIR}/settings.example.json"

OPENCODE_DIR="${REPO_ROOT}/opencode"
OPENCODE_SKILLS_SRC="${OPENCODE_DIR}/.agents/skills"
OPENCODE_CONFIG_SRC="${OPENCODE_DIR}/opencode.jsonc"
OPENCODE_AGENTS_SRC="${OPENCODE_DIR}/AGENTS.md"

# Rutas de destino globales en el host
GEMINI_BASE="${USER_HOME}/.gemini"
GEMINI_SKILLS="${GEMINI_BASE}/.agent/skills"
GEMINI_WORKFLOWS="${GEMINI_BASE}/.agent/workflows"
GEMINI_SPECIFY="${GEMINI_BASE}/.specify"
GEMINI_HOOKS="${GEMINI_BASE}/hooks"
GEMINI_MD="${GEMINI_BASE}/GEMINI.md"
GEMINI_SETTINGS="${GEMINI_BASE}/settings.json"

OPENCODE_SKILLS="${USER_HOME}/.agents/skills"
OPENCODE_CONFIG_DIR="${USER_HOME}/.config/opencode"
OPENCODE_CONFIG="${OPENCODE_CONFIG_DIR}/opencode.json"
OPENCODE_AGENTS="${OPENCODE_CONFIG_DIR}/AGENTS.md"

echo -e "\n${CLR_MAGENTA}============================================================${CLR_RESET}"
echo -e "${CLR_MAGENTA}         IA HARNESS — INSTALADOR GLOBAL DE RUNTIME         ${CLR_RESET}"
echo -e "${CLR_MAGENTA}============================================================${CLR_RESET}"
echo -e "  Repositorio Fuente : ${REPO_ROOT}"
echo -e "  Directorio Host    : ${USER_HOME}"
echo -e "  Motor Seleccionado : ${ENGINE}"

copy_skills() {
  local src_dir="$1"
  local dest_dir="$2"
  local engine_name="$3"

  if [[ ! -d "${src_dir}" ]]; then
    echo -e "  ${CLR_YELLOW}[WARN] Directorio de skills no encontrado: ${src_dir}${CLR_RESET}"
    return
  fi

  mkdir -p "${dest_dir}"
  local count=0
  for skill_path in "${src_dir}"/*; do
    if [[ -d "${skill_path}" ]]; then
      local skill_name="$(basename "${skill_path}")"
      mkdir -p "${dest_dir}/${skill_name}"
      cp -r "${skill_path}/"* "${dest_dir}/${skill_name}/"
      count=$((count + 1))
    fi
  done
  echo -e "  ${CLR_GREEN}[OK] ${count} skills instaladas en ${dest_dir} (${engine_name})${CLR_RESET}"
}

# ─────────────────────────────────────────────────────────────────────────────
# Gemini / Antigravity
# ─────────────────────────────────────────────────────────────────────────────
if [[ "${ENGINE}" == "All" || "${ENGINE}" == "Gemini" ]]; then
  echo -e "\n${CLR_CYAN}[STEP] Instalando runtime para Gemini / Antigravity...${CLR_RESET}"

  # 1. Skills
  copy_skills "${GEMINI_SKILLS_SRC}" "${GEMINI_SKILLS}" "Gemini"

  # 2. Workflows
  if [[ -d "${WORKFLOWS_SRC}" ]]; then
    mkdir -p "${GEMINI_WORKFLOWS}"
    cp -r "${WORKFLOWS_SRC}/"* "${GEMINI_WORKFLOWS}/"
    echo -e "  ${CLR_GREEN}[OK] Workflows speckit instalados en ${GEMINI_WORKFLOWS}${CLR_RESET}"
  fi

  # 3. .specify
  if [[ -d "${SPECIFY_SRC}" ]]; then
    mkdir -p "${GEMINI_SPECIFY}"
    cp -r "${SPECIFY_SRC}/"* "${GEMINI_SPECIFY}/"
    echo -e "  ${CLR_GREEN}[OK] Capa de gobernanza (.specify) instalada en ${GEMINI_SPECIFY}${CLR_RESET}"
  fi

  # 4. Hooks
  if [[ -d "${HOOKS_SRC}" ]]; then
    mkdir -p "${GEMINI_HOOKS}"
    cp -r "${HOOKS_SRC}/"* "${GEMINI_HOOKS}/"
    chmod +x "${GEMINI_HOOKS}/"* 2>/dev/null || true
    echo -e "  ${CLR_GREEN}[OK] Hooks de runtime instalados en ${GEMINI_HOOKS}${CLR_RESET}"
  fi

  # 5. GEMINI.md
  if [[ -f "${GEMINI_MD_SRC}" ]]; then
    cp "${GEMINI_MD_SRC}" "${GEMINI_MD}"
    echo -e "  ${CLR_GREEN}[OK] Entry point global instalado en ${GEMINI_MD}${CLR_RESET}"
  fi

  # 6. settings.json
  if [[ ! -f "${GEMINI_SETTINGS}" ]]; then
    if [[ -f "${SETTINGS_SRC}" ]]; then
      cp "${SETTINGS_SRC}" "${GEMINI_SETTINGS}"
      echo -e "  ${CLR_GREEN}[OK] Plantilla settings.json inicializada en ${GEMINI_SETTINGS}${CLR_RESET}"
    fi
  elif [[ "${FORCE}" == true ]]; then
    cp "${SETTINGS_SRC}" "${GEMINI_SETTINGS}"
    echo -e "  ${CLR_YELLOW}[WARN] settings.json sobrescrito forzosamente con settings.example.json${CLR_RESET}"
  else
    echo -e "  ${CLR_GRAY}[INFO] settings.json preexistente conservado en ${GEMINI_SETTINGS} (usa --force para sobrescribir)${CLR_RESET}"
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# OpenCode
# ─────────────────────────────────────────────────────────────────────────────
if [[ "${ENGINE}" == "All" || "${ENGINE}" == "OpenCode" ]]; then
  echo -e "\n${CLR_CYAN}[STEP] Instalando runtime para OpenCode...${CLR_RESET}"

  # 1. Skills globales (~/.agents/skills)
  copy_skills "${OPENCODE_SKILLS_SRC}" "${OPENCODE_SKILLS}" "OpenCode"

  # 2. Configuración y directrices (~/.config/opencode/)
  mkdir -p "${OPENCODE_CONFIG_DIR}"
  if [[ -f "${OPENCODE_AGENTS_SRC}" ]]; then
    cp "${OPENCODE_AGENTS_SRC}" "${OPENCODE_AGENTS}"
    echo -e "  ${CLR_GREEN}[OK] Directrices AGENTS.md instaladas en ${OPENCODE_AGENTS}${CLR_RESET}"
  fi

  if [[ ! -f "${OPENCODE_CONFIG}" ]]; then
    if [[ -f "${OPENCODE_CONFIG_SRC}" ]]; then
      cp "${OPENCODE_CONFIG_SRC}" "${OPENCODE_CONFIG}"
      echo -e "  ${CLR_GREEN}[OK] Configuración inicializada en ${OPENCODE_CONFIG}${CLR_RESET}"
    fi
  elif [[ "${FORCE}" == true ]]; then
    cp "${OPENCODE_CONFIG_SRC}" "${OPENCODE_CONFIG}"
    echo -e "  ${CLR_YELLOW}[WARN] opencode.json sobrescrito forzosamente con opencode.jsonc${CLR_RESET}"
  else
    echo -e "  ${CLR_GRAY}[INFO] opencode.json preexistente conservado en ${OPENCODE_CONFIG} (usa --force para sobrescribir)${CLR_RESET}"
  fi
fi

echo -e "\n${CLR_GREEN}============================================================${CLR_RESET}"
echo -e "${CLR_GREEN}       INSTALACIÓN DEL HARNESS COMPLETADA EXITOSAMENTE     ${CLR_RESET}"
echo -e "${CLR_GREEN}============================================================${CLR_RESET}"
echo -e "Los motores ahora ejecutan y resuelven skills desde las rutas globales del host."
