# Progress Tracker

## Status atual
- Ciclo: C1 — Núcleo Jogável
- Status do ciclo: EM VALIDAÇÃO
- Spec ativa: c1-boss-rush-core.md
- Pergunta do ciclo: O jogador consegue realizar a ação principal?

## Evidências
- O protótipo do boss rush foi definido com 4 chefes, ordem aleatória, upgrades permanentes e vitória por eliminação dos 4 chefes.
- A regra de parry atual é defensiva: acerto anula o dano do golpe e atordoa brevemente o boss, sem dano; o HP do boss só diminui pelo ataque do jogador.
- A falha no parry foi definida como penalidade de dano e controle sem stunlock infinito.
- O balanceamento inicial foi ajustado para HP do boss em 250, HP do jogador em 100 e janela de parry em 120 ms.
- `attack1` agora resolve o impacto no quadro de contato da animação e só retorna a `idle` após o fim do movimento; o hitbox não acerta durante a preparação.
- Parry dentro do alcance anula o dano recebido e atordoa o boss; não aplica dano.
- Godot 4.7.2 headless: parsing do projeto passou; smoke test de 900 frames sem erros, mas a seleção automática repetiu `attack2` e não cobriu `attack1`.
- `attack2` agora só causa dano no quadro de contato pela resolução central do controller; a animação não é cortada no impacto e ataques cancelados por stun não emitem um hit atrasado.
- Godot 4.7.2 headless: smoke test de 300 frames iniciou `attack2` sem erros e registrou um único dano, sem colisão antecipada do hitbox.
- Na faixa intermediária, o boss alterna `attack2` e `attack1` conforme o golpe anterior; o alcance do porrete foi aumentado para 170 px. O alcance horizontal do ataque do player passou de 90 para 150 px, preservando os testes de direção e altura.
- Godot 4.7.2 headless: em 900 frames a sequência observada foi `attack2` seguida por `attack1`, sem erros de runtime.
- O jogo inicia no menu; ao morrer, o jogador emite evento terminal e a luta retorna ao menu. Ao vencer, exibe mensagem por 2,5 s antes de retornar.
- Godot 4.7.2 headless: menu padrão executou por 90 frames e a arena por 240 frames, ambos sem erros.

## Próximo unit de implementação
- Unidade: protótipo de combate 1x1 contra um boss único.
- Objetivo: validar a ação principal de ataque, esquiva e parry defensivo.
- Escopo: um boss, um jogador, HP fixos, parry, dano, dano de falha e vitória/derrota do combate.
- Não escopo: run completa, 4 chefes, upgrades permanentes, tela de seleção de habilidades.

## Blocos e dependências
- Dependência de design: a janela e o feedback do parry defensivo precisam ser confirmados pelo playtest.
- Dependência técnica: construir um controller simples do jogador e do boss em ataque/defesa.
- Implementação atual: boss em 1x1 com 3 padrões (porrete, dash, bola de fogo), HP do jogador em 90 e do boss em 220, parry com janela de 100 ms.

## Próximo passo
- Implementar o protótipo de chefe único e validar se o parry produz a sensação de risco e recompensa pretendida.
- Fazer playtest visual de `attack1` e `attack2`, especialmente os quadros de contato, a janela de 100 ms do parry e o cancelamento por stun, antes de considerar o timing validado.
- Fazer playtest do novo alcance do golpe do player para confirmar se os 150 px parecem responsivos sem tornar o combate fácil demais.
