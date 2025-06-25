# Busca Tabu para Particionamento Sequencial de Tarefas

Este projeto implementa uma heurística de **busca tabu** para resolver o problema de **trabalho balanceado** entre operadores heterogêneos de forma a minimizar o **makespan** (tempo máximo entre operadores).

---

## 📌 Descrição do Problema

Dado:

- Um conjunto de `n` tarefas que devem ser executadas sequencialmente.
- Um conjunto de `m` operadores heterogêneos.
- Uma matriz de tempos `p[i][j]`, onde `p[i][j]` é o tempo que o operador `j` leva para executar a tarefa `i`.

Objetivo:

- Particionar as tarefas em `m` intervalos **consecutivos** e atribuir um operador a cada intervalo, minimizando o **tempo máximo (makespan)** entre todos os operadores.

---

## 🚀 Execução

### Pré-requisitos

- [Julia](https://julialang.org/) 1.6 ou superior instalado
- Pacote `Random` (padrão)
- Nenhum pacote externo necessário

### Rodar o algoritmo

1. Certifique-se de que o arquivo `tba1.txt`, e demais arquivos testes, estão no mesmo diretório.
2. No terminal, execute:

```bash
julia busca_tabu.jl
