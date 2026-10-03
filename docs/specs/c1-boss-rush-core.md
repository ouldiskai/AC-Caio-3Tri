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
  - Então o jogo deve anular o dano do ataque e atordoar brevemente o boss, sem causar dano ao boss.
  - E dado que o boss realiza uma sequência de ataques consecutivos,
  - Quando o jogador realiza o parry no último golpe dessa sequência,
  - Então o efeito de atordoamento deve ocorrer somente após a deflexão do último ataque.
  - E dado que o boss realiza um único golpe,
  - Quando o jogador acerta o parry,
  - Então o boss deve ser atordoado imediatamente após a deflexão, e seu HP só pode ser reduzido pelo ataque do jogador.

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

### REQ-BOSS-08
- Prioridade: Alta
- Status: Provisório
- Identificador: REQ-BOSS-08
- Origem: decisão do aluno para o protótipo de combate 1x1; prioriza tensão e ritmo rápido para validar a leitura de padrões do boss em um cenário exigente.
- Critério de aceitação:
  - Dado que uma partida de boss único começa,
  - Quando o protótipo carregar,
  - Então o jogador deve iniciar com 90 HP e o boss deve iniciar com 220 HP.
  - E dado que o jogador tenta executar um parry,
  - Quando a janela de tempo do golpe for aberta,
  - Então a janela aceitável para sucesso deve ser de 100 ms.
  - E dado que o jogador falha o parry,
  - Quando o ataque do boss conectar,
  - Então a penalidade deve causar dano elevado e reduzir o controle do combate para manter a pressão do protótipo.

### REQ-BOSS-09
- Prioridade: Alta
- Status: Provisório
- Identificador: REQ-BOSS-09
- Origem: escolha do aluno de reduzir o protótipo a um único boss com 3 padrões de ataque distintos para validar leitura de padrão e timing antes de ampliar para a run completa.
- Critério de aceitação:
  - Dado que o protótipo de combate do boss único é carregado,
  - Quando a luta começar,
  - Então o boss deve alternar entre 3 padrões de ataque distintos e reconhecíveis: porrete no chão à frente, dash para frente e bola de fogo disparada.
  - E dado que o jogador acerta o parry em um ataque do padrão,
  - Quando o ataque for defletido,
  - Então o jogo deve atordoar brevemente o boss e sinalizar claramente o sucesso, sem causar dano ao boss.
  - E dado que o protótipo não inclui a run completa,
  - Quando a validação começar,
  - Então o jogo não deve apresentar seleção de habilidades, mudança de boss ou progressão entre chefes.

### REQ-BOSS-10
- Prioridade: Alta
- Status: Provisório
- Identificador: REQ-BOSS-10
- Origem: decisão do aluno de usar o ataque de porrete como o gesto de ensino do parry, com leitura mais lenta e mais clara para a primeira aprendizagem.
- Critério de aceitação:
  - Dado que o boss inicia o ataque de porrete,
  - Quando a animação de impacto no chão à frente for exibida,
  - Então o golpe deve ser suficientemente lento para que o jogador tenha tempo de identificar a janela de parry.
  - E dado que o ataque de porrete for o primeiro padrão do protótipo,
  - Quando o jogador acertar o parry,
  - Então o jogo deve confirmar o sucesso com atordoamento breve e feedback claro, sem dano ao boss.

### REQ-BOSS-11
- Prioridade: Alta
- Status: Provisório
- Identificador: REQ-BOSS-11
- Origem: decisão do aluno sobre a ordem de apresentação dos padrões de ataque do boss para ensinar posicionamento e alternância de distância.
- Critério de aceitação:
  - Dado que o protótipo inicia a primeira sequência de combate,
  - Quando o boss usar o primeiro padrão,
  - Então ele deve começar com o porrete para punir o jogador por ficar muito perto e forçar uma distância média.
  - E dado que o jogador se mantém muito próximo após o porrete,
  - Quando o boss usar o dash,
  - Então o dash deve quebrar a distância de segurança e forçar o jogador a alternar de posicionamento.
  - E dado que o jogador se afasta demais ou fica parado esperando o boss,
  - Quando o boss usar a bola de fogo,
  - Então a bola de fogo deve punir esse comportamento e obrigar a reconfiguração de distância.

## Perguntas em aberto
- Quais habilidades de cada boss devem estar prontas para a primeira build?
- Como a progressão de boss para boss deve ser visualmente comunicada ao jogador?

## Observações
- Esta spec representa o primeiro incremento jogável do ciclo e deve ser validada com playtest antes de avançar para o próximo ciclo.
