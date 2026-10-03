# Diário de Aprendizado

## 2026-10-03 — Timing do porrete e parry

- O `attack1` era interrompido no meio: o dano era resolvido antes do quadro de contato e o boss voltava para `idle` logo depois.
- O hitbox também ficava ativo durante a preparação, podendo causar dano antes do momento que o jogador deveria ler e defender.
- O impacto agora usa o timing dos frames da animação; o golpe não abre hitbox antecipado e a animação termina antes da recuperação.
- A resolução de parry agora respeita o alcance, cancela o dano do boss e devolve dano ao boss.
- Validação: Godot 4.7.2 carregou o projeto em modo headless sem erro de parser; a simulação de 900 frames não reportou erros de runtime, mas não selecionou `attack1`.
- Próxima observação: confirmar visualmente o quadro de impacto e se a janela de parry de 100 ms é legível e executável.

## 2026-10-03 — Dano atrasado do dash

- O `attack2` aplicava dano por dois caminhos: um hitbox ativo desde o início do dash e o sinal atrasado do controller.
- A coroutine do ataque podia continuar após `stun_for()` ter interrompido a animação e ainda emitir o sinal de dano.
- O hitbox antecipado foi removido; o controller resolve o impacto uma única vez no quadro de contato. A coroutine agora confirma que o ataque ainda está ativo antes de emitir o hit, e o dash aguarda o fim da animação antes de voltar a `idle`.
- O ataque não inicia a lógica de dano se a animação correspondente não puder ser tocada.
- Validação: parsing headless sem erros; smoke test de 300 frames executou `attack2` e registrou um único dano, sem o evento antigo do hitbox.
- Próxima observação: testar com input real o parry e a interrupção por stun para conferir o timing e o cancelamento visualmente.

## 2026-10-03 — Alternância do boss e alcance do jogador

- Na faixa intermediária, a decisão de ataque sempre retornava `attack2`; agora alterna entre dash e porrete com base no padrão anterior.
- O porrete recebeu alcance efetivo de 170 px para funcionar melhor após um dash; o golpe horizontal do jogador passou a 150 px, mantendo direção e limite vertical.
- Validação: projeto carregado no Godot 4.7.2 headless; em 900 frames foram observados `attack2` e depois `attack1`, sem erros.
- Próxima observação: playtest visual do alcance do jogador para confirmar a responsividade e o equilíbrio.

## 2026-10-03 — Menu, parry defensivo e encerramento

- O pedido de design mudou o papel do parry: ele agora apenas evita dano e atordoa brevemente; não reduz o HP do boss. O dano ao boss fica exclusivamente no ataque do jogador.
- O projeto inicia pelo menu. Morrer encerra a luta e retorna ao menu; derrotar o boss mostra “Boss derrotado! Obrigado por jogar.” por 2,5 s antes do retorno.
- Validação no Godot 4.7.2 headless: o menu padrão executou por 90 frames e a arena por 240 frames, sem erros.
- Próxima observação: validar por interação visual os botões do menu e os caminhos de vitória/derrota.
