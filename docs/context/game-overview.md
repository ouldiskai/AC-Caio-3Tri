# Visão Geral do Jogo

## Premissa
O jogo é um boss rush em estilo coliseu, com 4 chefes em sequência, em ordem aleatória por run. O jogador entra em uma arena, enfrenta cada oponente individualmente, aprende seu padrão de ataque e, ao derrotá-lo, recebe 3 opções de habilidades relacionadas ao boss derrotado. O jogador escolhe apenas uma delas, e a habilidade permanece permanente até o fim da run.

## Eixos estruturais
- Ritmo: tempo real, com troca de golpes, esquiva e parry em janelas de tempo apertadas.
- Unidade de jogo: run de 4 chefes em um coliseu.
- Controle: direto sobre um único avatar, com ação de ataque, esquiva e parry.
- Fim: fim definido por vitória após derrotar os 4 chefes ou derrota ao zerar a vida do jogador.

## Experiência pretendida
Sensação de evolução e superação: cada chefão ensina ao jogador uma forma de lidar com o combate, e a combinação das habilidades herdadas cria builds progressivas e especializadas ao longo da run.

## Referências
- Titan Souls: foco em boss fights precisos e aprendizado de padrões.
- Nine Sols: sensação de evolução de combate e de domínio de mecânicas.
- Dead Cells: recompensa por builds progressivas e escolhas de upgrades.

## Decisões estabilizadas do ciclo atual
- O jogo é apenas boss rush; não há salas, mapas ou exploração em áreas.
- A ordem dos chefes é aleatória a cada run.
- O jogador escolhe somente 1 das 3 habilidades oferecidas por cada boss derrotado.
- O máximo de habilidades permanentes na run é 3.
- O jogador derrota o jogo ao zerar os 4 chefes.
- O jogador perde ao chegar a 0 de HP.
- A recompensa por parry é contra-ataque imediato após a deflexão do último ataque em sequência.
- Falha no parry causa dano e vulnerabilidade, mas sem stunlock infinito.
- Para o protótipo inicial de combate 1x1, o jogador começa com 90 HP, o boss com 220 HP e a janela de parry aceita 100 ms; a intenção é priorizar tensão e ritmo rápido para aprender o padrão de ataque.
- O primeiro protótipo válido deve incluir um boss único com 3 padrões de ataque distintos e uma resposta de contra-ataque clara, para testar leitura de padrão e timing sem expandir o escopo para a run completa.
- Os 3 padrões do boss no protótipo são: ataque de porrete no chão à frente, dash para frente e bola de fogo arremessada; esses ataques serão usados como a base do aprendizado do timing do jogador.
- O ataque de porrete será a introdução do parry: ele é um golpe mais lento, com leitura clara e tempo suficiente para o jogador reagir e encaixar a deflexão antes de os padrões mais agressivos entrarem em cena.
- A sequência de ensino do protótipo será porrete, dash e bola de fogo: o porrete começa punindo a proximidade excessiva para forçar distância média; o dash quebra essa distância e obriga o jogador a alternar a posição; a bola de fogo pune a distância excessiva ou a espera passiva do jogador.
