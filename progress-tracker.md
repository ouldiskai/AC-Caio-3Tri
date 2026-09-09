# Progress Tracker

## Status atual
- Ciclo: C1 — Núcleo Jogável
- Status do ciclo: EM VALIDAÇÃO
- Spec ativa: c1-boss-rush-core.md
- Pergunta do ciclo: O jogador consegue realizar a ação principal?

## Evidências
- O protótipo do boss rush foi definido com 4 chefes, ordem aleatória, upgrades permanentes e vitória por eliminação dos 4 chefes.
- A regra de parry inicial foi fechada: acerto anula dano e dispara contra-ataque imediato; em sequência, o último golpe da combo é o gatilho da recompensa.
- A falha no parry foi definida como penalidade de dano e controle sem stunlock infinito.
- O balanceamento inicial foi ajustado para HP do boss em 250, HP do jogador em 100 e janela de parry em 120 ms.

## Próximo unit de implementação
- Unidade: protótipo de combate 1x1 contra um boss único.
- Objetivo: validar a ação principal de ataque, esquiva, parry e contra-ataque.
- Escopo: um boss, um jogador, HP fixos, parry, dano, dano de falha e vitória/derrota do combate.
- Não escopo: run completa, 4 chefes, upgrades permanentes, tela de seleção de habilidades.

## Blocos e dependências
- Dependência de design: o parry e a regra de contra-ataque precisam ser confirmados pelo playtest.
- Dependência técnica: construir um controller simples do jogador e do boss em ataque/defesa.

## Próximo passo
- Implementar o protótipo de chefe único e validar se o parry produz a sensação de risco e recompensa pretendida.
