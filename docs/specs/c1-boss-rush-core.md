# Spec do Ciclo 1 — Núcleo Jogável

## Resumo do incremento
Prototipar uma run de boss rush com 4 chefes, ordem aleatória, escolhas permanentes de habilidades após cada chefão e um sistema de parry que recompensa precisão sem causar stunlock.

## Requisitos

### REQ-BOSS-01
- Prioridade: Alta
- Status: Provisório
- Identificador: REQ-BOSS-01
- Origem: ideação do projeto e decisão do aluno; proposta de boss rush em coliseu com 4 bosses e ordem aleatória.
- Critério de aceitação:
  - Dado que o jogador inicia uma run,
  - Quando a partida começar,
  - Então o jogo deve selecionar aleatoriamente a sequência de 4 chefes que o jogador enfrentará.

### REQ-BOSS-02
- Prioridade: Alta
- Status: Provisório
- Identificador: REQ-BOSS-02
- Origem: decisão de build inicial e de compra de upgrades permanentes após cada chefão.
- Critério de aceitação:
  - Dado que o jogador derrota um boss,
  - Quando o combate terminar,
  - Então o jogo deve abrir uma tela de escolha com 3 habilidades relacionadas ao boss derrotado.

### REQ-BOSS-03
- Prioridade: Alta
- Status: Provisório
- Identificador: REQ-BOSS-03
- Origem: regra de permanência, número máximo de habilidades e exclusão de duplicatas do mesmo boss.
- Critério de aceitação:
  - Dado que o jogador seleciona uma habilidade,
  - Quando ela for escolhida,
  - Então a habilidade deve se tornar permanente para o restante da run.
  - E dado que o jogador já possui 3 habilidades permanentes,
  - Quando o próximo boss for derrotado,
  - Então a escolha deve ser bloqueada e a run deve seguir sem permitir uma quarta habilidade.
  - E dado que a habilidade escolhida é do mesmo boss que já foi derrotado anteriormente,
  - Quando a tela de escolha abrir,
  - Então o jogo deve excluir a opção repetida do mesmo boss da lista de escolhas.

### REQ-BOSS-04
- Prioridade: Alta
- Status: Provisório
- Identificador: REQ-BOSS-04
- Origem: condição de vitória/derrota da run.
- Critério de aceitação:
  - Dado que o jogador derrotou os 4 bosses,
  - Quando a vida do último boss chegar a 0,
  - Então a partida deve ser considerada vencida e a run deve encerrar com o resumo final.
  - E dado que a vida do jogador chega a 0,
  - Quando o HP atingir 0,
  - Então a partida deve ser considerada perdida e a run deve encerrar.

### REQ-BOSS-05
- Prioridade: Alta
- Status: Provisório
- Identificador: REQ-BOSS-05
- Origem: regra do parry e recompensa por precisão, escolhida no playtest inicial.
- Critério de aceitação:
  - Dado que o jogador acerta um parry em um ataque do boss,
  - Quando o momento da deflexão for correto,
  - Então o jogo deve anular o dano do ataque e executar um contra-ataque imediato.
  - E dado que o boss realiza uma sequência de ataques consecutivos,
  - Quando o jogador realiza o parry no último golpe dessa sequência,
  - Então o jogo deve disparar o contra-ataque somente após a deflexão do último ataque.
  - E dado que o boss realiza um único golpe,
  - Quando o jogador acerta o parry,
  - Então o contra-ataque deve acontecer imediatamente após a deflexão.

### REQ-BOSS-06
- Prioridade: Alta
- Status: Provisório
- Identificador: REQ-BOSS-06
- Origem: punição da falha no parry sem stunlock excessivo.
- Critério de aceitação:
  - Dado que o jogador falha o parry,
  - Quando o ataque conecta,
  - Então o jogador deve receber dano com penalidade de tempo ou redução de controle, mas sem ficar travado em sequência infinita de dano.
  - E dado que a falha do parry acontece em uma sequência de ataques,
  - Quando a janela de punição for concluída,
  - Então o jogador deve recuperar o controle do personagem e poder continuar o combate.

### REQ-BOSS-07
- Prioridade: Média
- Status: Provisório
- Identificador: REQ-BOSS-07
- Origem: objetivo de sumarizar a run ao final.
- Critério de aceitação:
  - Dado que a run termina em vitória ou derrota,
  - Quando a tela de fim for exibida,
  - Então o jogo deve mostrar status finais do jogador, tempo de partida e habilidades adquiridas.

## Perguntas em aberto
- Qual deve ser a regra inicial de vida, dano e janela de parry para o protótipo?
- Quais habilidades de cada boss devem estar prontas para a primeira build?
- Como a progressão de boss para boss deve ser visualmente comunicada ao jogador?

## Observações
- Esta spec representa o primeiro incremento jogável do ciclo e deve ser validada com playtest antes de avançar para o próximo ciclo.
